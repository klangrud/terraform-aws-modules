//go:build integration
// +build integration

package ec2_scalable_test

import (
	"context"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	ec2types "github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/aws/aws-sdk-go-v2/service/iam"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"test/shared"
)

const awsProfile = "infra-sandbox"

func GetRegionFromProfile() string {
	cfg, err := awsconfig.LoadDefaultConfig(
		context.TODO(),
		awsconfig.WithSharedConfigProfile(awsProfile),
	)
	if err != nil {
		panic(fmt.Sprintf("Unable to load SDK config: %v", err))
	}
	return cfg.Region
}

func LoadAwsConfig(ctx context.Context, region string) aws.Config {
	cfg, err := awsconfig.LoadDefaultConfig(ctx,
		awsconfig.WithRegion(region),
		awsconfig.WithSharedConfigProfile(awsProfile),
	)
	if err != nil {
		panic(fmt.Sprintf("Failed to load AWS config with profile %s: %v", awsProfile, err))
	}
	return cfg
}

func setupIntegrationTestOptions(extraVars map[string]interface{}) *terraform.Options {
	region := GetRegionFromProfile()

	// Get default VPC and subnet for testing
	cfg := LoadAwsConfig(context.TODO(), region)
	ec2Client := ec2.NewFromConfig(cfg)

	// Find default VPC
	vpcResp, err := ec2Client.DescribeVpcs(context.TODO(), &ec2.DescribeVpcsInput{
		Filters: []ec2types.Filter{
			{
				Name:   aws.String("is-default"),
				Values: []string{"true"},
			},
		},
	})
	if err != nil || len(vpcResp.Vpcs) == 0 {
		panic("Could not find default VPC for integration tests")
	}
	vpcID := *vpcResp.Vpcs[0].VpcId

	// Find subnets in default VPC
	subnetResp, err := ec2Client.DescribeSubnets(context.TODO(), &ec2.DescribeSubnetsInput{
		Filters: []ec2types.Filter{
			{
				Name:   aws.String("vpc-id"),
				Values: []string{vpcID},
			},
		},
	})
	if err != nil || len(subnetResp.Subnets) == 0 {
		panic("Could not find subnets in default VPC for integration tests")
	}

	subnetIDs := make([]string, 0)
	for _, subnet := range subnetResp.Subnets {
		subnetIDs = append(subnetIDs, *subnet.SubnetId)
		if len(subnetIDs) >= 2 {
			break
		}
	}

	defaultVars := map[string]interface{}{
		"project_name":               fmt.Sprintf("integ-test-ec2-%d", time.Now().Unix()),
		"env_short":                  "test",
		"vpc_id":                     vpcID,
		"subnet_ids":                 subnetIDs,
		"ec2_key_pair":               "integration-test-key", // Must exist in AWS account
		"ami_id":                     "ami-0017468bf94789869",
		"instance_type":              "t3a.micro", // Use smallest instance for cost savings
		"create_security_group":      true,
		"allowed_cidr_blocks":        []string{"10.0.0.0/8"},
		"enable_security_updates":    true,
		"install_ssm_agent":          true,
		"disable_api_termination":    false, // Allow termination in tests
		"enable_detailed_monitoring": false,
		"tags": map[string]string{
			"Environment": "integration-test",
			"ManagedBy":   "terraform-integration-test",
			"AutoDelete":  "true",
		},
	}

	for k, v := range extraVars {
		defaultVars[k] = v
	}

	return &terraform.Options{
		TerraformDir: "./fixtures/basic",
		Vars:         defaultVars,
		EnvVars: map[string]string{
			"AWS_PROFILE": awsProfile,
		},
		Upgrade: true,
	}
}

// TestEC2BasicDeployment tests basic EC2 instance deployment
func TestEC2BasicDeployment(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()

	opts := setupIntegrationTestOptions(nil)

	// Clean up at the end
	defer terraform.Destroy(t, opts)

	// Deploy the infrastructure
	terraform.InitAndApply(t, opts)

	// Verify outputs
	instanceIDs := terraform.OutputList(t, opts, "instance_ids")
	require.NotEmpty(t, instanceIDs, "Instance IDs should not be empty")
	require.Len(t, instanceIDs, 1, "Should create exactly 1 instance")

	instanceID := instanceIDs[0]
	require.True(t, strings.HasPrefix(instanceID, "i-"), "Instance ID should have valid format")

	privateIPs := terraform.OutputList(t, opts, "instance_private_ips")
	require.NotEmpty(t, privateIPs, "Private IPs should not be empty")

	securityGroupID := terraform.Output(t, opts, "security_group_id")
	require.NotEmpty(t, securityGroupID, "Security group ID should not be empty")

	iamRoleName := terraform.Output(t, opts, "iam_role_name")
	require.NotEmpty(t, iamRoleName, "IAM role name should not be empty")

	t.Logf("✅ Basic EC2 deployment completed in %s", time.Since(start))
}

// TestEC2WithDataVolume tests EC2 deployment with /data volume
func TestEC2WithDataVolume(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()

	extraVars := map[string]interface{}{
		"enable_data_volume": true,
		"data_volume_size":   10, // Small size for testing
	}

	opts := setupIntegrationTestOptions(extraVars)
	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	// Verify instance and volumes
	instanceIDs := terraform.OutputList(t, opts, "instance_ids")
	require.NotEmpty(t, instanceIDs)

	ebsVolumeIDs := terraform.OutputMap(t, opts, "ebs_volume_ids")
	require.NotEmpty(t, ebsVolumeIDs, "EBS volumes should be created")

	// Verify volume is attached
	cfg := LoadAwsConfig(context.TODO(), GetRegionFromProfile())
	ec2Client := ec2.NewFromConfig(cfg)

	for _, volID := range ebsVolumeIDs {
		volResp, err := ec2Client.DescribeVolumes(context.TODO(), &ec2.DescribeVolumesInput{
			VolumeIds: []string{volID},
		})
		require.NoError(t, err)
		require.Len(t, volResp.Volumes, 1)

		vol := volResp.Volumes[0]
		require.Equal(t, ec2types.VolumeStateInUse, vol.State, "Volume should be in-use")
		require.NotEmpty(t, vol.Attachments, "Volume should have attachments")
	}

	t.Logf("✅ EC2 with /data volume deployment completed in %s", time.Since(start))
}

// TestEC2WithMultipleVolumes tests EC2 with multiple EBS volumes
func TestEC2WithMultipleVolumes(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()

	extraVars := map[string]interface{}{
		"additional_ebs_volumes": []map[string]interface{}{
			{
				"device_name": "/dev/sdf",
				"mount_point": "/data1",
				"volume_size": 10,
				"volume_type": "gp3",
			},
			{
				"device_name": "/dev/sdg",
				"mount_point": "/data2",
				"volume_size": 15,
				"volume_type": "gp3",
			},
		},
	}

	opts := setupIntegrationTestOptions(extraVars)
	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	// Verify multiple volumes created
	ebsVolumeIDs := terraform.OutputMap(t, opts, "ebs_volume_ids")
	require.Len(t, ebsVolumeIDs, 2, "Should create 2 EBS volumes")

	t.Logf("✅ EC2 with multiple volumes deployment completed in %s", time.Since(start))
}

// TestEC2MultipleInstances tests deployment of multiple instances
func TestEC2MultipleInstances(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()

	extraVars := map[string]interface{}{
		"instance_count": 2,
	}

	opts := setupIntegrationTestOptions(extraVars)
	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	// Verify 2 instances created
	instanceIDs := terraform.OutputList(t, opts, "instance_ids")
	require.Len(t, instanceIDs, 2, "Should create exactly 2 instances")

	// Verify both instances are running
	cfg := LoadAwsConfig(context.TODO(), GetRegionFromProfile())
	ec2Client := ec2.NewFromConfig(cfg)

	for _, instanceID := range instanceIDs {
		instResp, err := ec2Client.DescribeInstances(context.TODO(), &ec2.DescribeInstancesInput{
			InstanceIds: []string{instanceID},
		})
		require.NoError(t, err)
		require.NotEmpty(t, instResp.Reservations)
		require.NotEmpty(t, instResp.Reservations[0].Instances)

		instance := instResp.Reservations[0].Instances[0]
		assert.Contains(t, []ec2types.InstanceStateName{
			ec2types.InstanceStateNamePending,
			ec2types.InstanceStateNameRunning,
		}, instance.State.Name, "Instance should be pending or running")
	}

	t.Logf("✅ Multiple instances deployment completed in %s", time.Since(start))
}

// TestEC2SecurityGroup tests security group creation and rules
func TestEC2SecurityGroup(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()

	extraVars := map[string]interface{}{
		"allowed_cidr_blocks":     []string{"10.0.0.0/8"},
		"allowed_ssh_cidr_blocks": []string{"10.10.0.0/16"},
	}

	opts := setupIntegrationTestOptions(extraVars)
	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	securityGroupID := terraform.Output(t, opts, "security_group_id")
	require.NotEmpty(t, securityGroupID)

	// Verify security group rules
	cfg := LoadAwsConfig(context.TODO(), GetRegionFromProfile())
	ec2Client := ec2.NewFromConfig(cfg)

	sgResp, err := ec2Client.DescribeSecurityGroups(context.TODO(), &ec2.DescribeSecurityGroupsInput{
		GroupIds: []string{securityGroupID},
	})
	require.NoError(t, err)
	require.Len(t, sgResp.SecurityGroups, 1)

	sg := sgResp.SecurityGroups[0]

	// Verify egress rules (should allow all outbound)
	assert.NotEmpty(t, sg.IpPermissionsEgress, "Should have egress rules")

	// Verify ingress rules include SSH
	hasSSHRule := false
	for _, rule := range sg.IpPermissions {
		if rule.FromPort != nil && *rule.FromPort == 22 {
			hasSSHRule = true
			break
		}
	}
	assert.True(t, hasSSHRule, "Security group should have SSH rule")

	t.Logf("✅ Security group validation completed in %s", time.Since(start))
}

// TestEC2IAMRole tests IAM role creation and permissions
func TestEC2IAMRole(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()

	opts := setupIntegrationTestOptions(nil)
	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	iamRoleName := terraform.Output(t, opts, "iam_role_name")
	require.NotEmpty(t, iamRoleName)

	// Verify IAM role exists and has SSM policy
	cfg := LoadAwsConfig(context.TODO(), GetRegionFromProfile())
	iamClient := iam.NewFromConfig(cfg)

	roleResp, err := iamClient.GetRole(context.TODO(), &iam.GetRoleInput{
		RoleName: aws.String(iamRoleName),
	})
	require.NoError(t, err)
	require.NotNil(t, roleResp.Role)

	// Check attached policies
	policiesResp, err := iamClient.ListAttachedRolePolicies(context.TODO(), &iam.ListAttachedRolePoliciesInput{
		RoleName: aws.String(iamRoleName),
	})
	require.NoError(t, err)

	// Verify SSM policy is attached
	hasSSMPolicy := false
	for _, policy := range policiesResp.AttachedPolicies {
		if strings.Contains(*policy.PolicyName, "SSM") {
			hasSSMPolicy = true
			break
		}
	}
	assert.True(t, hasSSMPolicy, "IAM role should have SSM policy attached")

	t.Logf("✅ IAM role validation completed in %s", time.Since(start))
}

// TestEC2InstanceMetadata tests IMDSv2 configuration
func TestEC2InstanceMetadata(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()

	opts := setupIntegrationTestOptions(nil)
	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	instanceIDs := terraform.OutputList(t, opts, "instance_ids")
	require.NotEmpty(t, instanceIDs)

	// Verify IMDSv2 is enforced
	cfg := LoadAwsConfig(context.TODO(), GetRegionFromProfile())
	ec2Client := ec2.NewFromConfig(cfg)

	instResp, err := ec2Client.DescribeInstances(context.TODO(), &ec2.DescribeInstancesInput{
		InstanceIds: []string{instanceIDs[0]},
	})
	require.NoError(t, err)
	require.NotEmpty(t, instResp.Reservations)

	instance := instResp.Reservations[0].Instances[0]
	require.NotNil(t, instance.MetadataOptions)
	assert.Equal(t, ec2types.HttpTokensStateRequired, instance.MetadataOptions.HttpTokens,
		"IMDSv2 should be required")

	t.Logf("✅ Instance metadata validation completed in %s", time.Since(start))
}

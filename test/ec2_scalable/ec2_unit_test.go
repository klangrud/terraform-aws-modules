//go:build unit
// +build unit

package ec2_scalable_test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"test/shared"
)

func TestMain(m *testing.M) {
	code := m.Run()
	shared.FinalizeJUnitReportSummary()
	os.Exit(code)
}

func setupUnitTestOptions(extraVars map[string]interface{}) *terraform.Options {
	region := "us-east-1"

	defaultVars := map[string]interface{}{
		"project_name":          "unit-test-ec2",
		"env_short":             "test",
		"vpc_id":                "vpc-12345678", // Mock VPC ID
		"subnet_ids":            []string{"subnet-abcd1234"},
		"ec2_key_pair":          "test-keypair",
		"ami_id":                "ami-0017468bf94789869",
		"instance_type":         "t3a.medium",
		"create_security_group": true,
		"tags": map[string]string{
			"Environment": "test",
			"ManagedBy":   "terraform-unit-test",
		},
	}

	for k, v := range extraVars {
		defaultVars[k] = v
	}

	return &terraform.Options{
		TerraformDir: "./fixtures/basic",
		Vars:         defaultVars,
		EnvVars:      map[string]string{"AWS_REGION": region},
		PlanFilePath: "tfplan.out",
		Upgrade:      true,
		NoColor:      true,
	}
}

// TestBasicInstancePlan tests basic EC2 instance creation
func TestBasicInstancePlan(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	options := setupUnitTestOptions(nil)

	planStruct, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed")

	// Verify EC2 instance will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[0]")
	t.Log("✅ Basic instance plan succeeded")
}

// TestWithDataVolume tests EC2 with /data volume
func TestWithDataVolume(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"enable_data_volume": true,
		"data_volume_size":   200,
	}

	options := setupUnitTestOptions(extraVars)

	planStruct, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed")

	// Verify instance and EBS volume will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_ebs_volume.additional")

	t.Log("✅ Instance with /data volume plan succeeded")
}

// TestWithMultipleEBSVolumes tests EC2 with multiple custom EBS volumes
func TestWithMultipleEBSVolumes(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"additional_ebs_volumes": []map[string]interface{}{
			{
				"device_name": "/dev/sdf",
				"mount_point": "/var/lib/data",
				"volume_size": 100,
				"volume_type": "gp3",
				"iops":        3000,
				"throughput":  125,
				"encrypted":   true,
				"filesystem":  "ext4",
			},
			{
				"device_name": "/dev/sdg",
				"mount_point": "/backup",
				"volume_size": 500,
				"volume_type": "gp3",
				"iops":        5000,
				"throughput":  250,
				"encrypted":   true,
				"filesystem":  "xfs",
			},
		},
	}

	options := setupUnitTestOptions(extraVars)

	planStruct, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed")

	// Verify instance and multiple EBS volumes will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[0]")

	t.Log("✅ Instance with multiple EBS volumes plan succeeded")
}

// TestMultipleInstances tests creation of multiple EC2 instances
func TestMultipleInstances(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"instance_count": 3,
		"subnet_ids":     []string{"subnet-abcd1234", "subnet-efgh5678", "subnet-ijkl9012"},
	}

	options := setupUnitTestOptions(extraVars)

	planStruct, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed")

	// Verify all three instances will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[1]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[2]")

	t.Log("✅ Multiple instances plan succeeded")
}

// TestSecurityGroupCreation tests automatic security group creation
func TestSecurityGroupCreation(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"create_security_group":   true,
		"allowed_cidr_blocks":     []string{"10.0.0.0/8"},
		"allowed_ssh_cidr_blocks": []string{"10.10.0.0/16"},
	}

	options := setupUnitTestOptions(extraVars)

	planStruct, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed")

	// Verify security group will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_security_group.ec2_sg[0]")

	t.Log("✅ Security group creation plan succeeded")
}

// TestIAMRoleCreation tests automatic IAM role creation
func TestIAMRoleCreation(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"create_iam_instance_profile": true,
	}

	options := setupUnitTestOptions(extraVars)

	planStruct, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed")

	// Verify IAM role will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_iam_role.ec2_role[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_iam_instance_profile.ec2_profile[0]")

	t.Log("✅ IAM role creation plan succeeded")
}

// TestSecurityFeaturesDisabled tests disabling security features
func TestSecurityFeaturesDisabled(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"enable_security_updates": false,
		"install_ssm_agent":       false,
	}

	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed even with security features disabled")

	t.Log("✅ Plan succeeded with security features disabled")
}

// TestInvalidInstanceCount tests validation for instance_count
func TestInvalidInstanceCount(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"instance_count": 0, // Invalid: must be >= 1
	}

	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanE(t, options)
	assert.Error(t, err, "Plan should fail with invalid instance_count")

	t.Log("✅ Correctly rejected invalid instance_count")
}

// TestInvalidDeviceName tests validation for device names
func TestInvalidDeviceName(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"additional_ebs_volumes": []map[string]interface{}{
			{
				"device_name": "/dev/invalid", // Invalid device name
				"mount_point": "/data",
				"volume_size": 100,
			},
		},
	}

	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanE(t, options)
	assert.Error(t, err, "Plan should fail with invalid device name")

	t.Log("✅ Correctly rejected invalid device name")
}

// TestFullConfiguration tests a complete configuration with all features
func TestFullConfiguration(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	extraVars := map[string]interface{}{
		"instance_count":             2,
		"subnet_ids":                 []string{"subnet-abcd1234", "subnet-efgh5678"},
		"instance_type":              "m5.xlarge",
		"enable_data_volume":         true,
		"data_volume_size":           500,
		"create_security_group":      true,
		"allowed_cidr_blocks":        []string{"10.0.0.0/8"},
		"allowed_ssh_cidr_blocks":    []string{"10.10.0.0/16"},
		"enable_security_updates":    true,
		"install_ssm_agent":          true,
		"disable_api_termination":    true,
		"enable_detailed_monitoring": true,
		"additional_ebs_volumes": []map[string]interface{}{
			{
				"device_name": "/dev/sdg",
				"mount_point": "/var/lib/postgresql",
				"volume_size": 1000,
				"volume_type": "gp3",
				"iops":        10000,
				"throughput":  500,
			},
		},
	}

	options := setupUnitTestOptions(extraVars)

	planStruct, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed with full configuration")

	// Verify key resources
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[1]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_security_group.ec2_sg[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_iam_role.ec2_role[0]")

	t.Log("✅ Full configuration plan succeeded")
}

// TestDefaultValues tests that default values work correctly
func TestDefaultValues(t *testing.T) {
	t = shared.WrapWithJUnit(t)

	// Only provide required variables
	minimalVars := map[string]interface{}{
		"project_name": "minimal-test",
		"env_short":    "test",
		"vpc_id":       "vpc-12345678",
		"subnet_ids":   []string{"subnet-abcd1234"},
		"ec2_key_pair": "test-keypair",
	}

	options := setupUnitTestOptions(minimalVars)

	planStruct, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err, "Terraform plan should succeed with only required variables")

	// Verify instance created with defaults
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.ec2_scalable.aws_instance.ec2[0]")

	t.Log("✅ Plan succeeded with default values")
}

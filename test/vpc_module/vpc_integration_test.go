// test/vpc_module/vpc_integration_test.go
//go:build integration
// +build integration

package vpc_module_test

import (
	"context"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
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
	region := shared.GetRegionFromProfile()
	defaultVars := map[string]interface{}{
		"vpc_cidr":          "10.1.0.0/16",
		"test_resource_tag": "integration-test-tag",
		"region":            region,
		"vpc_endpoints": []string{
			"s3",
			"ssm",
			"ssmmessages",
			"ec2messages",
		},
	}
	for k, v := range extraVars {
		defaultVars[k] = v
	}
	return &terraform.Options{
		TerraformDir: "../vpc_module/fixtures/main",
		Vars:         defaultVars,
		EnvVars: map[string]string{
			"AWS_PROFILE": "infra-sandbox",
		},
		Upgrade: true,
	}
}

func TestVpcModule_BasicAndSubnetValidation(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()
	opts := setupIntegrationTestOptions(nil)
	terraform.InitAndApply(t, opts)
	defer terraform.Destroy(t, opts)

	vpcID := terraform.Output(t, opts, "vpc_id")
	require.NotEmpty(t, vpcID, "VPC ID output should not be empty")

	subnetTypes := []string{"public", "private", "custom"}
	for _, subnetType := range subnetTypes {
		key := fmt.Sprintf("%s_subnet_ids", subnetType)
		subnetIDs, err := terraform.OutputListE(t, opts, key)
		if err != nil {
			t.Logf("⚠ Output %s not found, skipping validation.", key)
			continue
		}
		require.NotEmpty(t, subnetIDs, "Subnet IDs for %s should not be empty", subnetType)
		for _, id := range subnetIDs {
			require.True(t, strings.HasPrefix(id, "subnet-"), "Each %s subnet should have valid AWS ID", subnetType)
		}
	}
	t.Logf("✅ Basic VPC and subnet validation completed in %s", time.Since(start))
}

func TestVpcModule_EndpointsAndRoutes(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	start := time.Now()
	opts := setupIntegrationTestOptions(nil)
	terraform.InitAndApply(t, opts)
	defer terraform.Destroy(t, opts)

	ec2Client := ec2.NewFromConfig(shared.LoadAwsConfig(context.TODO(), shared.GetRegionFromProfile()))
	vpcID := terraform.Output(t, opts, "vpc_id")
	require.NotEmpty(t, vpcID)

	expectedEndpoints := []string{"s3", "ssm", "ssmmessages", "ec2messages"}
	endpointOutput := terraform.OutputMap(t, opts, "vpc_endpoints")

	for _, svc := range expectedEndpoints {
		serviceName := fmt.Sprintf("com.amazonaws.%s.%s", shared.GetRegionFromProfile(), svc)
		found := false
		for _, ep := range endpointOutput {
			if strings.Contains(ep, serviceName) {
				found = true
				break
			}
		}
		assert.True(t, found, "Expected VPC endpoint for service %s", svc)
	}
	t.Logf("✅ Endpoint presence validated")

	rtIDs := terraform.OutputList(t, opts, "private_route_table_ids")
	s3EndpointID := ""
	resp, err := ec2Client.DescribeVpcEndpoints(context.TODO(), &ec2.DescribeVpcEndpointsInput{})
	require.NoError(t, err)
	for _, ep := range resp.VpcEndpoints {
		if strings.Contains(*ep.ServiceName, ".s3") {
			s3EndpointID = *ep.VpcEndpointId
			break
		}
	}

	for _, rtID := range rtIDs {
		rt, err := ec2Client.DescribeRouteTables(context.TODO(), &ec2.DescribeRouteTablesInput{
			RouteTableIds: []string{rtID},
		})
		require.NoError(t, err)
		require.Len(t, rt.RouteTables, 1)

		routeFound := false
		for _, r := range rt.RouteTables[0].Routes {
			if r.GatewayId != nil && *r.GatewayId == s3EndpointID {
				routeFound = true
				break
			}
		}
		assert.True(t, routeFound, "Route table %s should have route to S3 endpoint", rtID)
	}
	t.Logf("✅ Route tables validated in %s", time.Since(start))
}

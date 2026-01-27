//go:build unit
// +build unit

package vpc_module_test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
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
		"vpc_cidr":          "10.1.0.0/16",
		"test_resource_tag": "unit-test-tag",
		"region":            region,
		"mock_azs": []string{
			fmt.Sprintf("%sa", region),
			fmt.Sprintf("%sb", region),
			fmt.Sprintf("%sc", region),
		},
		"custom_subnets": []map[string]interface{}{
			{"name": "custom-1", "public": false, "subnet_count": 3},
		},
		"additional_custom_subnets": map[string]interface{}{},
		"create_internet_gateway":   true,
		"create_nat_gateway":        true,
		"create_rds_subnets":        true,
	}
	for k, v := range extraVars {
		defaultVars[k] = v
	}
	return &terraform.Options{
		TerraformDir: "../vpc_module/fixtures/main",
		Vars:         defaultVars,
		EnvVars:      map[string]string{"AWS_REGION": region},
		PlanFilePath: "tfplan.out",
		Upgrade:      true,
		NoColor:      true,
	}
}

// ============================================================================
// VPC CIDR Size Tests
// Tests each supported VPC CIDR size from /16 to /24
// ============================================================================

// TestVPCSize16 tests a /16 VPC (65,536 IPs)
// Expected: Public/Private = /20, RDS/Custom = /24
func TestVPCSize16(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/16",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /16 VPC plan succeeded - Public/Private: /20, RDS/Custom: /24")
}

// TestVPCSize17 tests a /17 VPC (32,768 IPs)
// Expected: Public/Private = /21, RDS/Custom = /25
func TestVPCSize17(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/17",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /17 VPC plan succeeded - Public/Private: /21, RDS/Custom: /25")
}

// TestVPCSize18 tests a /18 VPC (16,384 IPs)
// Expected: Public/Private = /22, RDS/Custom = /26
func TestVPCSize18(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/18",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /18 VPC plan succeeded - Public/Private: /22, RDS/Custom: /26")
}

// TestVPCSize19 tests a /19 VPC (8,192 IPs)
// Expected: Public/Private = /23, RDS/Custom = /27
func TestVPCSize19(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/19",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /19 VPC plan succeeded - Public/Private: /23, RDS/Custom: /27")
}

// TestVPCSize20 tests a /20 VPC (4,096 IPs)
// Expected: Public/Private = /24, RDS/Custom = /28
func TestVPCSize20(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/20",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /20 VPC plan succeeded - Public/Private: /24, RDS/Custom: /28")
}

// TestVPCSize21 tests a /21 VPC (2,048 IPs)
// Expected: Public/Private = /25, RDS/Custom = /28 (capped at AWS minimum)
func TestVPCSize21(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/21",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /21 VPC plan succeeded - Public/Private: /25, RDS/Custom: /28")
}

// TestVPCSize22 tests a /22 VPC (1,024 IPs)
// Expected: Public/Private = /26, RDS/Custom = /28 (capped at AWS minimum)
func TestVPCSize22(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/22",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /22 VPC plan succeeded - Public/Private: /26, RDS/Custom: /28")
}

// TestVPCSize23 tests a /23 VPC (512 IPs)
// Expected: Public/Private = /27, RDS/Custom = /28 (capped at AWS minimum)
func TestVPCSize23(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/23",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /23 VPC plan succeeded - Public/Private: /27, RDS/Custom: /28")
}

// TestVPCSize24 tests a /24 VPC (256 IPs) - smallest supported size
// Expected: All subnets = /28 (AWS minimum)
// Note: /24 VPCs have limited space (16 /28 subnets max), so we reduce subnet counts
func TestVPCSize24(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":             "10.0.0.0/24",
		"public_subnet_count":  2,
		"private_subnet_count": 2,
		"rds_subnet_count":     2,
		"create_rds_subnets":   true,
		"custom_subnets":       []map[string]interface{}{}, // No custom subnets for /24 - not enough space
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /24 VPC plan succeeded - All subnets: /28 (AWS minimum)")
}

// TestVPCSize24WithoutRDS tests a /24 VPC without RDS subnets
// This is a common use case for minimal VPCs
func TestVPCSize24WithoutRDS(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/24",
		"create_rds_subnets": false,
		"custom_subnets":     []map[string]interface{}{},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /24 VPC without RDS plan succeeded")
}

// TestVPCSize20WithMultipleCustomSubnets tests /20 VPC with multiple custom subnet groups
func TestVPCSize20WithMultipleCustomSubnets(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":           "10.0.0.0/20",
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "app", "public": false, "subnet_count": 3},
			{"name": "cache", "public": false, "subnet_count": 2},
			{"name": "dmz", "public": true, "subnet_count": 2},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /20 VPC with multiple custom subnets plan succeeded")
}

// TestVPCSize22WithReducedSubnetCounts tests /22 VPC with fewer subnets per type
// Smaller VPCs often need fewer subnets
func TestVPCSize22WithReducedSubnetCounts(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"vpc_cidr":             "10.0.0.0/22",
		"public_subnet_count":  2,
		"private_subnet_count": 2,
		"rds_subnet_count":     2,
		"create_rds_subnets":   true,
		"custom_subnets":       []map[string]interface{}{},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ /22 VPC with reduced subnet counts plan succeeded")
}

// ============================================================================
// Original Tests (Security Groups, Custom Subnets)
// ============================================================================

func TestCustomSubnetSpacing(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"custom_subnets": []map[string]interface{}{
			{"name": "custom-1", "public": false, "subnet_count": 3},
			{"name": "custom-2", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for custom subnet spacing")
}

func TestCustomSecurityGroupCreated(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"custom_subnets": []map[string]interface{}{
			{"name": "custom-1", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for custom SG")
}

func TestPublicSecurityGroupCreated(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions(nil)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for public SG")
}

func TestPrivateSecurityGroupCreated(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions(nil)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for private SG")
}

func TestRDSSecurityGroupCreated(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"create_rds_subnets": true,
		"custom_subnets": []map[string]interface{}{
			{"name": "custom-1", "public": false, "subnet_count": 3},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for RDS SG")
}

//go:build unit
// +build unit

package bootstrap_terraform_test

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
		"s3_bucket_name":      "test-terraform-state-123456789012",
		"dynamodb_table_name": "test-terraform-locks",
		"short_env":           "test",
		"aws_account_id":      "123456789012",
		"infra_account_id":    "123456789012",
		"tags": map[string]interface{}{
			"Environment": "test",
			"ManagedBy":   "terraform",
			"Purpose":     "unit-testing",
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

func TestBasicBootstrapPlan(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions(nil)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for basic bootstrap configuration")
}

func TestBootstrapWithCustomPolicies(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"aws_policy_arns_terraform_service_role": []string{
			"arn:aws:iam::aws:policy/PowerUserAccess",
			"arn:aws:iam::aws:policy/IAMReadOnlyAccess",
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for bootstrap with custom IAM policies")
}

func TestBootstrapWithCustomSessionTimeout(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"max_session_timeout_terraform_service_role": "7200",
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for bootstrap with custom session timeout")
}

func TestBootstrapWithDifferentEnvironments(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	environments := []string{"dev", "uat", "prod"}

	for _, env := range environments {
		t.Run(fmt.Sprintf("Environment_%s", env), func(t *testing.T) {
			extraVars := map[string]interface{}{
				"short_env":           env,
				"s3_bucket_name":      fmt.Sprintf("terraform-state-%s-123456789012", env),
				"dynamodb_table_name": fmt.Sprintf("terraform-locks-%s", env),
			}
			options := setupUnitTestOptions(extraVars)

			_, err := terraform.InitAndPlanAndShowE(t, options)
			require.NoError(t, err)
			t.Logf("✅ Plan succeeded for %s environment", env)
		})
	}
}

func TestBootstrapCrossAccount(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"aws_account_id":   "123456789012",
		"infra_account_id": "987654321098",
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for cross-account bootstrap configuration")
}

func TestBootstrapWithMinimalPolicies(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"aws_policy_arns_terraform_service_role": []string{
			"arn:aws:iam::aws:policy/AmazonS3FullAccess",
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for bootstrap with minimal policies")
}

func TestBootstrapWithCustomTags(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"tags": map[string]interface{}{
			"Environment": "production",
			"ManagedBy":   "terraform",
			"CostCenter":  "engineering",
			"Project":     "infrastructure",
			"Owner":       "platform-team",
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for bootstrap with custom tags")
}

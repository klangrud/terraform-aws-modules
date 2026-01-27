//go:build unit
// +build unit

package iam_password_policy_test

import (
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
		"minimum_password_length":        14,
		"require_lowercase_characters":   true,
		"require_uppercase_characters":   true,
		"require_numbers":                true,
		"require_symbols":                true,
		"allow_users_to_change_password": true,
		"max_password_age":               90,
		"password_reuse_prevention":      24,
		"hard_expiry":                    false,
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

func TestBasicIAMPasswordPolicyPlan(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions(nil)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for basic IAM password policy configuration")
}

func TestIAMPasswordPolicyWithMinimumLength(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	lengths := []int{8, 14, 20, 24}

	for _, length := range lengths {
		t.Run("MinLength_"+string(rune('0'+length/10))+string(rune('0'+length%10)), func(t *testing.T) {
			extraVars := map[string]interface{}{
				"minimum_password_length": length,
			}
			options := setupUnitTestOptions(extraVars)

			_, err := terraform.InitAndPlanAndShowE(t, options)
			require.NoError(t, err)
			t.Logf("Plan succeeded for IAM password policy with minimum length %d", length)
		})
	}
}

func TestIAMPasswordPolicyWithNoExpiry(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"max_password_age": 0,
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for IAM password policy with no expiry")
}

func TestIAMPasswordPolicyWithHardExpiry(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"hard_expiry": true,
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for IAM password policy with hard expiry")
}

func TestIAMPasswordPolicyWithRelaxedRequirements(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"require_symbols":           false,
		"minimum_password_length":   8,
		"password_reuse_prevention": 5,
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for IAM password policy with relaxed requirements")
}

func TestIAMPasswordPolicyWithStrictRequirements(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"minimum_password_length":        20,
		"require_lowercase_characters":   true,
		"require_uppercase_characters":   true,
		"require_numbers":                true,
		"require_symbols":                true,
		"max_password_age":               60,
		"password_reuse_prevention":      24,
		"hard_expiry":                    true,
		"allow_users_to_change_password": true,
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for IAM password policy with strict requirements")
}

func TestIAMPasswordPolicyPreventUserChange(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"allow_users_to_change_password": false,
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for IAM password policy preventing user password changes")
}

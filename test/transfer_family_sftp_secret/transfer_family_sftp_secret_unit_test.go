//go:build unit
// +build unit

package transfer_family_sftp_secret_test

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
		"secret_name":         "s-test123/test-user",
		"role_arn":            "arn:aws:iam::123456789012:role/test-sftp-role",
		"home_directory":      "/test-bucket/uploads",
		"accepted_ip_network": "0.0.0.0/0",
		"password_rotation":   "initial",
		"password_length":     16,
		"description":         "SFTP user credentials for AWS Transfer Family",
		"tags": map[string]interface{}{
			"Environment": "test",
			"ManagedBy":   "terraform",
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

func TestBasicTransferFamilySFTPSecretPlan(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions(nil)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for basic Transfer Family SFTP secret configuration")
}

func TestTransferFamilySFTPSecretWithIPRestriction(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"accepted_ip_network": "203.0.113.0/24",
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for SFTP secret with IP restriction")
}

func TestTransferFamilySFTPSecretWithCustomPasswordLength(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	passwordLengths := []int{16, 24, 32}

	for _, length := range passwordLengths {
		t.Run(fmt.Sprintf("PasswordLength_%d", length), func(t *testing.T) {
			extraVars := map[string]interface{}{
				"password_length": length,
			}
			options := setupUnitTestOptions(extraVars)

			_, err := terraform.InitAndPlanAndShowE(t, options)
			require.NoError(t, err)
			t.Logf("Plan succeeded for SFTP secret with password length %d", length)
		})
	}
}

func TestTransferFamilySFTPSecretWithPasswordRotation(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"password_rotation": "2024-01-15",
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for SFTP secret with password rotation")
}

func TestTransferFamilySFTPSecretWithCustomDescription(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"description": "Partner SFTP credentials for data exchange",
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for SFTP secret with custom description")
}

func TestTransferFamilySFTPSecretWithCustomTags(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"tags": map[string]interface{}{
			"Environment": "production",
			"ManagedBy":   "terraform",
			"Partner":     "acme-corp",
			"CostCenter":  "data-engineering",
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for SFTP secret with custom tags")
}

func TestTransferFamilySFTPSecretWithDifferentUsers(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	users := []struct {
		secretName    string
		homeDirectory string
	}{
		{"s-abc123/partner-a", "/bucket/partner-a/uploads"},
		{"s-abc123/vendor-b", "/bucket/vendor-b/inbound"},
		{"s-def456/internal-user", "/internal-bucket/data"},
	}

	for _, user := range users {
		t.Run(fmt.Sprintf("User_%s", user.secretName), func(t *testing.T) {
			extraVars := map[string]interface{}{
				"secret_name":    user.secretName,
				"home_directory": user.homeDirectory,
			}
			options := setupUnitTestOptions(extraVars)

			_, err := terraform.InitAndPlanAndShowE(t, options)
			require.NoError(t, err)
			t.Logf("Plan succeeded for SFTP secret user %s", user.secretName)
		})
	}
}

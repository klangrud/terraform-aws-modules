//go:build unit
// +build unit

// Note: This module generates cloud-init user data.
// Complex variable values with multi-line content don't work well with terratest -var flags.
// Unit tests use terraform validate to check configuration syntax.

package ec2_user_data_test

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

func setupUnitTestOptions() *terraform.Options {
	return &terraform.Options{
		TerraformDir: "./fixtures/basic",
		Upgrade:      true,
		NoColor:      true,
	}
}

func TestBasicEC2UserDataValidation(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions()

	_, err := terraform.InitE(t, options)
	require.NoError(t, err)

	_, err = terraform.ValidateE(t, options)
	require.NoError(t, err)
	t.Log("Validation succeeded for EC2 user data configuration")
}

func TestEC2UserDataPlanWithDefaults(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := &terraform.Options{
		TerraformDir: "./fixtures/basic",
		Vars: map[string]interface{}{
			"custom_user_data": map[string]interface{}{},
		},
		PlanFilePath: "tfplan.out",
		Upgrade:      true,
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for EC2 user data with default configuration")
}

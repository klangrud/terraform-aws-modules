//go:build unit
// +build unit

// Note: This module uses aws_ecr_image data source which requires AWS API access.
// Unit tests use terraform validate instead of plan to avoid AWS API calls.
// Validate tests use fixture defaults since validate doesn't accept -var flags.

package container_automation_ecs_test

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

func TestBasicContainerAutomationECSValidation(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions()

	_, err := terraform.InitE(t, options)
	require.NoError(t, err)

	_, err = terraform.ValidateE(t, options)
	require.NoError(t, err)
	t.Log("Validation succeeded for container automation ECS configuration")
}

//go:build unit
// +build unit

// Note: The identity_provider module requires SAML metadata documents that are 1000+ characters.
// Unit tests use terraform validate to check configuration syntax without AWS validation constraints.

package identity_provider_test

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

func TestBasicIdentityProviderValidation(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions()

	_, err := terraform.InitE(t, options)
	require.NoError(t, err)

	_, err = terraform.ValidateE(t, options)
	require.NoError(t, err)
	t.Log("Validation succeeded for identity provider configuration")
}

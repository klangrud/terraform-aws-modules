//go:build unit
// +build unit

package elastic_container_registry_test

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
		"aws_ecr_repository_name": "test-ecr-repo",
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

func TestBasicECRRepositoryPlan(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions(nil)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for basic ECR repository configuration")
}

func TestECRRepositoryWithCustomName(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"aws_ecr_repository_name": "my-application-repo",
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for ECR repository with custom name")
}

func TestECRRepositoryWithDifferentNames(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	repoNames := []string{"frontend-app", "backend-api", "worker-service", "data-processor"}

	for _, name := range repoNames {
		t.Run(fmt.Sprintf("Repo_%s", name), func(t *testing.T) {
			extraVars := map[string]interface{}{
				"aws_ecr_repository_name": name,
			}
			options := setupUnitTestOptions(extraVars)

			_, err := terraform.InitAndPlanAndShowE(t, options)
			require.NoError(t, err)
			t.Logf("Plan succeeded for ECR repository %s", name)
		})
	}
}

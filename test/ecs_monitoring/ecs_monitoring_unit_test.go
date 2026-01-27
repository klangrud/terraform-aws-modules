//go:build unit
// +build unit

package ecs_monitoring_test

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
		"ecs_cluster_name":          "test-cluster",
		"ecs_service_name":          "test-service",
		"cpu_threshold":             80,
		"cpu_evaluation_periods":    2,
		"memory_threshold":          80,
		"memory_evaluation_periods": 2,
		"error_threshold":           5,
		"error_evaluation_periods":  2,
		"metric_period":             300,
		"sns_topic_name":            "test-ecs-monitoring-alerts",
		"sns_subscriptions":         []interface{}{},
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

func TestBasicECSMonitoringPlan(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	options := setupUnitTestOptions(nil)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for basic ECS monitoring configuration")
}

func TestECSMonitoringWithCustomThresholds(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"cpu_threshold":    90,
		"memory_threshold": 85,
		"error_threshold":  10,
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for ECS monitoring with custom thresholds")
}

func TestECSMonitoringWithCustomEvaluationPeriods(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"cpu_evaluation_periods":    5,
		"memory_evaluation_periods": 5,
		"error_evaluation_periods":  3,
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for ECS monitoring with custom evaluation periods")
}

func TestECSMonitoringWithSNSSubscriptions(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"sns_subscriptions": []interface{}{
			map[string]interface{}{
				"protocol": "email",
				"endpoint": "oncall@example.com",
			},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for ECS monitoring with SNS subscriptions")
}

func TestECSMonitoringWithMultipleSNSSubscriptions(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"sns_subscriptions": []interface{}{
			map[string]interface{}{
				"protocol": "email",
				"endpoint": "primary@example.com",
			},
			map[string]interface{}{
				"protocol": "email",
				"endpoint": "secondary@example.com",
			},
			map[string]interface{}{
				"protocol": "sms",
				"endpoint": "+15551234567",
			},
		},
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for ECS monitoring with multiple SNS subscriptions")
}

func TestECSMonitoringWithCustomMetricPeriod(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	periods := []int{60, 120, 300, 600}

	for _, period := range periods {
		t.Run(fmt.Sprintf("Period_%d", period), func(t *testing.T) {
			extraVars := map[string]interface{}{
				"metric_period": period,
			}
			options := setupUnitTestOptions(extraVars)

			_, err := terraform.InitAndPlanAndShowE(t, options)
			require.NoError(t, err)
			t.Logf("Plan succeeded for ECS monitoring with metric period %d", period)
		})
	}
}

func TestECSMonitoringWithDifferentServices(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	services := []struct {
		cluster string
		service string
	}{
		{"production-cluster", "api-service"},
		{"production-cluster", "worker-service"},
		{"staging-cluster", "frontend-service"},
	}

	for _, svc := range services {
		t.Run(fmt.Sprintf("Cluster_%s_Service_%s", svc.cluster, svc.service), func(t *testing.T) {
			extraVars := map[string]interface{}{
				"ecs_cluster_name": svc.cluster,
				"ecs_service_name": svc.service,
				"sns_topic_name":   fmt.Sprintf("%s-%s-alerts", svc.cluster, svc.service),
			}
			options := setupUnitTestOptions(extraVars)

			_, err := terraform.InitAndPlanAndShowE(t, options)
			require.NoError(t, err)
			t.Logf("Plan succeeded for ECS monitoring cluster %s service %s", svc.cluster, svc.service)
		})
	}
}

func TestECSMonitoringWithLowThresholds(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	extraVars := map[string]interface{}{
		"cpu_threshold":    50,
		"memory_threshold": 60,
		"error_threshold":  1,
	}
	options := setupUnitTestOptions(extraVars)

	_, err := terraform.InitAndPlanAndShowE(t, options)
	require.NoError(t, err)
	t.Log("Plan succeeded for ECS monitoring with low thresholds (sensitive alerting)")
}

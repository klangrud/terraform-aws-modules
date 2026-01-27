//go:build unit
// +build unit

package s3_bucket_replication_test

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
	defaultVars := map[string]interface{}{
		"source_bucket_name":      "test-source-bucket",
		"destination_bucket_name": "test-dest-bucket",
		"source_account_id":       "123456789012",
		"destination_account_id":  "123456789012",
		"tags": map[string]string{
			"Environment": "unit-test",
			"ManagedBy":   "terratest",
		},
	}
	for k, v := range extraVars {
		defaultVars[k] = v
	}

	return &terraform.Options{
		TerraformDir: "./fixtures/basic",
		Vars:         defaultVars,
		PlanFilePath: "tfplan.out",
		Upgrade:      true,
		NoColor:      true,
	}
}

// Test 1: Create both buckets (neither exists)
func TestCreateBothBuckets(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"source_bucket_exists":      false,
		"destination_bucket_exists": false,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for creating both buckets")
}

// Test 2: Existing source, new destination
func TestExistingSourceNewDestination(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"source_bucket_exists":      true,
		"destination_bucket_exists": false,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for existing source, new destination")
}

// Test 3: New source, existing destination
func TestNewSourceExistingDestination(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"source_bucket_exists":      false,
		"destination_bucket_exists": true,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for new source, existing destination")
}

// Test 4: Both buckets exist (configure replication only)
func TestBothBucketsExist(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"source_bucket_exists":      true,
		"destination_bucket_exists": true,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for both buckets existing")
}

// Test 5: Bidirectional replication
func TestBidirectionalReplication(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"enable_bidirectional": true,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for bidirectional replication")
}

// Test 6: Use existing IAM role
func TestExistingIAMRole(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"source_replication_role_arn": "arn:aws:iam::123456789012:role/existing-role",
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded with existing IAM role")
}

// Test 7: Cross-account replication
func TestCrossAccountReplication(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"source_account_id":      "111111111111",
		"destination_account_id": "222222222222",
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for cross-account replication")
}

// Test 8: Custom prefix filters
func TestCustomPrefixFilters(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"replication_rules": []map[string]interface{}{
			{"prefix": "data/"},
		},
		"reverse_replication_rules": []map[string]interface{}{
			{"prefix": "backups/"},
		},
		"enable_bidirectional": true,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded with custom prefix filters")
}

// Test 11: Multiple prefix filters
func TestMultiplePrefixFilters(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"replication_rules": []map[string]interface{}{
			{"prefix": "data/"},
			{"prefix": "logs/"},
			{"prefix": "archives/"},
		},
		"enable_bidirectional": false,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded with multiple prefix filters")
}

// Test 12: Bidirectional with multiple prefixes
func TestBidirectionalMultiplePrefixes(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"replication_rules": []map[string]interface{}{
			{"prefix": "to-dest/data/"},
			{"prefix": "to-dest/logs/"},
		},
		"reverse_replication_rules": []map[string]interface{}{
			{"prefix": "to-source/data/"},
			{"prefix": "to-source/logs/"},
		},
		"enable_bidirectional": true,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded with bidirectional multiple prefixes")
}

// Test 13: Per-rule delete marker replication
func TestPerRuleDeleteMarker(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"replication_rules": []map[string]interface{}{
			{
				"prefix":                    "data/",
				"delete_marker_replication": true,
			},
			{
				"prefix":                    "logs/",
				"delete_marker_replication": false,
			},
		},
		"enable_bidirectional": false,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded with per-rule delete marker settings")
}

// Test 14: Per-rule storage class
func TestPerRuleStorageClass(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"replication_rules": []map[string]interface{}{
			{
				"prefix":        "data/",
				"storage_class": "STANDARD",
			},
			{
				"prefix":        "archives/",
				"storage_class": "GLACIER",
			},
		},
		"enable_bidirectional": false,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded with per-rule storage class")
}

// Test 9: Bidirectional with existing roles
func TestBidirectionalWithExistingRoles(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"enable_bidirectional":              true,
		"source_replication_role_arn":       "arn:aws:iam::123456789012:role/source-role",
		"destination_replication_role_arn":  "arn:aws:iam::123456789012:role/dest-role",
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for bidirectional with existing roles")
}

// Test 10: Cross-account bidirectional
func TestCrossAccountBidirectional(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupUnitTestOptions(map[string]interface{}{
		"source_account_id":      "111111111111",
		"destination_account_id": "222222222222",
		"enable_bidirectional":   true,
	})

	_, err := terraform.InitAndPlanAndShowE(t, opts)
	require.NoError(t, err)
	t.Log("✅ Plan succeeded for cross-account bidirectional replication")
}

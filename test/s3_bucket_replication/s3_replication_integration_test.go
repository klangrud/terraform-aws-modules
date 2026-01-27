//go:build integration
// +build integration

package s3_bucket_replication_test

import (
	"context"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"test/shared"
)

const awsProfile = "infra-sandbox"

func setupIntegrationTestOptions(extraVars map[string]interface{}) *terraform.Options {
	timestamp := time.Now().Unix()
	defaultVars := map[string]interface{}{
		"source_bucket_name":      fmt.Sprintf("test-source-%d", timestamp),
		"destination_bucket_name": fmt.Sprintf("test-dest-%d", timestamp),
		"source_account_id":       "YOUR_ACCOUNT_ID", // Your AWS account
		"destination_account_id":  "987654321098",
		"tags": map[string]string{
			"Environment": "integration-test",
			"ManagedBy":   "terratest",
			"Timestamp":   fmt.Sprintf("%d", timestamp),
		},
	}
	for k, v := range extraVars {
		defaultVars[k] = v
	}

	return &terraform.Options{
		TerraformDir: "./fixtures/basic",
		Vars:         defaultVars,
		EnvVars: map[string]string{
			"AWS_PROFILE": awsProfile,
		},
		Upgrade: true,
		NoColor: true,
	}
}

// Test 1: End-to-end unidirectional replication
func TestE2EUnidirectionalReplication(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupIntegrationTestOptions(nil)

	terraform.InitAndApply(t, opts)
	defer terraform.Destroy(t, opts)

	// Verify buckets created
	sourceBucket := terraform.Output(t, opts, "source_bucket_name")
	destBucket := terraform.Output(t, opts, "destination_bucket_name")
	require.NotEmpty(t, sourceBucket)
	require.NotEmpty(t, destBucket)

	// Verify replication configuration exists
	cfg := loadAwsConfig(t)
	s3Client := s3.NewFromConfig(cfg)

	replicationResp, err := s3Client.GetBucketReplication(context.TODO(), &s3.GetBucketReplicationInput{
		Bucket: aws.String(sourceBucket),
	})
	require.NoError(t, err)
	require.NotNil(t, replicationResp.ReplicationConfiguration)
	assert.Len(t, replicationResp.ReplicationConfiguration.Rules, 1)
	assert.Equal(t, "Enabled", string(replicationResp.ReplicationConfiguration.Rules[0].Status))

	t.Log("✅ Unidirectional replication configured successfully")
}

// Test 2: End-to-end bidirectional replication
func TestE2EBidirectionalReplication(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupIntegrationTestOptions(map[string]interface{}{
		"enable_bidirectional": true,
	})

	terraform.InitAndApply(t, opts)
	defer terraform.Destroy(t, opts)

	sourceBucket := terraform.Output(t, opts, "source_bucket_name")
	destBucket := terraform.Output(t, opts, "destination_bucket_name")

	cfg := loadAwsConfig(t)
	s3Client := s3.NewFromConfig(cfg)

	// Verify source → destination replication
	sourceReplication, err := s3Client.GetBucketReplication(context.TODO(), &s3.GetBucketReplicationInput{
		Bucket: aws.String(sourceBucket),
	})
	require.NoError(t, err)
	assert.Len(t, sourceReplication.ReplicationConfiguration.Rules, 1)
	assert.Equal(t, "source-to-destination", *sourceReplication.ReplicationConfiguration.Rules[0].ID)

	// Verify destination → source replication
	destReplication, err := s3Client.GetBucketReplication(context.TODO(), &s3.GetBucketReplicationInput{
		Bucket: aws.String(destBucket),
	})
	require.NoError(t, err)
	assert.Len(t, destReplication.ReplicationConfiguration.Rules, 1)
	assert.Equal(t, "destination-to-source", *destReplication.ReplicationConfiguration.Rules[0].ID)

	t.Log("✅ Bidirectional replication configured successfully")
}

// Test 3: Object replication verification
func TestObjectReplication(t *testing.T) {
	t = shared.WrapWithJUnit(t)
	opts := setupIntegrationTestOptions(nil)

	terraform.InitAndApply(t, opts)
	defer terraform.Destroy(t, opts)

	sourceBucket := terraform.Output(t, opts, "source_bucket_name")
	destBucket := terraform.Output(t, opts, "destination_bucket_name")

	cfg := loadAwsConfig(t)
	s3Client := s3.NewFromConfig(cfg)

	// Upload test object to source
	testKey := "test-replication.txt"
	testContent := "test content for replication"

	_, err := s3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(sourceBucket),
		Key:    aws.String(testKey),
		Body:   strings.NewReader(testContent),
	})
	require.NoError(t, err)
	t.Logf("✅ Uploaded test object to source bucket: %s", sourceBucket)

	// Wait for replication (up to 5 minutes with polling)
	maxWaitTime := 5 * time.Minute
	pollInterval := 30 * time.Second
	deadline := time.Now().Add(maxWaitTime)

	t.Logf("⏳ Waiting for replication (max %v)...", maxWaitTime)

	var replicated bool
	for time.Now().Before(deadline) {
		_, err = s3Client.HeadObject(context.TODO(), &s3.HeadObjectInput{
			Bucket: aws.String(destBucket),
			Key:    aws.String(testKey),
		})
		if err == nil {
			replicated = true
			break
		}

		t.Logf("Object not yet replicated, waiting %v before next check...", pollInterval)
		time.Sleep(pollInterval)
	}

	require.True(t, replicated, "Object was not replicated within %v", maxWaitTime)
	t.Log("✅ Object successfully replicated")
}

func loadAwsConfig(t *testing.T) aws.Config {
	cfg, err := awsconfig.LoadDefaultConfig(
		context.TODO(),
		awsconfig.WithSharedConfigProfile(awsProfile),
	)
	require.NoError(t, err)
	return cfg
}

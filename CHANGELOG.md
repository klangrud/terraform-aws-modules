# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v1.0.0] - 2026-01-07

### Added
- Initial release of Terraform Modules repository
- 22 production-ready Terraform modules for AWS infrastructure
- Comprehensive 8-stage CI/CD pipeline:
  - Lint: Terraform formatting and TFLint validation
  - Security: tfsec and Checkov compliance scanning
  - Validate: Terraform validation and provider version checking
  - Docs: terraform-docs automated documentation
  - Unit: Go-based Terratest unit testing
  - Integration: Manual and nightly integration tests
  - Report: Test summary and cleanup
  - Release: Automated semantic versioning and release management
- Pre-commit hooks for local development
- Module documentation with terraform-docs automation

### Modules Included
- **Compute**: ec2_scalable, container_automation_ecs
- **Networking**: vpc_module, ec2_user_data
- **Storage**: s3_bucket, standard_s3_bucket, s3_bucket_with_dr_backup, s3_bucket_replication
- **Security**: iam_roles, identity_provider, secure-sftp-account, transfer_user, transfer_family_sftp_secret
- **Monitoring**: ecs_monitoring, alerts_sns_topic
- **Foundation**: bootstrap, elastic_container_registry, maintenance_page, tableau-reporting-stack, transfer_webapp

[Unreleased]: https://github.com/klangrud/terraform-aws-modules/compare/v1.0.0...HEAD
[v1.0.0]: https://github.com/klangrud/terraform-aws-modules/releases/v1.0.0

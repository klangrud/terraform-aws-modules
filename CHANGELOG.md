# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.0.1] - 2026-01-27

### Added
- Initial release of Terraform AWS Modules repository
- 13 production-ready Terraform modules for AWS infrastructure
- CI/CD pipeline with GitHub Actions:
  - Lint: Terraform formatting validation
  - Validate: Terraform validation
  - Unit: Go-based Terratest unit testing
  - Integration: AWS infrastructure integration tests
  - Release: Automated semantic versioning and release management
- Pre-commit hooks for local development
- Comprehensive documentation

### Modules Included
- **Networking**: vpc_module (supports VPC CIDR /16 to /24)
- **Compute**: ec2_scalable, ec2_user_data, container_automation_ecs, elastic_container_registry, ecs_monitoring
- **Storage**: s3_bucket, s3_bucket_replication
- **Security**: identity_provider, iam_password_policy, transfer_family_sftp_secret
- **Monitoring**: alerts_sns_topic
- **Foundation**: bootstrap_terraform

[Unreleased]: https://github.com/klangrud/terraform-aws-modules/compare/v0.0.1...HEAD
[v0.0.1]: https://github.com/klangrud/terraform-aws-modules/releases/tag/v0.0.1

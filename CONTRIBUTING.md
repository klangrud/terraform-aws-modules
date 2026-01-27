# Contributing to Terraform Modules

Thank you for contributing to the Terraform Modules repository! This guide will help you understand our development workflow and commit conventions.

## Table of Contents

- [Commit Message Format](#commit-message-format)
- [Commit Types](#commit-types)
- [Semantic Versioning](#semantic-versioning)
- [Development Workflow](#development-workflow)
- [Module Development](#module-development)
- [Testing](#testing)

## Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. All commit messages must follow this format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Required Elements

- **type**: The type of change (see [Commit Types](#commit-types))
- **subject**: A brief description of the change (imperative mood, lowercase, no period)

### Optional Elements

- **scope**: The module or component affected (e.g., `s3_bucket`, `vpc_module`, `ci`)
- **body**: A longer description providing context and motivation
- **footer**: Breaking change notes or issue references

### Examples

**Feature (MINOR version bump)**
```
feat(s3_bucket): add cross-region replication support

Added new variables to enable cross-region replication
for disaster recovery scenarios. This includes support
for existing buckets and new bucket creation.

Closes #42
```

**Bug Fix (PATCH version bump)**
```
fix(vpc_module): correct NAT gateway count calculation

The module was creating extra NAT gateways when multi-AZ
was disabled. Fixed conditional logic in main.tf.

Fixes #156
```

**Breaking Change (MAJOR version bump)**
```
refactor(iam_roles)!: remove deprecated assume role policy

BREAKING CHANGE: The deprecated `assume_role_policy_json`
variable has been removed. Use `policy_json` variable instead.

Migration guide:
  Old: assume_role_policy_json = "..."
  New: policy_json = "..."
```

**Documentation**
```
docs: update README with cross-account examples

Added examples for cross-account module usage and
updated provider configuration documentation.
```

**CI/CD Changes**
```
ci: add automated release workflow

Implemented semantic versioning automation with:
- Conventional commit validation
- Automatic version tagging
- CHANGELOG generation
- Teams notifications
```

## Commit Types

| Type       | Description                              | Version Bump |
|------------|------------------------------------------|--------------|
| `feat`     | New feature                              | MINOR        |
| `fix`      | Bug fix                                  | PATCH        |
| `docs`     | Documentation changes                    | PATCH        |
| `style`    | Formatting, missing semicolons, etc.     | PATCH        |
| `refactor` | Code restructuring (no functional change)| PATCH        |
| `perf`     | Performance improvements                 | PATCH        |
| `test`     | Adding or updating tests                 | PATCH        |
| `build`    | Build system or dependency changes       | PATCH        |
| `ci`       | CI/CD pipeline changes                   | PATCH        |
| `chore`    | Maintenance tasks                        | PATCH        |
| `revert`   | Revert previous commit                   | PATCH        |

### Breaking Changes

Breaking changes trigger a MAJOR version bump. There are two ways to indicate a breaking change:

1. **Exclamation mark in subject:**
   ```
   refactor(api)!: change response format
   ```

2. **BREAKING CHANGE footer:**
   ```
   feat(api): add new endpoint

   BREAKING CHANGE: The /users endpoint now returns paginated results.
   Update your API clients to handle pagination.
   ```

## Semantic Versioning

This repository follows [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR** (v1.0.0 → v2.0.0): Breaking changes
- **MINOR** (v1.0.0 → v1.1.0): New features (backward compatible)
- **PATCH** (v1.0.0 → v1.0.1): Bug fixes (backward compatible)

### Version Bump Priority

When multiple commit types are present in a merge, the highest priority determines the version bump:

1. **BREAKING CHANGE** → MAJOR bump
2. **feat** → MINOR bump
3. **fix, perf, other** → PATCH bump

Example: A merge with both `feat` and `fix` commits results in a MINOR bump.

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feat/add-replication-support
```

Branch naming conventions:
- `feat/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `refactor/description` - Code refactoring
- `ci/description` - CI/CD changes

### 2. Make Changes with Conventional Commits

```bash
# Make your changes
git add .

# Commit with conventional format
git commit -m "feat(s3_bucket): add replication variables"
```

**Tips:**
- Keep commits atomic (one logical change per commit)
- Write clear, descriptive commit messages
- Reference issues in commit body or footer

### 3. Pre-commit Validation (Optional)

Install pre-commit hooks for local validation:

```bash
pre-commit install
```

This will validate commit messages before they're committed locally.

### 4. Push and Create Merge Request

```bash
git push origin feat/add-replication-support
```

Create a pull request on GitHub. The CI pipeline will:
- ✅ Validate all commit messages follow conventional format
- ✅ Run terraform fmt check
- ✅ Run TFLint
- ✅ Run security scanning (tfsec, Checkov)
- ✅ Validate Terraform configuration
- ✅ Check documentation
- ✅ Run unit tests
- ✅ Run integration tests (if triggered)

### 5. Address Review Feedback

If you need to amend your commit message:

```bash
# Amend the last commit
git commit --amend -m "feat(s3_bucket): add cross-region replication"

# Force push (use with caution)
git push --force-with-lease
```

### 6. Merge to Main

Once approved, merge your MR. The CI pipeline will automatically:
1. Calculate the next semantic version based on commit types
2. Create and push a git tag (e.g., `v1.2.0`)

### 7. Create a Release (Manual)

When ready to publish a release:
1. Go to GitHub → CI/CD → Pipelines
2. Find the pipeline for the main branch
3. Click the "play" button on the `create-release` job
4. This will:
   - Generate/update CHANGELOG.md
   - Create a GitHub release with changelog notes
   - Send a Teams notification (if configured)

## Module Development

### Module Structure

Every module should follow this structure:

```
modules/{module-name}/
├── README.md              # Auto-generated with terraform-docs
├── terraform.tf           # Provider and version constraints
├── variables.tf           # Input variables
├── outputs.tf             # Output values
├── main.tf                # Primary resources
├── data.tf                # Data sources (optional)
├── locals.tf              # Local values (optional)
└── *.tf                   # Additional resource files
```

### Module Documentation

All modules must have:
- Variable descriptions
- Output descriptions
- README.md with usage examples (auto-generated)

### Module Testing

Unit tests are required for all modules:

```bash
# Run unit tests for specific module
./run-tests.sh unit s3_bucket

# Run integration tests (requires AWS credentials)
AWS_PROFILE=infra-sandbox ./run-tests.sh integration s3_bucket
```

## Testing

### Local Testing

Before pushing commits:

```bash
# Format Terraform code
terraform fmt -recursive

# Run TFLint
tflint --init
tflint --recursive

# Validate conventional commits locally (if pre-commit installed)
pre-commit run --all-files
```

### CI Pipeline Stages

1. **Lint**: Format checking, TFLint, commit validation
2. **Security**: tfsec (AWS), Checkov (HIPAA/HITRUST)
3. **Validate**: Terraform validation, provider version check
4. **Docs**: terraform-docs validation
5. **Unit**: Go-based Terratest unit tests
6. **Integration**: Manual or nightly integration tests
7. **Report**: Test summary and cleanup
8. **Release**: Automated versioning and release management

## Common Mistakes

### ❌ Invalid Commit Messages

```bash
# Missing type
git commit -m "add new feature"

# Wrong format
git commit -m "Add: new feature"

# Capitalized subject
git commit -m "feat: Add new feature"

# Period at end
git commit -m "feat: add new feature."
```

### ✅ Valid Commit Messages

```bash
# Simple feature
git commit -m "feat: add new feature"

# With scope
git commit -m "feat(s3_bucket): add new feature"

# With body
git commit -m "feat: add new feature

Detailed explanation of what this feature does
and why it's needed."

# Breaking change
git commit -m "feat!: add new feature with breaking change"
```

## Getting Help

- **Documentation**: See README.md in each module
- **Issues**: Create an issue on GitHub
- **Questions**: Ask in #infrastructure Teams channel

## Additional Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terratest Documentation](https://terratest.gruntwork.io/)

---

Thank you for contributing to Terraform Modules! 🚀

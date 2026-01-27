#!/bin/bash

##################################################
# Terraform Modules Test Runner
# Usage: ./run-tests.sh [unit|integration|all|cleanup]
##################################################

set -e

TEST_TYPE=${1:-all}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$SCRIPT_DIR/test"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

##################################################
# Ensure dependencies are installed
##################################################

check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v go &> /dev/null; then
        log_error "Go is not installed. Please install Go 1.21 or later."
        exit 1
    fi

    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform 1.6 or later."
        exit 1
    fi

    log_success "Dependencies check passed"
}

##################################################
# Setup test environment
##################################################

setup_test_env() {
    log_info "Setting up test environment..."

    cd "$TEST_DIR"

    # Ensure go.mod exists
    if [ ! -f "go.mod" ]; then
        log_error "go.mod not found in $TEST_DIR"
        exit 1
    fi

    # Download Go dependencies
    log_info "Downloading Go dependencies..."
    go mod download
    go mod tidy

    log_success "Test environment setup complete"
}

##################################################
# Discover test modules
##################################################

discover_modules() {
    log_info "Discovering test modules..."

    MODULES=$(find "$TEST_DIR" -mindepth 1 -maxdepth 1 -type d -not -path '*/shared' -exec basename {} \; | sort)

    if [ -z "$MODULES" ]; then
        log_warning "No test modules found"
        exit 0
    fi

    log_info "Found test modules:"
    for module in $MODULES; do
        echo "  - $module"
    done
}

##################################################
# Run unit tests
##################################################

run_unit_tests() {
    log_info "Running unit tests..."

    cd "$TEST_DIR"
    local exit_code=0

    for module in $MODULES; do
        if [ ! -d "$module" ]; then
            continue
        fi

        log_info "Running unit tests for $module..."

        # Check if module has unit tests
        if ! grep -r "//go:build unit" "$module" > /dev/null 2>&1; then
            log_warning "No unit tests found in $module"
            continue
        fi

        # Run unit tests with verbose output
        if go test -v -tags=unit "./$module/..." -timeout 10m; then
            log_success "Unit tests passed for $module"
        else
            log_error "Unit tests failed for $module"
            exit_code=1
        fi

        echo ""
    done

    return $exit_code
}

##################################################
# Run integration tests
##################################################

run_integration_tests() {
    log_info "Running integration tests..."
    log_warning "This will create REAL AWS resources!"

    # Check for AWS credentials
    if [ -z "$AWS_PROFILE" ] && [ -z "$AWS_ACCESS_KEY_ID" ]; then
        log_error "AWS credentials not configured. Set AWS_PROFILE or AWS_ACCESS_KEY_ID."
        log_info "Example: AWS_PROFILE=infra-sandbox ./run-tests.sh integration"
        exit 1
    fi

    cd "$TEST_DIR"
    local exit_code=0

    for module in $MODULES; do
        if [ ! -d "$module" ]; then
            continue
        fi

        log_info "Running integration tests for $module..."

        # Check if module has integration tests
        if ! grep -r "//go:build integration" "$module" > /dev/null 2>&1; then
            log_warning "No integration tests found in $module"
            continue
        fi

        # Run integration tests with longer timeout
        if go test -v -tags=integration "./$module/..." -timeout 30m; then
            log_success "Integration tests passed for $module"
        else
            log_error "Integration tests failed for $module"
            exit_code=1
        fi

        echo ""
    done

    return $exit_code
}

##################################################
# Run all tests
##################################################

run_all_tests() {
    log_info "Running all tests (unit + integration)..."

    local exit_code=0

    if ! run_unit_tests; then
        exit_code=1
    fi

    if ! run_integration_tests; then
        exit_code=1
    fi

    return $exit_code
}

##################################################
# Cleanup test resources
##################################################

cleanup_resources() {
    log_info "Cleaning up test resources..."

    # Remove .terraform directories
    find "$TEST_DIR" -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true

    # Remove .terraform.lock.hcl files
    find "$TEST_DIR" -type f -name ".terraform.lock.hcl" -exec rm -f {} + 2>/dev/null || true

    # Remove terraform state files from test fixtures
    find "$TEST_DIR" -type f -name "terraform.tfstate*" -exec rm -f {} + 2>/dev/null || true

    # Remove test cache
    go clean -testcache 2>/dev/null || true

    log_success "Cleanup complete"
}

##################################################
# Display usage
##################################################

usage() {
    cat << EOF
Terraform Modules Test Runner

Usage:
    ./run-tests.sh [command]

Commands:
    unit          Run unit tests only (fast, no AWS resources)
    integration   Run integration tests (requires AWS credentials, creates resources)
    all           Run both unit and integration tests (default)
    cleanup       Clean up test artifacts and Terraform state

Examples:
    ./run-tests.sh unit
    AWS_PROFILE=infra-sandbox ./run-tests.sh integration
    ./run-tests.sh cleanup

Environment Variables:
    AWS_PROFILE            AWS profile to use for integration tests
    AWS_ACCESS_KEY_ID      AWS access key (alternative to profile)
    AWS_SECRET_ACCESS_KEY  AWS secret key (required with access key)

EOF
}

##################################################
# Main execution
##################################################

main() {
    echo ""
    log_info "Terraform Modules Test Runner"
    echo ""

    check_dependencies

    case "$TEST_TYPE" in
        unit)
            setup_test_env
            discover_modules
            run_unit_tests
            exit $?
            ;;
        integration)
            setup_test_env
            discover_modules
            run_integration_tests
            exit $?
            ;;
        all)
            setup_test_env
            discover_modules
            run_all_tests
            exit $?
            ;;
        cleanup)
            cleanup_resources
            exit 0
            ;;
        help|--help|-h)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown command: $TEST_TYPE"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main

# Deployment Guide

Learn how to deploy your Salesforce application using the automated CI/CD pipeline.

## Overview

This template includes a GitHub Actions workflow that:

- ✅ Validates code on every pull request
- ✅ Runs automated tests (LWC Jest + Apex)
- ✅ Creates and validates scratch orgs
- ✅ Reports code coverage to CodeCov
- ✅ Ensures code quality before merging

## GitHub Actions Workflow

### Workflow File

The CI/CD pipeline is defined in [`.github/workflows/ci.yml`](https://github.com/beyond-the-cloud-dev/template/blob/main/.github/workflows/ci.yml)

### Trigger Events

The workflow runs on:

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

- **Pull Requests**: Validates changes before merging
- **Pushes to main**: Ensures main branch is always healthy

### Workflow Steps

1. **Checkout Code**: Gets the latest code from repository
2. **Setup Node.js**: Installs Node.js 20
3. **Install Dependencies**: Runs `npm ci`
4. **Authenticate with Dev Hub**: Uses `SFDX_AUTH_URL_DEVHUB` secret
5. **Create Scratch Org**: Temporary org for testing
6. **Deploy Source**: Pushes metadata to scratch org
7. **Run Apex Tests**: Executes all Apex tests
8. **Run LWC Jest Tests**: Runs component tests
9. **Upload Coverage**: Sends coverage to CodeCov
10. **Cleanup**: Deletes scratch org

## Required Secrets

### Setting Up Secrets

Navigate to your GitHub repository:

1. Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add the following secrets:

### 1. SFDX_AUTH_URL_DEVHUB

**Purpose**: Authenticates with your Dev Hub org

**How to get it**:

```bash
# Authenticate with your Dev Hub
sf org login web -d -a DevHub

# Get the auth URL
sf org display --verbose -o DevHub | grep "Sfdx Auth Url"
```

Copy the entire `force://` URL and save it as a secret.

**Alternative method**:

```bash
# Generate auth URL to file
sf org display --verbose -o DevHub --json > auth.json

# Extract "sfdxAuthUrl" from the JSON file
# Copy the value and save as secret
# Delete auth.json after copying (contains sensitive data!)
```

### 2. CODECOV_TOKEN (Optional)

**Purpose**: Uploads code coverage to CodeCov

**How to get it**:

1. Go to [codecov.io](https://codecov.io)
2. Sign in with GitHub
3. Add your repository
4. Copy the upload token
5. Add as secret in GitHub

**Note**: CodeCov is optional. Remove the upload step from workflow if not using.

## Local Deployment

### Deploy to Scratch Org

```bash
# Create scratch org
sf org create scratch -f config/project-scratch-def.json -a dev -d 30

# Deploy source
sf project deploy start -o dev

# Run tests
sf apex run test --test-level RunLocalTests -o dev

# Open org
sf org open -o dev
```

### Deploy to Sandbox

```bash
# Authenticate with sandbox
sf org login web -a MySandbox

# Deploy source
sf project deploy start -o MySandbox

# Run tests
sf apex run test --test-level RunLocalTests -o MySandbox

# Validate deployment (without deploying)
sf project deploy validate -o MySandbox
```

### Deploy to Production

```bash
# Authenticate with production
sf org login web -a Production

# Validate deployment with all tests
sf project deploy validate --test-level RunLocalTests -o Production

# If validation succeeds, deploy
sf project deploy start --test-level RunLocalTests -o Production
```

**Production Deployment Checklist**:

- ✅ All tests passing
- ✅ Code coverage >75%
- ✅ Validated in sandbox
- ✅ Change set documented
- ✅ Rollback plan ready

## Continuous Integration Best Practices

### Branch Protection Rules

Recommended settings for main branch:

1. **Navigate to**: Settings → Branches → Add rule
2. **Branch name pattern**: `main`
3. **Enable**:
   - ✅ Require pull request before merging
   - ✅ Require approvals (1+)
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - ✅ Include administrators

### Pull Request Workflow

1. **Create feature branch**

   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes and commit**

   ```bash
   git add .
   git commit -m "Add new feature"
   ```

3. **Push to GitHub**

   ```bash
   git push origin feature/my-feature
   ```

4. **Create Pull Request**
   - Go to GitHub repository
   - Click "Pull requests" → "New pull request"
   - Select your feature branch
   - Add description
   - Create pull request

5. **CI/CD runs automatically**
   - GitHub Actions workflow starts
   - All checks must pass
   - Review code coverage report

6. **Review and Merge**
   - Request code review
   - Address feedback
   - Merge when approved and checks pass

## Customizing the Workflow

### Modify Test Level

Edit `.github/workflows/ci.yml`:

```yaml
# Current (runs local tests only)
- name: Run Apex Tests
  run: sf apex run test --test-level RunLocalTests

# Run all tests (including managed packages)
- name: Run Apex Tests
  run: sf apex run test --test-level RunAllTestsInOrg
```

### Add Deployment Step

Add to workflow for automatic deployment:

```yaml
- name: Deploy to Integration Org
  if: github.ref == 'refs/heads/main'
  run: |
    sf org login sfdx-url --sfdx-url-file=INTEGRATION_AUTH_URL
    sf project deploy start
```

### Skip Tests for Documentation

```yaml
on:
  push:
    branches: [main]
    paths-ignore:
      - "website/**"
      - "**.md"
      - "docs/**"
```

## Monitoring and Debugging

### View Workflow Runs

1. Go to repository on GitHub
2. Click "Actions" tab
3. View all workflow runs
4. Click specific run for details

### Debugging Failed Workflows

1. **Check logs**:
   - Click failed workflow
   - Expand failed step
   - Read error messages

2. **Common issues**:
   - Authentication failure → Check `SFDX_AUTH_URL_DEVHUB` secret
   - Test failures → Run tests locally
   - Deployment errors → Check metadata format

3. **Re-run workflow**:
   - Click "Re-run failed jobs"
   - Or push new commit with fixes

### Code Coverage

View coverage reports:

- **CodeCov**: Visit your repository on codecov.io
- **GitHub PR**: Coverage comment appears on PRs
- **Locally**: `npm run test:unit:coverage`

## Advanced Configuration

### Multiple Environments

Set up different environments:

```yaml
jobs:
  deploy-dev:
    # Deploy to dev environment

  deploy-uat:
    needs: deploy-dev
    # Deploy to UAT after dev

  deploy-prod:
    needs: deploy-uat
    if: github.ref == 'refs/heads/main'
    # Deploy to prod after UAT
```

### Scheduled Workflows

Run tests on schedule:

```yaml
on:
  schedule:
    - cron: "0 0 * * *" # Daily at midnight
```

### Manual Workflow Dispatch

Allow manual triggers:

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Environment to deploy to"
        required: true
        type: choice
        options:
          - dev
          - uat
          - prod
```

## Deployment Checklist

Before deploying to production:

- [ ] All tests passing locally
- [ ] Code reviewed by team member
- [ ] CI/CD pipeline green
- [ ] Code coverage ≥75%
- [ ] Tested in sandbox environment
- [ ] Documentation updated
- [ ] Release notes prepared
- [ ] Stakeholders notified
- [ ] Rollback plan documented
- [ ] Production backup taken

## Next Steps

- [Testing Guide](/guide/testing) - Learn about testing
- [Development Guide](/guide/development) - Development workflow
- [Best Practices](/examples/best-practices) - Deployment best practices

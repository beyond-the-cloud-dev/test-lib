<div align="center">
  <a href="https://beyond-the-cloud-dev.github.io/template/">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="./website/public/logo-round.png">
      <img alt="Salesforce Template logo" src="./website/public/logo-round.png" height="98">
    </picture>
  </a>
  <h1>Salesforce Template</h1>

<a href="https://beyondthecloud.dev"><img alt="Beyond The Cloud logo" src="https://img.shields.io/badge/MADE_BY_BEYOND_THE_CLOUD-555?style=for-the-badge"></a>
<a><img alt="API version" src="https://img.shields.io/badge/api-v65.0-blue?style=for-the-badge"></a>
<a href="https://github.com/beyond-the-cloud-dev/template/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-mit-green?style=for-the-badge"></a>

[![CI](https://github.com/beyond-the-cloud-dev/template/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/beyond-the-cloud-dev/template/actions/workflows/ci.yml)
[![Deploy Docs](https://github.com/beyond-the-cloud-dev/template/actions/workflows/deploy-docs.yml/badge.svg?branch=main)](https://github.com/beyond-the-cloud-dev/template/actions/workflows/deploy-docs.yml)

</div>

# Getting Started

Professional Salesforce development template with CI/CD, testing, and best practices.

This template is part of the Beyond the Cloud ecosystem, providing production-ready tools for Salesforce development.

For comprehensive documentation, visit [https://beyond-the-cloud-dev.github.io/template/](https://beyond-the-cloud-dev.github.io/template/)

## Features

- **Salesforce DX Project Structure** - Modern SFDX project layout with package-based development
- **GitHub Actions CI/CD** - Automated testing and deployment workflows
- **LWC Jest Testing** - Comprehensive testing setup with CodeCov integration
- **Code Quality Tools** - ESLint, Prettier, Husky pre-commit hooks
- **Comprehensive Documentation** - VitePress-based documentation site

## Quick Start

```bash
# Clone the template
git clone https://github.com/beyond-the-cloud-dev/template.git my-salesforce-project
cd my-salesforce-project

# Install dependencies
npm install

# Authenticate with Dev Hub
sf org login web -d -a DevHub

# Create scratch org
sf org create scratch -f config/project-scratch-def.json -a my-scratch-org -d 30

# Deploy source
sf project deploy start -o my-scratch-org

# Run tests
npm test
```

## Deploy to Salesforce

<a href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=template&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Documentation

📚 **Full documentation**: [https://beyond-the-cloud-dev.github.io/template/](https://beyond-the-cloud-dev.github.io/template/)

### Documentation Sections

- **[Getting Started](https://beyond-the-cloud-dev.github.io/template/guide/getting-started)** - Set up your development environment
- **[Development Guide](https://beyond-the-cloud-dev.github.io/template/guide/development)** - Development workflow and commands
- **[Testing Guide](https://beyond-the-cloud-dev.github.io/template/guide/testing)** - Testing framework and best practices
- **[Deployment Guide](https://beyond-the-cloud-dev.github.io/template/guide/deployment)** - CI/CD and deployment process
- **[API Reference](https://beyond-the-cloud-dev.github.io/template/api/lwc)** - LWC and Apex documentation
- **[Code Examples](https://beyond-the-cloud-dev.github.io/template/examples/)** - Practical code patterns

### Run Documentation Locally

```bash
# Run documentation locally
npm run docs:dev

# Build documentation
npm run docs:build

# Preview built documentation
npm run docs:preview
```

## Project Structure

```
.
├── force-app/              # Salesforce metadata
│   └── main/default/
│       ├── lwc/            # Lightning Web Components
│       ├── aura/           # Aura components
│       ├── classes/        # Apex classes
│       └── ...             # Other metadata
├── config/                 # Salesforce configurations
│   └── project-scratch-def.json
├── website/                # VitePress documentation
│   ├── .vitepress/
│   ├── guide/
│   ├── api/
│   └── examples/
├── .github/workflows/      # CI/CD workflows
│   ├── ci.yml             # Salesforce CI/CD
│   └── deploy-docs.yml    # Documentation deployment
├── package.json            # npm dependencies and scripts
└── sfdx-project.json      # SFDX project configuration
```

## Using This Template

After cloning this repository, see [TODO.md](TODO.md) for a checklist of customizations needed for your project.

## Available Scripts

### Salesforce

```bash
# Create scratch org
sf org create scratch -f config/project-scratch-def.json -a dev

# Deploy source
sf project deploy start

# Run Apex tests
sf apex run test --test-level RunLocalTests
```

### Testing

```bash
npm test                    # Run all LWC Jest tests
npm run test:unit:watch     # Watch mode
npm run test:unit:debug     # Debug mode
npm run test:unit:coverage  # Generate coverage report
```

### Code Quality

```bash
npm run lint                # Lint LWC and Aura components
npm run prettier            # Format all files
npm run prettier:verify     # Check formatting
```

## CI/CD

This template includes two GitHub Actions workflows:

### Salesforce CI/CD

Runs on every push and pull request:

- Creates scratch org
- Deploys source
- Runs Apex tests
- Runs LWC Jest tests
- Uploads coverage to CodeCov

### Documentation Deployment

Automatically deploys documentation to GitHub Pages when changes are pushed to `website/` folder.

### Required Secrets

Add these secrets in GitHub repository settings:

- `SFDX_AUTH_URL_DEVHUB` - Dev Hub authentication URL
- `CODECOV_TOKEN` - CodeCov upload token (optional)

See [Deployment Guide](https://beyond-the-cloud-dev.github.io/template/guide/deployment) for detailed instructions.

## What's Included

### Tooling

- **Salesforce CLI** - Modern Salesforce development
- **LWC Jest** - Lightning Web Component testing
- **ESLint** - Code quality for LWC/Aura
- **Prettier** - Code formatting
- **Husky** - Git hooks
- **lint-staged** - Run checks on staged files
- **VitePress** - Documentation site generator

### Configuration

- Scratch org definition
- ESLint rules for LWC/Aura
- Prettier configuration
- Pre-commit hooks
- GitHub Actions workflows
- Test coverage reporting

### Documentation

- Getting Started guide
- Development workflow
- Testing guide
- Deployment guide
- API reference templates
- Code examples
- Best practices

## Contributors

<a href="https://github.com/beyond-the-cloud-dev/template/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=beyond-the-cloud-dev/template" />
</a>

## License

MIT License

Copyright © 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)

See [LICENSE](LICENSE) file for details.

## License Notes

- For proper license management each repository should contain LICENSE file similar to this one.
- Each original class should contain copyright mark: © Copyright 2025, Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)

## About Beyond The Cloud

This template is maintained by [Beyond The Cloud](https://beyondthecloud.dev) - experts in Salesforce development and DevOps.

**Connect with us:**

- Website: [beyondthecloud.dev](https://beyondthecloud.dev)
- LinkedIn: [Beyond The Cloud](https://www.linkedin.com/company/beyondtheclouddev)
- GitHub: [@beyond-the-cloud-dev](https://github.com/beyond-the-cloud-dev)

## Support

- **Documentation**: [Full documentation](https://beyond-the-cloud-dev.github.io/template/)
- **Issues**: [GitHub Issues](https://github.com/beyond-the-cloud-dev/template/issues)
- **Discussions**: [GitHub Discussions](https://github.com/beyond-the-cloud-dev/template/discussions)

---

**Note:** This is a template repository. After cloning, customize it for your project by following the [TODO.md](TODO.md) checklist.

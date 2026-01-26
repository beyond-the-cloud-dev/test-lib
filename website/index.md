---
layout: home

hero:
  name: "Salesforce Template"
  text: "Beyond The Cloud"
  tagline: Professional Salesforce development with CI/CD, testing, and best practices
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: View on GitHub
      link: https://github.com/beyond-the-cloud-dev/template

features:
  - icon: 🚀
    title: Production Ready
    details: Enterprise-grade template with CI/CD, automated testing, and deployment workflows configured out of the box.

  - icon: 🧪
    title: Comprehensive Testing
    details: LWC Jest testing setup with coverage reports, integrated with CodeCov for continuous quality monitoring.

  - icon: 📦
    title: Modern Tooling
    details: ESLint, Prettier, Husky hooks, and lint-staged configured for consistent code quality.

  - icon: 🔄
    title: GitHub Actions
    details: Automated CI/CD pipeline with Salesforce DX, scratch org validation, and deployment automation.

  - icon: 📚
    title: Best Practices
    details: Following Salesforce and community best practices for scalable, maintainable code.

  - icon: ⚡
    title: Lightning Web Components
    details: Modern LWC development with proper structure, testing, and documentation.
---

## Quick Start

```bash
# Clone the template
git clone https://github.com/beyond-the-cloud-dev/template.git

# Install dependencies
npm install

# Authenticate with Dev Hub
sf org login web -d -a DevHub

# Create scratch org
sf org create scratch -f config/project-scratch-def.json -a my-scratch-org

# Deploy source
sf project deploy start

# Run tests
npm test
```

## What's Included

- **Salesforce DX Project Structure**: Modern SFDX project layout
- **CI/CD Pipeline**: GitHub Actions workflow for automated testing and deployment
- **Testing Framework**: LWC Jest with coverage reporting
- **Code Quality Tools**: ESLint, Prettier, Husky pre-commit hooks
- **Documentation**: Comprehensive guides and API documentation

## Beyond The Cloud

This template is maintained by [Beyond The Cloud](https://beyondthecloud.dev) - experts in Salesforce development and DevOps.

**License:** MIT
**Copyright:** © 2025 Beyond The Cloud Sp. z o.o.

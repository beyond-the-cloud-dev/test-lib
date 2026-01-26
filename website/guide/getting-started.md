# Getting Started

Welcome to the Salesforce Template! This guide will help you get up and running quickly.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** 20 or higher - [Download](https://nodejs.org/)
- **Salesforce CLI** (latest version) - [Installation Guide](https://developer.salesforce.com/tools/sfdxcli)
- **Git** - [Download](https://git-scm.com/)
- **Dev Hub Enabled** - Access to a Salesforce org with Dev Hub enabled

## Installation

### 1. Clone the Template

```bash
git clone https://github.com/beyond-the-cloud-dev/template.git my-salesforce-project
cd my-salesforce-project
```

### 2. Install Dependencies

```bash
npm install
```

This will install all required npm packages including:

- Salesforce CLI plugins
- LWC Jest testing framework
- ESLint and Prettier
- Husky for git hooks

### 3. Authenticate with Dev Hub

```bash
sf org login web -d -a DevHub
```

This command will:

- Open your browser
- Prompt you to log in to your Dev Hub org
- Set the org as your default Dev Hub

### 4. Create a Scratch Org

```bash
sf org create scratch -f config/project-scratch-def.json -a my-scratch-org -d 30
```

Parameters:

- `-f`: Path to scratch org definition file
- `-a`: Alias for the scratch org
- `-d`: Duration in days (1-30)

### 5. Deploy Source to Scratch Org

```bash
sf project deploy start -o my-scratch-org
```

### 6. Open Your Scratch Org

```bash
sf org open -o my-scratch-org
```

## Verify Installation

### Run Tests

```bash
npm test
```

You should see LWC Jest tests run successfully.

### Run Linting

```bash
npm run lint
```

This checks your code for any ESLint issues.

### Format Code

```bash
npm run prettier
```

This formats all files according to Prettier rules.

## Project Structure

```
.
├── force-app/              # Salesforce metadata
│   └── main/default/
│       ├── aura/           # Aura components
│       ├── lwc/            # Lightning Web Components
│       ├── classes/        # Apex classes
│       └── ...             # Other metadata
├── config/                 # Salesforce configurations
│   └── project-scratch-def.json
├── .github/workflows/      # CI/CD workflows
│   └── ci.yml             # Main CI workflow
├── website/                # Documentation (VitePress)
├── package.json            # npm dependencies and scripts
└── sfdx-project.json      # SFDX project configuration
```

## Development Workflow

1. **Create a feature branch**

   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes**
   - Add/modify LWC components in `force-app/main/default/lwc/`
   - Add/modify Apex classes in `force-app/main/default/classes/`
   - Write tests for your changes

3. **Test your changes**

   ```bash
   npm test
   sf project deploy start -o my-scratch-org
   ```

4. **Commit your changes**

   ```bash
   git add .
   git commit -m "Description of changes"
   ```

   Pre-commit hooks will automatically:
   - Format your code with Prettier
   - Run ESLint on changed files

5. **Push and create a pull request**
   ```bash
   git push origin feature/my-new-feature
   ```

## Next Steps

- [Development Guide](/guide/development) - Learn about development commands and best practices
- [Testing Guide](/guide/testing) - Understand the testing framework
- [Deployment Guide](/guide/deployment) - Set up CI/CD for your project

## Troubleshooting

### Authentication Issues

If you encounter authentication errors:

```bash
# Logout and re-authenticate
sf org logout --all
sf org login web -d -a DevHub
```

### Scratch Org Creation Fails

Check your Dev Hub limits:

```bash
sf org list limits -o DevHub
```

You may need to delete unused scratch orgs:

```bash
sf org delete scratch -o old-scratch-org
```

### npm Install Errors

Clear npm cache and reinstall:

```bash
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

## Need Help?

- **GitHub Issues**: [Report a bug or request a feature](https://github.com/beyond-the-cloud-dev/template/issues)
- **Documentation**: Browse the full documentation
- **Beyond The Cloud**: Visit [beyondthecloud.dev](https://beyondthecloud.dev)

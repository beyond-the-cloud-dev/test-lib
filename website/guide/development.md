# Development Guide

Learn how to develop efficiently with this template.

## Project Structure

### Salesforce Metadata

```
force-app/main/default/
├── aura/                   # Aura components
├── lwc/                    # Lightning Web Components
│   ├── myComponent/
│   │   ├── myComponent.html
│   │   ├── myComponent.js
│   │   ├── myComponent.css
│   │   ├── myComponent.js-meta.xml
│   │   └── __tests__/
│   │       └── myComponent.test.js
├── classes/                # Apex classes
├── triggers/               # Apex triggers
├── objects/                # Custom objects
├── tabs/                   # Custom tabs
└── ...                     # Other metadata types
```

## Development Commands

### Salesforce CLI Commands

#### Org Management

```bash
# Create scratch org
sf org create scratch -f config/project-scratch-def.json -a dev -d 30

# List all orgs
sf org list

# Open scratch org
sf org open -o dev

# Delete scratch org
sf org delete scratch -o dev
```

#### Source Deployment

```bash
# Deploy all source
sf project deploy start

# Deploy specific directory
sf project deploy start -d force-app/main/default/lwc

# Deploy to specific org
sf project deploy start -o my-scratch-org
```

#### Source Retrieval

```bash
# Retrieve all source
sf project retrieve start

# Retrieve specific metadata
sf project retrieve start -m ApexClass

# Retrieve specific component
sf project retrieve start -m LightningComponentBundle:myComponent
```

#### Running Apex Tests

```bash
# Run all tests
sf apex run test --test-level RunLocalTests

# Run specific test class
sf apex run test --tests MyTestClass

# Run with code coverage
sf apex run test --test-level RunLocalTests --code-coverage
```

### npm Scripts

```bash
# Linting
npm run lint                # Lint LWC and Aura components

# Testing
npm test                    # Run all LWC Jest tests
npm run test:unit:watch     # Watch mode for tests
npm run test:unit:debug     # Debug tests
npm run test:unit:coverage  # Generate coverage report

# Code Formatting
npm run prettier            # Format all files
npm run prettier:verify     # Check formatting without changes

# Documentation
npm run docs:dev            # Run documentation locally
npm run docs:build          # Build documentation
npm run docs:preview        # Preview built documentation
```

## Code Quality

### Pre-commit Hooks

Husky runs automatically before each commit:

1. **Prettier** formats changed files
2. **ESLint** validates LWC/Aura code
3. Changes are staged automatically

### Manual Quality Checks

```bash
# Format all files
npm run prettier

# Check formatting (without making changes)
npm run prettier:verify

# Lint code
npm run lint
```

## Best Practices

### Lightning Web Components

#### Component Structure

Always include tests for your components:

```
lwc/myComponent/
├── myComponent.html         # Template
├── myComponent.js           # JavaScript
├── myComponent.css          # Styles
├── myComponent.js-meta.xml  # Metadata
└── __tests__/
    └── myComponent.test.js  # Tests
```

#### Naming Conventions

- Use **camelCase** for component names
- Be descriptive and action-oriented
- Good examples:
  - `accountSearchForm`
  - `contactListDisplay`
  - `opportunityEditModal`

#### Component Best Practices

1. **Keep components small and focused**
   - Single responsibility principle
   - Easier to test and maintain

2. **Use proper lifecycle hooks**

   ```javascript
   import { LightningElement } from "lwc";

   export default class MyComponent extends LightningElement {
     connectedCallback() {
       // Component connected to DOM
     }

     renderedCallback() {
       // Component finished rendering
     }

     disconnectedCallback() {
       // Component removed from DOM
     }
   }
   ```

3. **Handle errors gracefully**
   ```javascript
   handleSave() {
     saveRecord({ record: this.record })
       .then(() => {
         this.showToast('Success', 'Record saved', 'success');
       })
       .catch((error) => {
         this.showToast('Error', error.body.message, 'error');
       });
   }
   ```

### Apex Classes

#### Class Structure

```apex
/**
 * @description Service class for Account operations
 * @author Beyond The Cloud
 * @date 2025
 */
public with sharing class AccountService {
    /**
     * @description Retrieves active accounts
     * @param limit Maximum number of records to return
     * @return List of active accounts
     */
    public static List<Account> getActiveAccounts(Integer limit) {
        return [
            SELECT Id, Name, Industry
            FROM Account
            WHERE IsActive__c = true
            LIMIT :limit
        ];
    }
}
```

#### Naming Conventions

- **PascalCase** for class names
- Descriptive, purpose-driven names
- Common suffixes:
  - `Service`: Business logic (e.g., `AccountService`)
  - `Controller`: LWC controllers (e.g., `AccountSearchController`)
  - `Helper`: Helper methods (e.g., `DateHelper`)
  - `Selector`: SOQL queries (e.g., `AccountSelector`)
  - `Test`: Test classes (e.g., `AccountServiceTest`)

#### Apex Best Practices

1. **Bulkify your code**

   ```apex
   // Good - Bulkified
   public static void updateAccounts(List<Account> accounts) {
       for (Account acc : accounts) {
           acc.LastModifiedDate__c = System.now();
       }
       update accounts;
   }

   // Bad - Not bulkified
   public static void updateAccount(Account acc) {
       acc.LastModifiedDate__c = System.now();
       update acc; // DML inside loop is bad
   }
   ```

2. **Use proper sharing keywords**
   - `with sharing`: Enforce user's sharing rules
   - `without sharing`: Bypass sharing rules (use carefully)
   - `inherited sharing`: Inherit from caller

3. **Avoid SOQL in loops**

   ```apex
   // Good
   Map<Id, Account> accountMap = new Map<Id, Account>(
       [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
   );

   // Bad
   for (Id accountId : accountIds) {
       Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId];
   }
   ```

## Debugging

### LWC Debugging

Use browser DevTools:

```javascript
// In component JavaScript
console.log("Debug data:", this.data);
console.table(this.records);
debugger; // Set breakpoint
```

Enable debug mode:

1. Setup → Users → Select user
2. Check "Debug Mode"

### Apex Debugging

#### Debug Logs

```bash
# Start tailing logs
sf apex tail log

# Get specific log
sf apex get log --log-id <logId>
```

#### Debug Statements

```apex
System.debug('Variable value: ' + myVariable);
System.debug(LoggingLevel.ERROR, 'Error occurred: ' + errorMessage);
```

## Configuration Files

### sfdx-project.json

Main project configuration:

```json
{
  "packageDirectories": [
    {
      "path": "force-app",
      "default": true,
      "package": "Package Name Lib",
      "versionName": "ver 1.0.0",
      "versionNumber": "1.0.0.NEXT"
    }
  ],
  "namespace": "btcdev",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "65.0"
}
```

### config/project-scratch-def.json

Scratch org definition:

```json
{
  "orgName": "Beyond The Cloud Dev",
  "edition": "Developer",
  "features": ["EnableSetPasswordInApi"],
  "settings": {
    "lightningExperienceSettings": {
      "enableS1DesktopEnabled": true
    }
  }
}
```

## Next Steps

- [Testing Guide](/guide/testing) - Learn about testing your code
- [Deployment Guide](/guide/deployment) - Set up CI/CD
- [Code Examples](/examples/) - See practical examples

# Best Practices

Essential best practices for Salesforce development with this template.

## Code Quality

### General Principles

1. **Write Clean, Readable Code**
   - Use meaningful variable and method names
   - Keep methods short and focused
   - Add comments for complex logic
   - Follow consistent formatting

2. **DRY (Don't Repeat Yourself)**
   - Extract reusable logic into helper methods
   - Create utility classes for common operations
   - Use inheritance and composition wisely

3. **SOLID Principles**
   - Single Responsibility: One class, one purpose
   - Open/Closed: Open for extension, closed for modification
   - Liskov Substitution: Subtypes must be substitutable
   - Interface Segregation: Many specific interfaces
   - Dependency Inversion: Depend on abstractions

## Lightning Web Components

### Component Design

**Good:**

```javascript
// Small, focused component
export default class AccountName extends LightningElement {
  @api recordId;

  @wire(getRecord, { recordId: "$recordId", fields: ["Account.Name"] })
  account;

  get accountName() {
    return this.account.data?.fields.Name.value;
  }
}
```

**Bad:**

```javascript
// Too many responsibilities
export default class AccountEverything extends LightningElement {
  // Handles display, editing, deleting, related records, etc.
  // 500+ lines of code
}
```

### Property Naming

**Good:**

```javascript
export default class MyComponent extends LightningElement {
  @api recordId; // Public API
  selectedItem; // Private property
  isLoading = false; // Boolean with 'is' prefix
  errorMessage; // Clear naming
}
```

**Bad:**

```javascript
export default class MyComponent extends LightningElement {
  @api rid; // Unclear abbreviation
  item; // Too generic
  loading; // Missing 'is' prefix
  err; // Unclear abbreviation
}
```

### Error Handling

**Good:**

```javascript
async loadData() {
    this.isLoading = true;
    this.error = undefined;

    try {
        this.data = await getData({ recordId: this.recordId });
    } catch (error) {
        this.error = this.normalizeError(error);
        this.showToast('Error', this.error.message, 'error');
    } finally {
        this.isLoading = false;
    }
}

normalizeError(error) {
    if (error.body?.message) {
        return { message: error.body.message };
    }
    return { message: 'An unexpected error occurred' };
}
```

**Bad:**

```javascript
async loadData() {
    this.data = await getData({ recordId: this.recordId });
    // No error handling, no loading state
}
```

### Reactive Properties

**Good:**

```javascript
export default class AccountDisplay extends LightningElement {
  @track filters = {
    industry: "",
    minRevenue: 0,
  };

  handleIndustryChange(event) {
    // Triggers reactivity by creating new object
    this.filters = {
      ...this.filters,
      industry: event.target.value,
    };
  }
}
```

**Bad:**

```javascript
export default class AccountDisplay extends LightningElement {
  @track filters = {
    industry: "",
    minRevenue: 0,
  };

  handleIndustryChange(event) {
    // Mutation doesn't trigger reactivity
    this.filters.industry = event.target.value;
  }
}
```

## Apex Best Practices

### Bulkification

**Good:**

```apex
public class AccountService {
    public static void updateIndustries(List<Account> accounts, String industry) {
        for (Account acc : accounts) {
            acc.Industry = industry;
        }
        update accounts; // Single DML
    }
}
```

**Bad:**

```apex
public class AccountService {
    public static void updateIndustries(List<Account> accounts, String industry) {
        for (Account acc : accounts) {
            acc.Industry = industry;
            update acc; // DML in loop - NEVER DO THIS
        }
    }
}
```

### SOQL Best Practices

**Good:**

```apex
public static List<Account> getAccountsWithContacts(Set<Id> accountIds) {
    // Single query with relationship
    return [
        SELECT Id, Name,
               (SELECT Id, Name FROM Contacts)
        FROM Account
        WHERE Id IN :accountIds
    ];
}
```

**Bad:**

```apex
public static List<Account> getAccountsWithContacts(Set<Id> accountIds) {
    List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];

    for (Account acc : accounts) {
        // SOQL in loop - NEVER DO THIS
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
        // Can't assign to relationship anyway
    }

    return accounts;
}
```

### Sharing and Security

**Good:**

```apex
// Explicitly declare sharing
public with sharing class AccountService {
    public static List<Account> getAccounts() {
        // Respects user's sharing rules
        return [SELECT Id, Name FROM Account];
    }
}

// Use without sharing only when necessary
public without sharing class SystemAccountService {
    // Used for system-level operations only
    public static List<Account> getAllAccountsSystemMode() {
        return [SELECT Id, Name FROM Account];
    }
}
```

**Bad:**

```apex
// No sharing declaration - inherited from caller (unclear)
public class AccountService {
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account];
    }
}
```

### Field-Level Security

**Good:**

```apex
public with sharing class AccountController {
    @AuraEnabled
    public static List<Account> getAccounts() {
        // Check FLS
        if (!Schema.sObjectType.Account.fields.AnnualRevenue.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions');
        }

        return [
            SELECT Id, Name, AnnualRevenue
            FROM Account
            LIMIT 10
        ];
    }
}
```

**Alternative: Use Security.stripInaccessible**

```apex
public with sharing class AccountController {
    @AuraEnabled
    public static List<Account> getAccounts() {
        List<Account> accounts = [
            SELECT Id, Name, AnnualRevenue, Industry
            FROM Account
            LIMIT 10
        ];

        // Automatically removes fields user can't access
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            accounts
        );

        return decision.getRecords();
    }
}
```

### Exception Handling

**Good:**

```apex
public class AccountService {
    public class AccountServiceException extends Exception {}

    public static void updateAccount(Account acc) {
        try {
            update acc;
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR, 'Error updating account: ' + e.getMessage());
            throw new AccountServiceException('Failed to update account: ' + e.getDmlMessage(0));
        }
    }
}
```

**Bad:**

```apex
public class AccountService {
    public static void updateAccount(Account acc) {
        try {
            update acc;
        } catch (Exception e) {
            // Swallowing exception - NEVER DO THIS
            System.debug('Error: ' + e.getMessage());
        }
    }
}
```

## Testing Best Practices

### Test Data

**Good:**

```apex
@isTest
private class AccountServiceTest {

    @TestSetup
    static void setup() {
        // Create test data once for all test methods
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Industry = 'Technology'
            ));
        }
        insert accounts;
    }

    @isTest
    static void testGetAccounts() {
        Test.startTest();
        List<Account> accounts = AccountService.getActiveAccounts(10);
        Test.stopTest();

        Assert.areEqual(10, accounts.size(), 'Should return 10 accounts');
    }
}
```

**Bad:**

```apex
@isTest
private class AccountServiceTest {
    @isTest
    static void testGetAccounts() {
        // Creating data in every test method (inefficient)
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test ' + i));
        }
        insert accounts;

        // Test code
    }
}
```

### Assertions

**Good:**

```apex
@isTest
static void testAccountCreation() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    Account inserted = [SELECT Id, Name, IsActive__c FROM Account WHERE Id = :acc.Id];

    // Clear, descriptive assertions
    Assert.areEqual('Test Account', inserted.Name, 'Account name should match');
    Assert.isTrue(inserted.IsActive__c, 'New accounts should be active by default');
}
```

**Bad:**

```apex
@isTest
static void testAccountCreation() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    Account inserted = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];

    // Generic assertion
    Assert.isNotNull(inserted);
}
```

## Git and Version Control

### Commit Messages

**Good:**

```
Add account search functionality

- Implement AccountController.searchAccounts method
- Create accountSearch LWC component
- Add Jest tests for search component
- Update documentation
```

**Bad:**

```
fixed stuff
```

### Branch Naming

**Good:**

```
feature/account-search
bugfix/contact-email-validation
hotfix/production-error-123
```

**Bad:**

```
new-branch
fix
maciej-branch
```

### Pull Requests

**Good PR:**

- Clear title describing the change
- Detailed description of what and why
- Links to related issues
- Screenshots for UI changes
- Tests included and passing
- Code review requested

**Bad PR:**

- No description
- Hundreds of files changed
- No tests
- Failing CI checks

## CI/CD Best Practices

### Pre-Deployment Checklist

- [ ] All tests passing locally
- [ ] Code reviewed by peer
- [ ] No hardcoded values or credentials
- [ ] Documentation updated
- [ ] CI/CD pipeline green
- [ ] Validated in sandbox
- [ ] Rollback plan documented

### Metadata Management

**Good:**

```xml
<!-- Clear, well-organized metadata -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>65.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__RecordPage</target>
        <target>lightning__AppPage</target>
    </targets>
</LightningComponentBundle>
```

### Environment Variables

**Good:**

```apex
// Use Custom Metadata or Custom Settings
Integration_Setting__mdt setting = [
    SELECT Endpoint__c, API_Key__c
    FROM Integration_Setting__mdt
    WHERE DeveloperName = 'Production'
    LIMIT 1
];
String endpoint = setting.Endpoint__c;
```

**Bad:**

```apex
// Hardcoded values
String endpoint = 'https://api.example.com/prod';
String apiKey = 'abc123secret';
```

## Performance Best Practices

### LWC Performance

**Good:**

```javascript
// Cache wire results
@wire(getAccounts)
accounts;

// Use getters for computed values
get hasAccounts() {
    return this.accounts?.data?.length > 0;
}
```

**Bad:**

```javascript
// Imperative calls on every render
renderedCallback() {
    getAccounts()
        .then(result => {
            this.accounts = result;
        });
}
```

### Apex Performance

**Good:**

```apex
// Use selective queries
List<Account> accounts = [
    SELECT Id, Name
    FROM Account
    WHERE Industry = 'Technology'
    AND CreatedDate = LAST_N_DAYS:30
    LIMIT 100
];
```

**Bad:**

```apex
// Querying all records
List<Account> accounts = [SELECT Id, Name FROM Account];

// Filtering in code
List<Account> filtered = new List<Account>();
for (Account acc : accounts) {
    if (acc.Industry == 'Technology') {
        filtered.add(acc);
    }
}
```

## Documentation Best Practices

1. **Code Comments**
   - Explain why, not what
   - Keep comments up-to-date
   - Use JSDoc/JavaDoc format

2. **README Files**
   - Clear setup instructions
   - Prerequisites listed
   - Examples included

3. **API Documentation**
   - Document all public methods
   - Include parameter descriptions
   - Provide usage examples

## Security Best Practices

1. **CRUD/FLS Checks**
   - Always check permissions
   - Use `with sharing`
   - Validate user input

2. **SOQL Injection Prevention**

   ```apex
   // Good - using binding
   String accountName = 'Test';
   List<Account> accounts = [
       SELECT Id FROM Account
       WHERE Name = :accountName
   ];

   // Bad - string concatenation
   String query = 'SELECT Id FROM Account WHERE Name = \'' + accountName + '\'';
   ```

3. **XSS Prevention**
   - Sanitize user input
   - Use platform encoding
   - Validate data types

## Next Steps

- [LWC Examples](/examples/lwc-examples) - See examples in practice
- [Apex Examples](/examples/apex-examples) - Server-side patterns
- [Testing Guide](/guide/testing) - Testing best practices

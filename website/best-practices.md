# Best Practices

Guidelines for effective test data creation with Test Lib.

## Choose the Right Pattern

### Builder - Integration Tests

Use `Builder` when you need real database records:

- Testing triggers and workflows
- Testing SOQL queries
- Testing DML operations
- End-to-end integration tests

```apex
@IsTest
static void integrationTest() {
    // Builder creates real records
    Account acc = (Account) AccountTestModule.Builder()
        .enterprise()
        .buildAndInsert();

    // Test actual database operations
    acc.Rating = 'Hot';
    update acc;

    Account reloaded = [SELECT Rating FROM Account WHERE Id = :acc.Id];
    System.assertEquals('Hot', reloaded.Rating);
}
```

### Mocker - Unit Tests

Use `Mocker` when you don't need database interaction:

- Testing pure business logic
- Testing calculations
- Testing data transformations
- Faster test execution

```apex
@IsTest
static void unitTest() {
    // Mocker creates in-memory records (no DML)
    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .set(Account.AnnualRevenue, 1000000)
        .build();

    // Test pure logic without database
    String tier = AccountClassifier.getTier(acc);
    System.assertEquals('Enterprise', tier);
}
```

## Design Fluent Builders

### Return `this` for Chaining

Always return the builder type for fluent chaining:

```apex
// Good - enables chaining
public AccountBuilder withName(String name) {
    super.set(Account.Name, name);
    return this;
}

// Usage
AccountTestModule.Builder()
    .withName('Acme')
    .withIndustry('Tech')
    .enterprise()
    .buildAndInsert();
```

### Create Semantic Methods

Create methods that express business concepts:

```apex
// Good - expressive and self-documenting
public AccountBuilder enterprise() {
    super.useTemplate('enterprise');
    return this;
}

public AccountBuilder active() {
    super.set(Account.IsActive__c, true);
    return this;
}

// Usage reads like a sentence
AccountTestModule.Builder()
    .enterprise()
    .active()
    .buildAndInsert();
```

### Group Related Fields

```apex
// Good - sets related fields together
public OpportunityBuilder wonDeal(Decimal amount) {
    super.set(Opportunity.StageName, 'Closed Won');
    super.set(Opportunity.Amount, amount);
    super.set(Opportunity.CloseDate, Date.today());
    return this;
}

// Usage
OpportunityTestModule.Builder()
    .wonDeal(100000)
    .buildAndInsert();
```

## Use Templates Effectively

### Define Common Scenarios

```apex
public class Templates implements TestModule.Template {
    public SObject defaultTemplate() {
        return new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
    }

    public Map<String, SObject> templates() {
        return new Map<String, SObject>{
            // Business scenarios
            'enterprise' => new Account(
                Name = 'Enterprise Account',
                AnnualRevenue = 1000000,
                NumberOfEmployees = 500
            ),
            'startup' => new Account(
                Name = 'Startup Account',
                AnnualRevenue = 100000,
                NumberOfEmployees = 10
            ),

            // Account types
            'partner' => new Account(
                Name = 'Partner Account',
                Type = 'Partner'
            ),
            'prospect' => new Account(
                Name = 'Prospect Account',
                Type = 'Prospect',
                Rating = 'Warm'
            )
        };
    }
}
```

### Combine Templates with Overrides

```apex
@IsTest
static void testEnterpriseWithCustomName() {
    Account acc = (Account) AccountTestModule.Builder()
        .enterprise()                    // Start with template
        .withName('Custom Corp')         // Override specific field
        .buildAndInsert();

    System.assertEquals('Custom Corp', acc.Name);
    System.assertEquals(1000000, acc.AnnualRevenue);
}
```

## Randomizers for Bulk Data

### Use for Unique Values

```apex
@IsTest
static void testBulkAccountCreation() {
    List<Account> accounts = AccountTestModule.Builder()
        .withAccountRandomizer()
        .buildAndInsert(100);

    // Each account has unique name
    Set<String> names = new Set<String>();
    for (Account acc : accounts) {
        names.add(acc.Name);
    }
    System.assertEquals(100, names.size());
}
```

### Create Reusable Randomizers

```apex
public class PhoneRandomizer implements TestModule.FieldRandomizer {
    public Object generate(Integer index) {
        String areaCode = String.valueOf(100 + Math.mod(index, 900));
        String prefix = String.valueOf(100 + Math.mod(index * 7, 900));
        String suffix = String.valueOf(1000 + index);
        return '(' + areaCode + ') ' + prefix + '-' + suffix;
    }
}
```

## Mock Relationships

### Parent Relationships with Mocker

```apex
@IsTest
static void testWithParentData() {
    Contact con = (Contact) ContactTestModule.Mocker()
        .setFakeId()
        .set('Account.Name', 'Parent Account')
        .set('Account.Industry', 'Technology')
        .build();

    System.assertEquals('Parent Account', con.Account.Name);
}
```

### Child Relationships with Mocker

```apex
@IsTest
static void testWithChildData() {
    List<Contact> contacts = ContactTestModule.Mocker().build(5);
    List<Opportunity> opps = OpportunityTestModule.Mocker().build(3);

    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .setChildren('Contacts', contacts)
        .setChildren('Opportunities', opps)
        .build();

    System.assertEquals(5, acc.Contacts.size());
    System.assertEquals(3, acc.Opportunities.size());
}
```

## Test Organization

### One Module Per SObject

```
test-module/
├── TestModule.cls              # Framework
└── concrete-modules/
    ├── AccountTestModule.cls   # Account builders
    ├── ContactTestModule.cls   # Contact builders
    └── OpportunityTestModule.cls
```

### Consistent Naming

```apex
// Module: {SObject}TestModule
public class AccountTestModule { ... }

// Builder: {SObject}Builder
public class AccountBuilder extends TestModule.RecordBuilder { ... }

// Mocker: {SObject}Mocker
public class AccountMocker extends TestModule.RecordMocker { ... }
```

## Performance Tips

### Prefer Mocker for Unit Tests

```apex
// Slow - database operations
@IsTest
static void slowTest() {
    Account acc = (Account) AccountTestModule.Builder()
        .buildAndInsert();
    // ...
}

// Fast - no database
@IsTest
static void fastTest() {
    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .build();
    // ...
}
```

### Bulk Operations

```apex
// Good - single DML
List<Account> accounts = AccountTestModule.Builder()
    .buildAndInsert(100);

// Avoid - multiple DML
for (Integer i = 0; i < 100; i++) {
    AccountTestModule.Builder().buildAndInsert();
}
```

### Use @TestSetup for Shared Data

```apex
@IsTest
private class AccountServiceTest {

    @TestSetup
    static void setup() {
        AccountTestModule.Builder()
            .enterprise()
            .buildAndInsert(10);
    }

    @IsTest
    static void test1() {
        List<Account> accounts = [SELECT Id FROM Account];
        // Use pre-created accounts
    }

    @IsTest
    static void test2() {
        List<Account> accounts = [SELECT Id FROM Account];
        // Same accounts available
    }
}
```

## Error Handling

### Handle Missing Templates

```apex
@IsTest
static void testMissingTemplate() {
    try {
        AccountTestModule.Builder()
            .useTemplate('nonexistent')
            .build();
        System.assert(false, 'Should have thrown exception');
    } catch (TestModule.TestModuleException e) {
        System.assert(e.getMessage().contains('not found'));
    }
}
```

## Documentation

### Document Your Modules

```apex
/**
 * Test data builder for Account records.
 *
 * Templates:
 * - enterprise: Large company with 500+ employees
 * - startup: Small company with <50 employees
 * - partner: Partner account type
 *
 * @example
 * Account acc = (Account) AccountTestModule.Builder()
 *     .enterprise()
 *     .withName('Custom Name')
 *     .buildAndInsert();
 */
@IsTest
public class AccountTestModule {
    // ...
}
```

[See Examples →](/examples)

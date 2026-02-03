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
    Assert.areEqual('Hot', reloaded.Rating);
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
    Assert.areEqual('Enterprise', tier);
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

public OpportunityBuilder closedWon() {
    super.useTemplate('closedWon');
    return this;
}

// Usage reads like a sentence
AccountTestModule.Builder()
    .enterprise()
    .buildAndInsert();
```

### Group Related Fields

```apex
// Good - sets related fields together
public OpportunityBuilder closedWon() {
    super.useTemplate('closedWon');  // Sets StageName, CloseDate, Amount
    return this;
}

// Usage
OpportunityTestModule.Builder()
    .closedWon()
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
            'enterprise' => new Account(
                Name = 'Enterprise Account',
                AnnualRevenue = 1000000
            ),
            'startup' => new Account(
                Name = 'Startup Account',
                AnnualRevenue = 100000
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

    Assert.areEqual('Custom Corp', acc.Name);
    Assert.areEqual(1000000, acc.AnnualRevenue);
}
```

## Implement RecordRandomizer Correctly

### Return Map of FieldRandomizers

```apex
public class AccountRandomizer implements TestModule.RecordRandomizer {
    public Map<SObjectField, TestModule.FieldRandomizer> randomizers() {
        return new Map<SObjectField, TestModule.FieldRandomizer>{
            Account.Name => new CompanyNameRandomizer(),
            Account.Industry => new IndustryRandomizer()
        };
    }
}
```

### Create Reusable FieldRandomizers

```apex
public class CompanyNameRandomizer implements TestModule.FieldRandomizer {
    public Object generate(Integer index) {
        return 'Company ' + (index + 1);
    }
}

public class IndustryRandomizer implements TestModule.FieldRandomizer {
    private List<String> industries = new List<String>{
        'Technology', 'Finance', 'Healthcare', 'Retail'
    };

    public Object generate(Integer index) {
        return industries[Math.mod(index, industries.size())];
    }
}
```

## Mock Relationships

### Parent Relationships with Mocker

```apex
@IsTest
static void testWithParentData() {
    Contact con = (Contact) ContactTestModule.Mocker()
        .withFakeId()
        .set('Account.Name', 'Parent Account')
        .set('Account.Industry', 'Technology')
        .build();

    Assert.areEqual('Parent Account', con.Account.Name);
}
```

### Child Relationships with Mocker

```apex
@IsTest
static void testWithChildData() {
    List<Contact> contacts = (List<Contact>) ContactTestModule.Mocker().build(5);

    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .setChildren('Contacts', contacts)
        .build();

    Assert.areEqual(5, acc.Contacts.size());
}
```

## Test Organization

### One Module Per SObject

```
concrete-modules/
├── AccountTestModule.cls
├── ContactTestModule.cls
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

// Randomizer: {SObject}Randomizer or {Field}Randomizer
public class AccountRandomizer implements TestModule.RecordRandomizer { ... }
public class IndustryRandomizer implements TestModule.FieldRandomizer { ... }
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
List<SObject> accounts = AccountTestModule.Builder()
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
    Boolean exceptionThrown = false;
    try {
        AccountTestModule.Builder()
            .useTemplate('nonexistent')
            .build();
    } catch (TestModule.TestModuleException e) {
        exceptionThrown = true;
        Assert.isTrue(e.getMessage().contains('not found'));
    }
    Assert.isTrue(exceptionThrown, 'Expected TestModuleException');
}
```

## Documentation

### Document Your Modules

```apex
/**
 * Test data builder for Account records.
 *
 * Templates:
 * - enterprise: Large company with $1M+ revenue
 * - startup: Small company with $100K revenue
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

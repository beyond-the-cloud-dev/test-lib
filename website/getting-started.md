# Getting Started

Learn how to use Test Lib in your Salesforce Apex tests.

## What is Test Lib?

Test Lib is a fluent test data builder library for Salesforce Apex. It provides two complementary patterns:

- **Builder** - Create real SObject records for database insertion
- **Mocker** - Create in-memory SObjects without DML operations

Both patterns use fluent APIs with method chaining for clean, readable test code.

## Installation

See the [Installation Guide](/installation) for setup instructions.

## Core Concepts

### 1. Test Module Classes

Create a Test Module class for each SObject you want to build:

```apex
@IsTest
public class AccountTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static AccountBuilder Builder() {
        return new AccountBuilder();
    }

    public static AccountMocker Mocker() {
        return new AccountMocker();
    }

    // Builder and Mocker implementations...
}
```

### 2. Builder Pattern

Use `Builder` when you need records in the database:

```apex
@IsTest
static void testWithRealRecords() {
    // Create single record
    Account acc = (Account) AccountTestModule.Builder()
        .withName('Acme Corp')
        .withIndustry('Technology')
        .buildAndInsert();

    // Create multiple records
    List<SObject> accounts = AccountTestModule.Builder()
        .withAccountRandomizer()
        .buildAndInsert(10);

    // Records have real IDs and are in the database
    Assert.isNotNull(acc.Id);
}
```

### 3. Mocker Pattern

Use `Mocker` when you need records without DML (faster unit tests):

```apex
@IsTest
static void testWithMockedRecords() {
    // Create in-memory record with fake ID
    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .build();

    // Mock parent relationships
    Account accWithParent = (Account) AccountTestModule.Mocker()
        .withParentName('Parent Corp')
        .build();

    // Mock child relationships
    List<Contact> contacts = (List<Contact>) ContactTestModule.Mocker().build(3);
    Account accWithContacts = (Account) AccountTestModule.Mocker()
        .withContacts(contacts)
        .build();
}
```

## Basic Usage

### Creating a Simple Builder

```apex
public class AccountBuilder extends TestModule.RecordBuilder {
    public AccountBuilder() {
        super(new Account(Name = 'Default Account'));
    }

    public AccountBuilder withName(String name) {
        super.set(Account.Name, name);
        return this;
    }

    public AccountBuilder withIndustry(String industry) {
        super.set(Account.Industry, industry);
        return this;
    }
}
```

### Creating a Simple Mocker

```apex
public class AccountMocker extends TestModule.RecordMocker {
    public AccountMocker() {
        super(new Account(Name = 'Test Account'));
    }

    public AccountMocker withContacts(List<Contact> contacts) {
        super.setChildren('Contacts', contacts);
        return this;
    }
}
```

## Builder Methods

| Method | Description |
|--------|-------------|
| `set(SObjectField, Object)` | Set field value using SObjectField token |
| `set(String, Object)` | Set field value using String field name |
| `useTemplate(String)` | Apply named template |
| `withRandomizer(RecordRandomizer)` | Apply record randomizer for multiple fields |
| `withRandomizer(SObjectField, FieldRandomizer)` | Apply single field randomizer |
| `build()` | Build single record (no DML) |
| `buildAndInsert()` | Build and insert single record |
| `build(Integer)` | Build multiple records (no DML) |
| `buildAndInsert(Integer)` | Build and insert multiple records |

## Mocker Methods

| Method | Description |
|--------|-------------|
| `set(SObjectField, Object)` | Set field value |
| `set(String, Object)` | Set field value (supports dot notation for parent relationships) |
| `setChildren(String, List<SObject>)` | Set child relationship |
| `setFakeId()` | Generate fake ID |
| `withRandomizer(RecordRandomizer)` | Apply record randomizer |
| `withRandomizer(SObjectField, FieldRandomizer)` | Apply single field randomizer |
| `build()` | Build single mock record |
| `build(Integer)` | Build multiple mock records |

## Quick Example

```apex
@IsTest
private class OpportunityServiceTest {

    @IsTest
    static void shouldCreateOpportunityWithAccount() {
        // Arrange
        Account acc = (Account) AccountTestModule.Builder()
            .enterprise()
            .buildAndInsert();

        // Act
        Opportunity opp = (Opportunity) OpportunityTestModule.Builder()
            .set(Opportunity.AccountId, acc.Id)
            .withAmount(100000)
            .buildAndInsert();

        // Assert
        Assert.areEqual(acc.Id, opp.AccountId);
        Assert.areEqual(100000, opp.Amount);
    }

    @IsTest
    static void shouldProcessClosedOpportunity() {
        // Arrange - Use Mocker for pure unit tests
        Opportunity opp = (Opportunity) OpportunityTestModule.Mocker()
            .withFakeId()
            .withStageName('Closed Won')
            .withAmount(100000)
            .build();

        // Act - Test pure logic without database
        Boolean isClosed = OpportunityService.isClosed(opp);

        // Assert
        Assert.isTrue(isClosed);
    }
}
```

## Next Steps

- Learn about [Builder Pattern](/builder) in depth
- Explore [Mocker Pattern](/mocker) for unit testing
- See [Templates](/templates) for reusable configurations
- Use [Randomizers](/randomizers) for bulk data generation
- Review [API Reference](/api)
- Check [Complete Examples](/examples)

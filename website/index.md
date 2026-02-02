---
layout: home

hero:
  name: "Test Lib"
  text: "Apex Test Data Builder"
  tagline: A fluent, type-safe library for creating test data in Salesforce Apex tests using Builder and Mocker patterns
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started
    - theme: alt
      text: API Reference
      link: /api
    - theme: alt
      text: View on GitHub
      link: https://github.com/beyond-the-cloud-dev/test-lib

features:
  - icon: 🏗️
    title: Builder Pattern
    details: Create real SObject records with fluent API. Build single records or bulk insert multiple records with one call.

  - icon: 🎭
    title: Mocker Pattern
    details: Create in-memory SObjects without DML operations. Perfect for unit testing triggers, services, and complex logic.

  - icon: 📋
    title: Templates
    details: Define reusable record templates for common scenarios like "enterprise account" or "startup account".

  - icon: 🎲
    title: Randomizers
    details: Generate unique field values automatically. Create 100 accounts with unique names and industries effortlessly.

  - icon: 🔗
    title: Parent-Child Relations
    details: Mock complex object relationships including parent lookups and child record collections.

  - icon: 🚀
    title: Production Ready
    details: Battle-tested in production. Part of Beyond The Cloud suite of enterprise-grade Salesforce libraries.
---

## Why Test Lib?

Creating test data in Apex is verbose and repetitive. Test Lib simplifies it with fluent, type-safe builders:

::: code-group

```apex [Before - Verbose]
// Traditional approach - verbose and hard to maintain
@IsTest
static void testAccountProcessing() {
    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.Industry = 'Technology';
    acc.AnnualRevenue = 1000000;
    acc.BillingCity = 'San Francisco';
    insert acc;

    Contact con = new Contact();
    con.FirstName = 'John';
    con.LastName = 'Doe';
    con.AccountId = acc.Id;
    insert con;

    // Test logic...
}
```

```apex [After - Clean]
// Test Lib - fluent and maintainable
@IsTest
static void testAccountProcessing() {
    Account acc = (Account) AccountTestModule.Builder()
        .withName('Test Account')
        .enterprise()
        .buildAndInsert();

    Contact con = (Contact) ContactTestModule.Builder()
        .withAccount(acc.Id)
        .buildAndInsert();

    // Test logic...
}
```

:::

## Builder vs Mocker

Test Lib provides two complementary patterns:

### Builder - Real Records

Use `Builder` when you need records in the database:

```apex
// Single record
Account acc = (Account) AccountTestModule.Builder()
    .withName('Acme Corp')
    .withIndustry('Technology')
    .buildAndInsert();

// Multiple records with unique values
List<Account> accounts = AccountTestModule.Builder()
    .withAccountRandomizer()
    .buildAndInsert(100);
```

### Mocker - In-Memory Records

Use `Mocker` when you need records without DML (faster tests):

```apex
// Mock record with fake ID
Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .build();

// Mock with parent relationship
Account acc = (Account) AccountTestModule.Mocker()
    .withParentName('Parent Corp')
    .build();

// Mock with child records
List<Contact> contacts = ContactTestModule.Mocker().build(3);
Account acc = (Account) AccountTestModule.Mocker()
    .withContacts(contacts)
    .build();
```

## Quick Example

```apex
@IsTest
private class OpportunityServiceTest {

    @IsTest
    static void shouldCalculateExpectedRevenue() {
        // Arrange - Create test data with Builder
        Account acc = (Account) AccountTestModule.Builder()
            .enterprise()
            .buildAndInsert();

        Opportunity opp = (Opportunity) OpportunityTestModule.Builder()
            .withAccount(acc.Id)
            .withAmount(100000)
            .withProbability(75)
            .buildAndInsert();

        // Act
        Decimal revenue = OpportunityService.calculateExpectedRevenue(opp.Id);

        // Assert
        Assert.areEqual(75000, revenue);
    }

    @IsTest
    static void shouldProcessOpportunityWithMockedData() {
        // Arrange - Use Mocker for unit tests (no DML)
        Opportunity opp = (Opportunity) OpportunityTestModule.Mocker()
            .setFakeId()
            .set(Opportunity.Amount, 100000)
            .set(Opportunity.Probability, 75)
            .build();

        // Act & Assert - Test pure logic without database
        Decimal expected = OpportunityService.calculateExpected(opp);
        Assert.areEqual(75000, expected);
    }
}
```

## Features at a Glance

- **Builder Pattern** - Fluent API for creating real database records
- **Mocker Pattern** - Create in-memory records without DML
- **Templates** - Reusable record configurations
- **Randomizers** - Generate unique field values for bulk creation
- **Type Safety** - Compile-time field validation
- **Parent Relations** - Mock parent lookups (e.g., `Account.Parent.Name`)
- **Child Relations** - Mock child collections (e.g., `Account.Contacts`)
- **Fake IDs** - Generate valid-looking IDs without database

## Part of Beyond The Cloud

Test Lib is part of [Beyond The Cloud](https://beyondthecloud.dev) suite of production-ready Salesforce libraries.

## Get Started

Ready to simplify your test data creation? [Get started →](/getting-started)

<BTCFooter context="test-lib" />

# Mocker Pattern

The Mocker pattern creates in-memory SObject records without database operations.

## Overview

Use `Mocker` when you don't need records in the database:

- Unit tests for pure business logic
- Testing calculations and transformations
- Mocking query results with relationships
- Faster test execution (no DML overhead)

## RecordMocker Base Class

All mockers extend `TestModule.RecordMocker`:

```apex
public class AccountMocker extends TestModule.RecordMocker {
    public AccountMocker() {
        super(new Account(Name = 'Test Account'));
    }
}
```

## Building Mock Records

### Single Record

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .set(Account.Name, 'Mock Account')
    .build();

// No database operation - acc.Id is null
System.assertEquals(null, acc.Id);
System.assertEquals('Mock Account', acc.Name);
```

### Multiple Records

```apex
List<Account> accounts = AccountTestModule.Mocker()
    .set(Account.Industry, 'Technology')
    .build(10);

// 10 in-memory records
System.assertEquals(10, accounts.size());
```

## Setting Field Values

### Using SObjectField Token

```apex
public AccountMocker withName(String name) {
    super.set(Account.Name, name);
    return this;
}
```

### Using String Field Name

Supports dot notation for parent relationships:

```apex
// Simple field
super.set('Name', 'Test Account');

// Parent relationship
super.set('Parent.Name', 'Parent Corp');
super.set('Owner.Name', 'John Doe');
```

## Fake IDs

Generate valid-looking IDs without database inserts:

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .build();

// Has a valid ID format: 001000000000001
System.assertNotEquals(null, acc.Id);
System.assert(String.valueOf(acc.Id).startsWith('001'));
```

### Multiple Records with Fake IDs

Each record gets a unique fake ID:

```apex
List<Account> accounts = AccountTestModule.Mocker()
    .setFakeId()
    .build(3);

// 001000000000001, 001000000000002, 001000000000003
Set<Id> ids = new Set<Id>();
for (Account acc : accounts) {
    ids.add(acc.Id);
}
System.assertEquals(3, ids.size());
```

## Parent Relationships

Mock parent lookup relationships using dot notation:

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .withParentName('Parent Corporation')
    .build();

// Parent relationship is populated
System.assertEquals('Parent Corporation', acc.Parent.Name);
```

### Implementation

```apex
public AccountMocker withParentName(String name) {
    super.set('Parent.Name', name);
    return this;
}

public AccountMocker withOwner(String ownerName, String ownerEmail) {
    super.set('Owner.Name', ownerName);
    super.set('Owner.Email', ownerEmail);
    return this;
}
```

### Deep Nesting

```apex
Contact con = (Contact) ContactTestModule.Mocker()
    .set('Account.Name', 'Acme Corp')
    .set('Account.Parent.Name', 'Acme Holdings')
    .build();

System.assertEquals('Acme Corp', con.Account.Name);
System.assertEquals('Acme Holdings', con.Account.Parent.Name);
```

## Child Relationships

Mock child record collections:

```apex
List<Contact> contacts = ContactTestModule.Mocker()
    .set(Contact.FirstName, 'Test')
    .build(3);

Account acc = (Account) AccountTestModule.Mocker()
    .setChildren('Contacts', contacts)
    .build();

// Child records are accessible
System.assertEquals(3, acc.Contacts.size());
```

### Implementation

```apex
public AccountMocker withContacts(List<Contact> contacts) {
    super.setChildren('Contacts', contacts);
    return this;
}

public AccountMocker withOpportunities(List<Opportunity> opportunities) {
    super.setChildren('Opportunities', opportunities);
    return this;
}
```

### Multiple Child Relationships

```apex
List<Contact> contacts = ContactTestModule.Mocker().build(5);
List<Opportunity> opps = OpportunityTestModule.Mocker().build(3);
List<Case> cases = CaseTestModule.Mocker().build(2);

Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .withContacts(contacts)
    .withOpportunities(opps)
    .setChildren('Cases', cases)
    .build();

System.assertEquals(5, acc.Contacts.size());
System.assertEquals(3, acc.Opportunities.size());
System.assertEquals(2, acc.Cases.size());
```

## Randomizers with Mocker

```apex
List<Account> accounts = AccountTestModule.Mocker()
    .withRandomIndustry()
    .build(4);

// Industries cycle: Technology, Finance, Healthcare, Retail
System.assertEquals('Technology', accounts[0].Industry);
System.assertEquals('Finance', accounts[1].Industry);
```

## Complete Mocker Example

```apex
@IsTest
public class AccountTestModule implements TestModule.MockerProvider {

    public static AccountMocker Mocker() {
        return new AccountMocker();
    }

    public class AccountMocker extends TestModule.RecordMocker {

        public AccountMocker() {
            super(new Account(Name = 'Test Account', Industry = 'Technology'));
        }

        // Field setters
        public AccountMocker withName(String name) {
            super.set(Account.Name, name);
            return this;
        }

        public AccountMocker withIndustry(String industry) {
            super.set(Account.Industry, industry);
            return this;
        }

        // Parent relationships
        public AccountMocker withParentName(String parentName) {
            super.set('Parent.Name', parentName);
            return this;
        }

        public AccountMocker withOwnerName(String ownerName) {
            super.set('Owner.Name', ownerName);
            return this;
        }

        // Child relationships
        public AccountMocker withContacts(List<Contact> contacts) {
            super.setChildren('Contacts', contacts);
            return this;
        }

        public AccountMocker withOpportunities(List<Opportunity> opportunities) {
            super.setChildren('Opportunities', opportunities);
            return this;
        }

        // Randomizers
        public AccountMocker withRandomIndustry() {
            super.withRandomizer(Account.Industry, new IndustryRandomizer());
            return this;
        }
    }

    public class IndustryRandomizer implements TestModule.SingleFieldRandomizer {
        private List<String> industries = new List<String>{
            'Technology', 'Finance', 'Healthcare', 'Retail'
        };

        public Object generate(Integer index) {
            return industries[Math.mod(index, industries.size())];
        }
    }
}
```

## Use Cases

### Testing Business Logic

```apex
@IsTest
static void testDiscountCalculation() {
    // Mock account without database
    Account acc = (Account) AccountTestModule.Mocker()
        .set(Account.AnnualRevenue, 500000)
        .set(Account.Type, 'Customer')
        .build();

    // Test pure business logic
    Decimal discount = PricingService.calculateDiscount(acc);

    System.assertEquals(0.15, discount);
}
```

### Testing Trigger Logic

```apex
@IsTest
static void testTriggerHandler() {
    Account oldAcc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .set(Account.Rating, 'Cold')
        .build();

    Account newAcc = (Account) AccountTestModule.Mocker()
        .set(Account.Id, oldAcc.Id)
        .set(Account.Rating, 'Hot')
        .build();

    // Test trigger logic without DML
    Boolean changed = AccountTriggerHandler.hasRatingChanged(oldAcc, newAcc);

    System.assert(changed);
}
```

### Testing Data Mapping

```apex
@IsTest
static void testDTOMapping() {
    List<Contact> contacts = ContactTestModule.Mocker().build(3);

    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .withParentName('Holding Company')
        .withContacts(contacts)
        .build();

    // Test mapping logic
    AccountDTO dto = AccountMapper.toDTO(acc);

    System.assertEquals(3, dto.contactCount);
    System.assertEquals('Holding Company', dto.parentName);
}
```

### Mocking Query Results

```apex
@IsTest
static void testServiceWithMockedQuery() {
    // Create mock data as if from SOQL query
    List<Contact> contacts = ContactTestModule.Mocker()
        .set(Contact.Email, 'test@example.com')
        .build(5);

    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .set(Account.Name, 'Test Account')
        .withContacts(contacts)
        .build();

    // Test service that processes query results
    Integer emailCount = AccountService.countContactEmails(acc);

    System.assertEquals(5, emailCount);
}
```

## Mocker vs Builder

| Aspect | Mocker | Builder |
|--------|--------|---------|
| Database | No DML | Inserts records |
| Speed | Fast | Slower (DML overhead) |
| IDs | Fake IDs or null | Real database IDs |
| Relationships | Mocked in-memory | Real references |
| Use Case | Unit tests | Integration tests |
| Query Results | Can mock | Must query |

[Next: Templates →](/templates)

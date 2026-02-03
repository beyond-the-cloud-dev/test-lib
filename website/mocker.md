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
Assert.isNull(acc.Id);
Assert.areEqual('Mock Account', acc.Name);
```

### Multiple Records

```apex
List<SObject> accounts = AccountTestModule.Mocker()
    .set(Account.Industry, 'Technology')
    .build(10);

// 10 in-memory records
Assert.areEqual(10, accounts.size());
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
Assert.isNotNull(acc.Id);
Assert.isTrue(String.valueOf(acc.Id).startsWith('001'));
```

### Unique IDs Across Calls

Each call to `setFakeId()` generates a unique ID:

```apex
Account acc1 = (Account) AccountTestModule.Mocker().setFakeId().build();
Account acc2 = (Account) AccountTestModule.Mocker().setFakeId().build();

// Different IDs
Assert.areNotEqual(acc1.Id, acc2.Id);
```

### Static IdGenerator

You can also use the static utility directly:

```apex
Id accountId = TestModule.IdGenerator.get(Account.SObjectType);
Id contactId = TestModule.IdGenerator.get(Contact.SObjectType);

Assert.isTrue(String.valueOf(accountId).startsWith('001'));
Assert.isTrue(String.valueOf(contactId).startsWith('003'));
```

## Parent Relationships

Mock parent lookup relationships using dot notation:

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .withParentName('Parent Corporation')
    .build();

// Parent relationship is populated
Assert.areEqual('Parent Corporation', acc.Parent.Name);
```

### Implementation

```apex
public AccountMocker withParentName(String name) {
    super.set('Parent.Name', name);
    return this;
}
```

### Deep Nesting

```apex
Contact con = (Contact) ContactTestModule.Mocker()
    .set('Account.Name', 'Acme Corp')
    .set('Account.Parent.Name', 'Acme Holdings')
    .build();

Assert.areEqual('Acme Corp', con.Account.Name);
Assert.areEqual('Acme Holdings', con.Account.Parent.Name);
```

### Read-Only Fields

You can set read-only fields like `CreatedDate`, `Owner.Name`, etc.:

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .set('CreatedDate', Datetime.newInstance(2025, 1, 15, 10, 30, 0))
    .set('Owner.Name', 'System Admin')
    .build();

Assert.areEqual('System Admin', acc.Owner.Name);
```

## Child Relationships

Mock child record collections:

```apex
List<Contact> contacts = (List<Contact>) ContactTestModule.Mocker()
    .withLastName('Smith')
    .build(3);

Account acc = (Account) AccountTestModule.Mocker()
    .setChildren('Contacts', contacts)
    .build();

// Child records are accessible
Assert.areEqual(3, acc.Contacts.size());
```

### Implementation

```apex
public AccountMocker withContacts(List<Contact> contacts) {
    super.setChildren('Contacts', contacts);
    return this;
}
```

### Multiple Child Relationships

```apex
List<Contact> contacts = (List<Contact>) ContactTestModule.Mocker().build(5);
List<Opportunity> opps = (List<Opportunity>) OpportunityTestModule.Mocker().build(3);

Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .withContacts(contacts)
    .setChildren('Opportunities', opps)
    .build();

Assert.areEqual(5, acc.Contacts.size());
Assert.areEqual(3, acc.Opportunities.size());
```

## Randomizers with Mocker

```apex
List<SObject> accounts = AccountTestModule.Mocker()
    .withRandomIndustry()
    .build(4);

// Industries cycle: Technology, Finance, Healthcare, Retail
Assert.areEqual('Technology', accounts[0].get('Industry'));
Assert.areEqual('Finance', accounts[1].get('Industry'));
```

### Using ListRandomizer

```apex
List<SObject> accounts = AccountTestModule.Mocker()
    .withRandomizer(Account.Industry,
        TestModule.ListRandomizer(new List<Object>{ 'A', 'B' }))
    .build(4);

Assert.areEqual('A', accounts[0].get('Industry'));
Assert.areEqual('B', accounts[1].get('Industry'));
Assert.areEqual('A', accounts[2].get('Industry'));
Assert.areEqual('B', accounts[3].get('Industry'));
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

        // Fake ID
        public AccountMocker withFakeId() {
            super.setFakeId();
            return this;
        }

        // Parent relationships
        public AccountMocker withParentName(String parentName) {
            super.set('Parent.Name', parentName);
            return this;
        }

        // Child relationships
        public AccountMocker withContacts(List<Contact> contacts) {
            super.setChildren('Contacts', contacts);
            return this;
        }

        // Randomizers
        public AccountMocker withRandomIndustry() {
            super.withRandomizer(Account.Industry, new IndustryRandomizer());
            return this;
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

    Assert.areEqual(0.15, discount);
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

    Assert.isTrue(changed);
}
```

### Testing Data Mapping

```apex
@IsTest
static void testDTOMapping() {
    List<Contact> contacts = (List<Contact>) ContactTestModule.Mocker().build(3);

    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .withParentName('Holding Company')
        .withContacts(contacts)
        .build();

    // Test mapping logic
    AccountDTO dto = AccountMapper.toDTO(acc);

    Assert.areEqual(3, dto.contactCount);
    Assert.areEqual('Holding Company', dto.parentName);
}
```

### Builder + Mocker Integration

```apex
@IsTest
static void testBuilderThenMocker() {
    // Create real account in database
    Account realAccount = (Account) AccountTestModule.Builder()
        .withName('Real Account')
        .buildAndInsert();

    // Create mock contact referencing real account
    Contact mockContact = (Contact) ContactTestModule.Mocker()
        .withFakeId()
        .set('Account.Name', realAccount.Name)
        .build();

    Assert.isNotNull(realAccount.Id);
    Assert.areEqual('Real Account', mockContact.Account.Name);
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

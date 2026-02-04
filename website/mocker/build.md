---
outline: deep
---

# Build

Build in-memory SObject records without database operations.

## Methods

| Method | Description |
|--------|-------------|
| [`set(SObjectField, Object)`](#set-sobjectfield) | Set field value using field token |
| [`set(String, Object)`](#set-string) | Set field value (supports dot notation for parents) |
| [`setChildren(String, List)`](#setchildren) | Set child relationship records |
| [`setFakeId()`](#setfakeid) | Generate and set a fake ID |
| [`build()`](#build) | Build single mock record |
| [`build(Integer)`](#build-multiple) | Build multiple mock records |

## set (SObjectField)

Set a field value using the SObjectField token.

**Signature**

```apex
Mocker set(SObjectField field, Object value);
```

**Test Lib**

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .set(Account.Name, 'Mock Account')
    .set(Account.Industry, 'Technology')
    .build();
```

## set (String)

Set a field value using a string field name. Supports dot notation for parent relationships.

**Signature**

```apex
Mocker set(String field, Object value);
```

### Simple Field

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .set('Name', 'Mock Account')
    .set('Industry', 'Technology')
    .build();
```

### Parent Relationship

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .set('Parent.Name', 'Parent Corporation')
    .build();

// acc.Parent.Name == 'Parent Corporation'
```

### Deeply Nested

```apex
Contact con = (Contact) ContactTestModule.Mocker()
    .set('Account.Parent.Name', 'Grandparent Corp')
    .build();

// con.Account.Parent.Name == 'Grandparent Corp'
```

### Read-Only Fields

Mocker can set fields that are normally read-only in Apex.

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .set('CreatedDate', Datetime.newInstance(2025, 1, 15, 10, 30, 0))
    .set('Owner.Name', 'System Admin')
    .build();

Assert.areEqual('System Admin', acc.Owner.Name);
```

::: tip
Use dot notation to mock parent relationships. This is especially useful when testing code that accesses parent fields from query results.
:::

## setChildren

Set child relationship records on a mock parent.

**Signature**

```apex
Mocker setChildren(String relationship, List<SObject> children);
```

**Traditional Apex**

```apex
// Cannot mock child relationships without database queries
Account acc = [SELECT Id, (SELECT Id, LastName FROM Contacts) FROM Account WHERE Id = :accId];
```

**Test Lib**

```apex
List<Contact> contacts = (List<Contact>) ContactTestModule.Mocker()
    .build(3);

Account acc = (Account) AccountTestModule.Mocker()
    .setChildren('Contacts', contacts)
    .build();

// acc.Contacts.size() == 3
```

### Multiple Child Relationships

```apex
List<Contact> contacts = (List<Contact>) ContactTestModule.Mocker().build(5);
List<Opportunity> opportunities = (List<Opportunity>) OpportunityTestModule.Mocker().build(3);

Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .setChildren('Contacts', contacts)
    .setChildren('Opportunities', opportunities)
    .build();

Assert.areEqual(5, acc.Contacts.size());
Assert.areEqual(3, acc.Opportunities.size());
```

## setFakeId

Generate and set a fake ID for the mock record.

**Signature**

```apex
Mocker setFakeId();
```

**Traditional Apex**

```apex
// Cannot create valid IDs without database insert
Account acc = new Account(Name = 'Test');
// acc.Id is null
```

**Test Lib**

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .build();

// acc.Id is a valid-looking ID like 001000000000001
Assert.isNotNull(acc.Id);
Assert.isTrue(String.valueOf(acc.Id).startsWith('001'));
```

### Unique IDs

Each call to `setFakeId()` generates a unique ID.

```apex
Account acc1 = (Account) AccountTestModule.Mocker().setFakeId().build();
Account acc2 = (Account) AccountTestModule.Mocker().setFakeId().build();

Assert.areNotEqual(acc1.Id, acc2.Id);
```

::: tip
Use fake IDs when testing code that requires record IDs but doesn't need actual database records, such as Map operations or trigger handlers.
:::

## build

Build a single mock record.

**Signature**

```apex
SObject build();
```

**Traditional Apex**

```apex
Account acc = new Account(Name = 'Test Account', Industry = 'Technology');
// Cannot set read-only fields like CreatedDate, formulas, etc.
```

**Test Lib**

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .set(Account.Name, 'Test Account')
    .set(Account.Industry, 'Technology')
    .build();

// No database operation - perfect for unit tests
```

## build (Multiple)

Build multiple mock records.

**Signature**

```apex
List<SObject> build(Integer amount);
```

**Traditional Apex**

```apex
List<Account> accounts = new List<Account>();
for (Integer i = 0; i < 10; i++) {
    accounts.add(new Account(Name = 'Account ' + i));
}
```

**Test Lib**

```apex
List<SObject> accounts = AccountTestModule.Mocker()
    .set(Account.Industry, 'Technology')
    .build(10);
```

## When to Use Mocker

Use Mocker instead of Builder when:

- Testing pure business logic without database
- Testing calculations and transformations
- Mocking query results with relationships
- Need faster test execution (no DML overhead)
- Need to set read-only fields (CreatedDate, formulas)

**Example: Testing Business Logic**

```apex
@IsTest
static void testDiscountCalculation() {
    Account acc = (Account) AccountTestModule.Mocker()
        .set(Account.AnnualRevenue, 500000)
        .set(Account.Type, 'Customer')
        .build();

    Decimal discount = PricingService.calculateDiscount(acc);

    Assert.areEqual(0.15, discount);
}
```

::: tip
Mocker creates records using JSON serialization, which allows setting read-only fields that are normally impossible to set in Apex.
:::

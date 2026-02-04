---
outline: deep
---

# Build

Build in-memory SObject records without database operations.

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

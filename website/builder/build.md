---
outline: deep
---

# Build

Build real SObject records for database insertion.

## Methods

| Method | Description |
|--------|-------------|
| [`set(SObjectField, Object)`](#set-sobjectfield) | Set field value using field token |
| [`set(String, Object)`](#set-string) | Set field value using field name |
| [`build()`](#build) | Build single record (no DML) |
| [`buildAndInsert()`](#buildandinsert) | Build and insert single record |
| [`build(Integer)`](#build-multiple) | Build multiple records (no DML) |
| [`buildAndInsert(Integer)`](#buildandinsert-multiple) | Build and insert multiple records |

## set (SObjectField)

Set a field value using the SObjectField token for compile-time validation.

**Signature**

```apex
Builder set(SObjectField field, Object value);
```

**Traditional Apex**

```apex
Account acc = new Account();
acc.Name = 'Acme Corp';
acc.Industry = 'Technology';
acc.AnnualRevenue = 1000000;
```

**Test Lib**

```apex
Account acc = (Account) AccountTestModule.Builder()
    .set(Account.Name, 'Acme Corp')
    .set(Account.Industry, 'Technology')
    .set(Account.AnnualRevenue, 1000000)
    .build();
```

## set (String)

Set a field value using a string field name.

**Signature**

```apex
Builder set(String field, Object value);
```

**Traditional Apex**

```apex
Account acc = new Account();
acc.put('Name', 'Acme Corp');
acc.put('Industry', 'Technology');
```

**Test Lib**

```apex
Account acc = (Account) AccountTestModule.Builder()
    .set('Name', 'Acme Corp')
    .set('Industry', 'Technology')
    .build();
```

## Convenience Methods

Create custom convenience methods in your Builder class for common fields.

**Implementation**

```apex
public class AccountBuilder extends TestModule.RecordBuilder {
    public AccountBuilder() {
        super(new Account(Name = 'Test Account'));
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

**Usage**

```apex
Account acc = (Account) AccountTestModule.Builder()
    .withName('Acme Corp')
    .withIndustry('Technology')
    .buildAndInsert();
```

::: tip
Prefer SObjectField tokens over string field names for compile-time validation and refactoring safety.
:::

## build

Build a single record without inserting it into the database.

**Signature**

```apex
SObject build();
```

**Traditional Apex**

```apex
Account acc = new Account(Name = 'Test Account', Industry = 'Technology');
```

**Test Lib**

```apex
Account acc = (Account) AccountTestModule.Builder()
    .withName('Test Account')
    .withIndustry('Technology')
    .build();
```

## buildAndInsert

Build and insert a single record into the database.

**Signature**

```apex
SObject buildAndInsert();
```

**Traditional Apex**

```apex
Account acc = new Account(Name = 'Test Account', Industry = 'Technology');
insert acc;
```

**Test Lib**

```apex
Account acc = (Account) AccountTestModule.Builder()
    .withName('Test Account')
    .withIndustry('Technology')
    .buildAndInsert();
```

## build (Multiple)

Build multiple records without inserting them.

**Signature**

```apex
List<SObject> build(Integer amount);
```

**Traditional Apex**

```apex
List<Account> accounts = new List<Account>();
for (Integer i = 0; i < 10; i++) {
    accounts.add(new Account(Name = 'Account ' + i, Industry = 'Technology'));
}
```

**Test Lib**

```apex
List<SObject> accounts = AccountTestModule.Builder()
    .withIndustry('Technology')
    .build(10);
```

## buildAndInsert (Multiple)

Build and insert multiple records into the database.

**Signature**

```apex
List<SObject> buildAndInsert(Integer amount);
```

**Traditional Apex**

```apex
List<Account> accounts = new List<Account>();
for (Integer i = 0; i < 10; i++) {
    accounts.add(new Account(Name = 'Account ' + i, Industry = 'Technology'));
}
insert accounts;
```

**Test Lib**

```apex
List<SObject> accounts = AccountTestModule.Builder()
    .withIndustry('Technology')
    .buildAndInsert(10);
```

::: tip
Use `build()` when you need records for in-memory operations. Use `buildAndInsert()` when you need records with real IDs in the database for integration tests.
:::

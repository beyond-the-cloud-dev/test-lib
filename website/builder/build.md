---
outline: deep
---

# Build

Build real SObject records for database insertion.

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

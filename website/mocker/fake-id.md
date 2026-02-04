---
outline: deep
---

# Fake ID

Generate valid-looking Salesforce IDs without database inserts.

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

## Unique IDs

Each call to `setFakeId()` generates a unique ID.

```apex
Account acc1 = (Account) AccountTestModule.Mocker().setFakeId().build();
Account acc2 = (Account) AccountTestModule.Mocker().setFakeId().build();

Assert.areNotEqual(acc1.Id, acc2.Id);
```

## Multiple Records

When building multiple records, each gets a unique ID.

```apex
List<SObject> accounts = AccountTestModule.Mocker()
    .setFakeId()
    .build(3);

Set<Id> ids = new Set<Id>();
for (SObject acc : accounts) {
    ids.add(acc.Id);
}

Assert.areEqual(3, ids.size()); // All unique
```

## Use Cases

### Testing with Maps

```apex
Account acc = (Account) AccountTestModule.Mocker().setFakeId().build();

Map<Id, Account> accountMap = new Map<Id, Account>{ acc.Id => acc };

Assert.isTrue(accountMap.containsKey(acc.Id));
```

### Testing Trigger Logic

```apex
Account oldAcc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .set(Account.Rating, 'Cold')
    .build();

Account newAcc = (Account) AccountTestModule.Mocker()
    .set(Account.Id, oldAcc.Id)
    .set(Account.Rating, 'Hot')
    .build();

Boolean changed = AccountTriggerHandler.hasRatingChanged(oldAcc, newAcc);

Assert.isTrue(changed);
```

## Convenience Method

Create a convenience method in your Mocker class.

**Implementation**

```apex
public class AccountMocker extends TestModule.RecordMocker {
    public AccountMocker() {
        super(new Account(Name = 'Test Account'));
    }

    public AccountMocker withFakeId() {
        super.setFakeId();
        return this;
    }
}
```

**Usage**

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .withFakeId()
    .build();
```

::: tip
Use fake IDs when testing code that requires record IDs but doesn't need actual database records, such as Map operations or trigger handlers.
:::

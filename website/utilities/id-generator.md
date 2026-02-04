---
outline: deep
---

# IdGenerator

Generate valid-looking Salesforce IDs without database operations.

## IdGenerator.get

Get a fake ID for a specific SObject type.

**Signature**

```apex
public static Id get(SObjectType objectType);
```

**Traditional Apex**

```apex
// Cannot create valid IDs without database insert
Account acc = new Account(Name = 'Test');
insert acc;
Id accountId = acc.Id;
```

**Test Lib**

```apex
Id accountId = TestModule.IdGenerator.get(Account.SObjectType);
Id contactId = TestModule.IdGenerator.get(Contact.SObjectType);

Assert.isTrue(String.valueOf(accountId).startsWith('001'));
Assert.isTrue(String.valueOf(contactId).startsWith('003'));
```

## fakeId

Convenience static method for generating fake IDs.

**Signature**

```apex
public static Id fakeId(SObjectType objectType);
```

**Test Lib**

```apex
Id fakeId = TestModule.fakeId(Account.SObjectType);

Assert.isTrue(String.valueOf(fakeId).startsWith('001'));
```

## Unique IDs

Each call generates a unique, incrementing ID.

```apex
Id id1 = TestModule.IdGenerator.get(Account.SObjectType);
Id id2 = TestModule.IdGenerator.get(Account.SObjectType);
Id id3 = TestModule.IdGenerator.get(Account.SObjectType);

Assert.areNotEqual(id1, id2);
Assert.areNotEqual(id2, id3);
Assert.areNotEqual(id1, id3);
```

## Correct Key Prefix

IDs use the correct key prefix for each SObject type.

```apex
Id accountId = TestModule.IdGenerator.get(Account.SObjectType);   // 001...
Id contactId = TestModule.IdGenerator.get(Contact.SObjectType);   // 003...
Id oppId = TestModule.IdGenerator.get(Opportunity.SObjectType);   // 006...
Id leadId = TestModule.IdGenerator.get(Lead.SObjectType);         // 00Q...
```

## Use Cases

### Creating Mock Records Manually

```apex
Account acc = new Account(
    Id = TestModule.fakeId(Account.SObjectType),
    Name = 'Test Account'
);
```

### Testing with Maps

```apex
Id fakeId = TestModule.fakeId(Account.SObjectType);
Map<Id, String> accountNames = new Map<Id, String>{ fakeId => 'Test' };

Assert.isTrue(accountNames.containsKey(fakeId));
```

### Testing Trigger Context

```apex
Map<Id, Account> oldMap = new Map<Id, Account>();
Map<Id, Account> newMap = new Map<Id, Account>();

Id accId = TestModule.fakeId(Account.SObjectType);

oldMap.put(accId, new Account(Id = accId, Rating = 'Cold'));
newMap.put(accId, new Account(Id = accId, Rating = 'Hot'));

// Test trigger handler with mock context
AccountTriggerHandler.handleUpdate(oldMap, newMap);
```

::: tip
Use `IdGenerator` directly when you need fake IDs without using the full Mocker pattern, such as when creating records manually or setting up test maps.
:::

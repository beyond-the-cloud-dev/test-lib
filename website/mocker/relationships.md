---
outline: deep
---

# Relationships

Mock parent and child relationships without database operations.

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

## Parent Relationships

Use dot notation with `set()` to mock parent relationships.

**Signature**

```apex
Mocker set(String field, Object value);
```

**Traditional Apex**

```apex
// Cannot mock parent relationships without database queries
Contact con = [SELECT Id, Account.Name FROM Contact WHERE Id = :conId];
```

**Test Lib**

```apex
Contact con = (Contact) ContactTestModule.Mocker()
    .set('Account.Name', 'Parent Account')
    .build();

// con.Account.Name == 'Parent Account'
```

### Deep Nesting

```apex
Contact con = (Contact) ContactTestModule.Mocker()
    .set('Account.Name', 'Acme Corp')
    .set('Account.Parent.Name', 'Acme Holdings')
    .set('Account.Parent.Industry', 'Technology')
    .build();

Assert.areEqual('Acme Holdings', con.Account.Parent.Name);
```

## Multiple Child Relationships

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

## Convenience Methods

Create custom convenience methods for common relationships.

**Implementation**

```apex
public class AccountMocker extends TestModule.RecordMocker {
    public AccountMocker() {
        super(new Account(Name = 'Test Account'));
    }

    public AccountMocker withContacts(List<Contact> contacts) {
        super.setChildren('Contacts', contacts);
        return this;
    }

    public AccountMocker withParentName(String parentName) {
        super.set('Parent.Name', parentName);
        return this;
    }
}
```

**Usage**

```apex
List<Contact> contacts = (List<Contact>) ContactTestModule.Mocker().build(3);

Account acc = (Account) AccountTestModule.Mocker()
    .withContacts(contacts)
    .withParentName('Parent Corp')
    .build();
```

::: tip
Use relationship mocking to test code that processes query results with parent and child records, without needing actual database operations.
:::

---
outline: deep
---

# Set Fields

Set field values on mock records, including read-only and relationship fields.

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

## Read-Only Fields

Mocker can set fields that are normally read-only in Apex.

**CreatedDate**

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .set('CreatedDate', Datetime.newInstance(2025, 1, 15, 10, 30, 0))
    .build();

Assert.areEqual(Datetime.newInstance(2025, 1, 15, 10, 30, 0), acc.CreatedDate);
```

**Owner.Name**

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .set('Owner.Name', 'System Admin')
    .build();

Assert.areEqual('System Admin', acc.Owner.Name);
```

## Convenience Methods

Create custom convenience methods for common fields.

**Implementation**

```apex
public class AccountMocker extends TestModule.RecordMocker {
    public AccountMocker() {
        super(new Account(Name = 'Test Account'));
    }

    public AccountMocker withParentName(String parentName) {
        super.set('Parent.Name', parentName);
        return this;
    }
}
```

**Usage**

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .withParentName('Parent Corp')
    .build();
```

::: tip
Use dot notation to mock parent relationships. This is especially useful when testing code that accesses parent fields from query results.
:::

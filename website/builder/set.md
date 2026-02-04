---
outline: deep
---

# Set Fields

Set field values on records being built.

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

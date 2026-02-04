---
outline: deep
---

# Randomizers

Generate unique field values when creating multiple mock records.

## withRandomizer (RecordRandomizer)

Apply a randomizer that generates values for multiple fields.

**Signature**

```apex
Mocker withRandomizer(TestModule.RecordRandomizer randomizer);
```

**Test Lib**

```apex
List<SObject> accounts = AccountTestModule.Mocker()
    .withAccountRandomizer()
    .build(100);

// Each account has unique Name and cycling Industry
```

## withRandomizer (FieldRandomizer)

Apply a randomizer for a single field.

**Signature**

```apex
Mocker withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer);
```

**Test Lib**

```apex
List<SObject> accounts = AccountTestModule.Mocker()
    .withRandomizer(Account.Industry, new IndustryRandomizer())
    .build(10);
```

## ListRandomizer

Built-in randomizer that cycles through a list of values.

```apex
List<SObject> accounts = AccountTestModule.Mocker()
    .withRandomizer(Account.Industry,
        TestModule.ListRandomizer(new List<Object>{ 'A', 'B', 'C' }))
    .build(6);

// Industries: A, B, C, A, B, C
Assert.areEqual('A', accounts[0].get('Industry'));
Assert.areEqual('B', accounts[1].get('Industry'));
Assert.areEqual('C', accounts[2].get('Industry'));
Assert.areEqual('A', accounts[3].get('Industry'));
```

## Implementation Example

**FieldRandomizer**

```apex
public class IndustryRandomizer implements TestModule.FieldRandomizer {
    private List<String> industries = new List<String>{
        'Technology', 'Finance', 'Healthcare', 'Retail'
    };

    public Object generate(Integer index) {
        return industries[Math.mod(index, industries.size())];
    }
}
```

**RecordRandomizer**

```apex
public class AccountRandomizer implements TestModule.RecordRandomizer {
    public Map<SObjectField, TestModule.FieldRandomizer> randomizers() {
        return new Map<SObjectField, TestModule.FieldRandomizer>{
            Account.Name => new CompanyNameRandomizer(),
            Account.Industry => new IndustryRandomizer()
        };
    }
}
```

## Convenience Method

```apex
public class AccountMocker extends TestModule.RecordMocker {
    public AccountMocker() {
        super(new Account(Name = 'Test Account'));
    }

    public AccountMocker withRandomIndustry() {
        super.withRandomizer(Account.Industry, new IndustryRandomizer());
        return this;
    }

    public AccountMocker withAccountRandomizer() {
        super.withRandomizer(new AccountRandomizer());
        return this;
    }
}
```

::: tip
Randomizers work the same way in both Builder and Mocker. Use them when creating bulk mock data for testing aggregations or collections.
:::

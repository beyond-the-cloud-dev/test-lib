---
outline: deep
---

# Randomizers

Generate unique field values when creating multiple records.

## FieldRandomizer Interface

```apex
public interface FieldRandomizer {
    Object generate(Integer index);
}
```

## RecordRandomizer Interface

```apex
public interface RecordRandomizer {
    Map<SObjectField, TestModule.FieldRandomizer> randomizers();
}
```

## withRandomizer (RecordRandomizer)

Apply a randomizer that generates values for multiple fields.

**Signature**

```apex
Builder withRandomizer(TestModule.RecordRandomizer randomizer);
```

**Traditional Apex**

```apex
List<Account> accounts = new List<Account>();
List<String> industries = new List<String>{'Technology', 'Finance', 'Healthcare'};

for (Integer i = 0; i < 100; i++) {
    accounts.add(new Account(
        Name = 'Company ' + (i + 1),
        Industry = industries[Math.mod(i, industries.size())]
    ));
}
insert accounts;
```

**Test Lib**

```apex
List<SObject> accounts = AccountTestModule.Builder()
    .withAccountRandomizer()
    .buildAndInsert(100);
```

## withRandomizer (FieldRandomizer)

Apply a randomizer for a single field.

**Signature**

```apex
Builder withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer);
```

**Test Lib**

```apex
List<SObject> accounts = AccountTestModule.Builder()
    .withRandomizer(Account.Industry, new IndustryRandomizer())
    .buildAndInsert(10);
```

## ListRandomizer

Built-in randomizer that cycles through a list of values.

**Signature**

```apex
TestModule.ListRandomizer(List<Object> values)
```

**Test Lib**

```apex
List<SObject> accounts = AccountTestModule.Builder()
    .withRandomizer(Account.Industry,
        TestModule.ListRandomizer(new List<Object>{ 'Tech', 'Finance', 'Health' }))
    .build(6);

// Industries: Tech, Finance, Health, Tech, Finance, Health
```

## Implementing Randomizers

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

public class CompanyNameRandomizer implements TestModule.FieldRandomizer {
    public Object generate(Integer index) {
        return 'Company ' + (index + 1);
    }
}
```

::: tip
Use randomizers when creating bulk test data to avoid duplicate key violations and generate realistic data distributions.
:::

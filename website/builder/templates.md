---
outline: deep
---

# Templates

Define reusable record configurations for common test scenarios.

## Template Interface

```apex
public interface Template {
    SObject defaultTemplate();
    Map<String, SObject> templates();
}
```

## useTemplate

Apply a named template to the record being built.

**Signature**

```apex
Builder useTemplate(String templateName);
```

**Traditional Apex**

```apex
Account enterprise = new Account(
    Name = 'Enterprise Account',
    Industry = 'Technology',
    AnnualRevenue = 1000000
);
insert enterprise;

Account startup = new Account(
    Name = 'Startup Account',
    Industry = 'Technology',
    AnnualRevenue = 100000
);
insert startup;
```

**Test Lib**

```apex
Account enterprise = (Account) AccountTestModule.Builder()
    .enterprise()
    .buildAndInsert();

Account startup = (Account) AccountTestModule.Builder()
    .startup()
    .buildAndInsert();
```

## Implementing Templates

**Template Class**

```apex
public class Templates implements TestModule.Template {
    public SObject defaultTemplate() {
        return new Account(Name = 'Test Account', Industry = 'Technology');
    }

    public Map<String, SObject> templates() {
        return new Map<String, SObject>{
            'enterprise' => new Account(
                Name = 'Enterprise Account',
                Industry = 'Technology',
                AnnualRevenue = 1000000
            ),
            'startup' => new Account(
                Name = 'Startup Account',
                Industry = 'Technology',
                AnnualRevenue = 100000
            )
        };
    }
}
```

**Builder with Templates**

```apex
public class AccountBuilder extends TestModule.RecordBuilder {
    public AccountBuilder() {
        super(new Templates());
    }

    public AccountBuilder enterprise() {
        super.useTemplate('enterprise');
        return this;
    }

    public AccountBuilder startup() {
        super.useTemplate('startup');
        return this;
    }
}
```

## Template with Overrides

Templates can be combined with field overrides.

```apex
Account acc = (Account) AccountTestModule.Builder()
    .enterprise()
    .withName('Custom Enterprise Name')
    .buildAndInsert();

// Name: 'Custom Enterprise Name'
// AnnualRevenue: 1000000 (from template)
```

::: tip
Use templates for common business scenarios like `enterprise`, `startup`, `closedWon`, `prospecting`. This makes tests more readable and self-documenting.
:::

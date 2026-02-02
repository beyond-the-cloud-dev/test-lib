# Templates

Templates provide predefined field configurations for common test scenarios.

## Overview

Templates help you:

- Define standard test data configurations
- Create consistent test records
- Reduce code duplication
- Express business scenarios clearly

## Template Interface

```apex
public interface Template {
    SObject defaultTemplate();
    Map<String, SObject> templates();
}
```

### defaultTemplate()

Returns the default prototype used when no template is specified:

```apex
public SObject defaultTemplate() {
    return new Account(
        Name = 'Test Account',
        Industry = 'Technology'
    );
}
```

### templates()

Returns a map of named templates:

```apex
public Map<String, SObject> templates() {
    return new Map<String, SObject>{
        'enterprise' => new Account(...),
        'startup' => new Account(...)
    };
}
```

## Implementing Templates

### Basic Implementation

```apex
public class Templates implements TestModule.Template {

    public SObject defaultTemplate() {
        return new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
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

### Using Templates in Builder

```apex
public class AccountBuilder extends TestModule.RecordBuilder {

    public AccountBuilder() {
        super(new Templates());  // Pass templates to constructor
    }

    // Convenience methods for templates
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

## Using Templates

### Apply Template

```apex
Account acc = (Account) AccountTestModule.Builder()
    .enterprise()
    .buildAndInsert();

Assert.areEqual('Enterprise Account', acc.Name);
Assert.areEqual(1000000, acc.AnnualRevenue);
```

### Template with Overrides

Templates can be combined with field overrides:

```apex
Account acc = (Account) AccountTestModule.Builder()
    .enterprise()                           // Apply template
    .withName('Custom Enterprise Name')     // Override name
    .withIndustry('Finance')                // Override industry
    .buildAndInsert();

Assert.areEqual('Custom Enterprise Name', acc.Name);
Assert.areEqual('Finance', acc.Industry);
Assert.areEqual(1000000, acc.AnnualRevenue);  // From template
```

### Direct Template Access

```apex
public AccountBuilder useCustomTemplate(String templateName) {
    super.useTemplate(templateName);
    return this;
}

// Usage
AccountTestModule.Builder()
    .useTemplate('startup')
    .buildAndInsert();
```

## Real-World Examples

### Account Templates

From `AccountTestModule.cls`:

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

### Contact Templates

From `ContactTestModule.cls`:

```apex
public class Templates implements TestModule.Template {
    public SObject defaultTemplate() {
        return new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com'
        );
    }

    public Map<String, SObject> templates() {
        return new Map<String, SObject>{
            'business' => new Contact(
                FirstName = 'Business',
                LastName = 'Contact',
                Email = 'business.contact@example.com'
            ),
            'personal' => new Contact(
                FirstName = 'Personal',
                LastName = 'Contact',
                Email = 'personal.contact@example.com'
            )
        };
    }
}
```

### Opportunity Templates

From `OpportunityTestModule.cls`:

```apex
public class Templates implements TestModule.Template {
    public SObject defaultTemplate() {
        return new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
    }

    public Map<String, SObject> templates() {
        return new Map<String, SObject>{
            'prospecting' => new Opportunity(
                Name = 'Prospecting Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ),
            'closedWon' => new Opportunity(
                Name = 'Closed Won Opportunity',
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 100000
            )
        };
    }
}
```

## Error Handling

### Missing Template Configuration

If you call `useTemplate()` without configuring templates:

```apex
public AccountBuilder() {
    super(new Account(Name = 'Default'));  // No templates
}

// This throws TestModuleException
AccountTestModule.Builder()
    .useTemplate('enterprise')  // Error: Templates not configured
    .build();
```

### Template Not Found

If you request a template that doesn't exist:

```apex
AccountTestModule.Builder()
    .useTemplate('nonexistent')  // Error: Template "nonexistent" not found
    .build();
```

### Handling Errors

```apex
@IsTest
static void testInvalidTemplate() {
    Boolean exceptionThrown = false;
    try {
        AccountTestModule.Builder()
            .useTemplate('invalid')
            .build();
    } catch (TestModule.TestModuleException e) {
        exceptionThrown = true;
        Assert.isTrue(e.getMessage().contains('not found'));
    }
    Assert.isTrue(exceptionThrown);
}
```

## Templates with Mocker

Templates work the same way with Mocker when using the Template constructor:

```apex
public class AccountMocker extends TestModule.RecordMocker {
    public AccountMocker() {
        super(new Account(Name = 'Test Account', Industry = 'Technology'));
    }
}
```

## Best Practices

1. **Name templates clearly** - Use descriptive names like `enterprise`, `closedWon`, `business`
2. **Keep templates focused** - Each template should represent one scenario
3. **Allow overrides** - Templates set defaults; allow users to override
4. **Document templates** - Comment what each template represents
5. **Use consistent patterns** - Follow the same naming conventions across modules

[Next: Randomizers →](/randomizers)

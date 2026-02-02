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
        'startup' => new Account(...),
        'partner' => new Account(...)
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
            Industry = 'Technology',
            BillingCountry = 'USA'
        );
    }

    public Map<String, SObject> templates() {
        return new Map<String, SObject>{
            'enterprise' => new Account(
                Name = 'Enterprise Account',
                Industry = 'Technology',
                AnnualRevenue = 1000000,
                NumberOfEmployees = 500,
                Rating = 'Hot'
            ),
            'startup' => new Account(
                Name = 'Startup Account',
                Industry = 'Technology',
                AnnualRevenue = 100000,
                NumberOfEmployees = 10,
                Rating = 'Warm'
            ),
            'partner' => new Account(
                Name = 'Partner Account',
                Type = 'Partner',
                Industry = 'Consulting',
                Rating = 'Hot'
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

    public AccountBuilder partner() {
        super.useTemplate('partner');
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

System.assertEquals('Enterprise Account', acc.Name);
System.assertEquals(1000000, acc.AnnualRevenue);
System.assertEquals(500, acc.NumberOfEmployees);
```

### Template with Overrides

Templates can be combined with field overrides:

```apex
Account acc = (Account) AccountTestModule.Builder()
    .enterprise()                           // Apply template
    .withName('Custom Enterprise Name')     // Override name
    .withIndustry('Finance')                // Override industry
    .buildAndInsert();

System.assertEquals('Custom Enterprise Name', acc.Name);
System.assertEquals('Finance', acc.Industry);
System.assertEquals(1000000, acc.AnnualRevenue);  // From template
```

### Direct Template Access

```apex
public AccountBuilder useCustomTemplate(String templateName) {
    super.useTemplate(templateName);
    return this;
}

// Usage
AccountTestModule.Builder()
    .useCustomTemplate('partner')
    .buildAndInsert();
```

## Template Design Patterns

### By Business Scenario

```apex
public Map<String, SObject> templates() {
    return new Map<String, SObject>{
        // Size-based
        'enterprise' => new Account(AnnualRevenue = 1000000, NumberOfEmployees = 500),
        'mid-market' => new Account(AnnualRevenue = 500000, NumberOfEmployees = 100),
        'startup' => new Account(AnnualRevenue = 100000, NumberOfEmployees = 10),

        // Type-based
        'customer' => new Account(Type = 'Customer', Rating = 'Hot'),
        'prospect' => new Account(Type = 'Prospect', Rating = 'Warm'),
        'partner' => new Account(Type = 'Partner')
    };
}
```

### By Test Context

```apex
public Map<String, SObject> templates() {
    return new Map<String, SObject>{
        // For integration tests
        'integration' => new Account(
            Name = 'Integration Test Account',
            BillingStreet = '123 Test St',
            BillingCity = 'Test City',
            BillingState = 'CA',
            BillingPostalCode = '94105',
            BillingCountry = 'USA'
        ),

        // For validation tests
        'minimal' => new Account(Name = 'Minimal Account'),

        // For workflow tests
        'workflow-trigger' => new Account(
            Name = 'Workflow Test',
            Rating = 'Cold',
            Industry = 'Technology'
        )
    };
}
```

### Opportunity Templates

```apex
public class OpportunityTemplates implements TestModule.Template {

    public SObject defaultTemplate() {
        return new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
    }

    public Map<String, SObject> templates() {
        return new Map<String, SObject>{
            'won' => new Opportunity(
                Name = 'Won Deal',
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Probability = 100
            ),
            'lost' => new Opportunity(
                Name = 'Lost Deal',
                StageName = 'Closed Lost',
                CloseDate = Date.today(),
                Probability = 0
            ),
            'negotiation' => new Opportunity(
                Name = 'In Negotiation',
                StageName = 'Negotiation/Review',
                CloseDate = Date.today().addDays(14),
                Probability = 75
            ),
            'big-deal' => new Opportunity(
                Name = 'Big Deal',
                Amount = 500000,
                StageName = 'Qualification',
                CloseDate = Date.today().addDays(90)
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
    try {
        AccountTestModule.Builder()
            .useTemplate('invalid')
            .build();
        System.assert(false, 'Should have thrown exception');
    } catch (TestModule.TestModuleException e) {
        System.assert(e.getMessage().contains('not found'));
    }
}
```

## Templates with Mocker

Templates work the same way with Mocker:

```apex
public class AccountMocker extends TestModule.RecordMocker {
    public AccountMocker() {
        super(new Templates());  // Same templates
    }
}

// Usage
Account acc = (Account) AccountTestModule.Mocker()
    .enterprise()
    .setFakeId()
    .build();
```

## Complete Example

```apex
@IsTest
public class AccountTestModule {

    public static AccountBuilder Builder() {
        return new AccountBuilder();
    }

    public static AccountMocker Mocker() {
        return new AccountMocker();
    }

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

        public AccountBuilder partner() {
            super.useTemplate('partner');
            return this;
        }
    }

    public class AccountMocker extends TestModule.RecordMocker {
        public AccountMocker() {
            super(new Templates());
        }

        // Same template methods...
    }

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
                    AnnualRevenue = 1000000,
                    NumberOfEmployees = 500
                ),
                'startup' => new Account(
                    Name = 'Startup Account',
                    Industry = 'Technology',
                    AnnualRevenue = 100000,
                    NumberOfEmployees = 10
                ),
                'partner' => new Account(
                    Name = 'Partner Account',
                    Type = 'Partner',
                    Industry = 'Consulting'
                )
            };
        }
    }
}
```

## Best Practices

1. **Name templates clearly** - Use descriptive names like `enterprise`, `won`, `minimal`
2. **Keep templates focused** - Each template should represent one scenario
3. **Allow overrides** - Templates set defaults; allow users to override
4. **Document templates** - Comment what each template represents
5. **Share templates** - Use the same Templates class for Builder and Mocker

[Next: Randomizers →](/randomizers)

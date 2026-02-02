# Builder Pattern

The Builder pattern creates real SObject records that can be inserted into the database.

## Overview

Use `Builder` when you need records with actual IDs in the database:

- Integration tests that verify triggers
- Tests that require SOQL queries
- Tests that verify DML operations
- End-to-end workflow tests

## RecordBuilder Base Class

All builders extend `TestModule.RecordBuilder`:

```apex
public class AccountBuilder extends TestModule.RecordBuilder {
    public AccountBuilder() {
        super(new Account(Name = 'Default Name'));
    }
}
```

### Constructor Options

**With Prototype:**

```apex
public AccountBuilder() {
    super(new Account(
        Name = 'Default Account',
        Industry = 'Technology'
    ));
}
```

**With Templates:**

```apex
public AccountBuilder() {
    super(new Templates());
}
```

## Building Records

### Single Record (No DML)

```apex
Account acc = (Account) AccountTestModule.Builder()
    .withName('Acme Corp')
    .build();

// acc.Id is null - not inserted
System.assertEquals(null, acc.Id);
```

### Single Record (With Insert)

```apex
Account acc = (Account) AccountTestModule.Builder()
    .withName('Acme Corp')
    .buildAndInsert();

// acc.Id is set - record is in database
System.assertNotEquals(null, acc.Id);
```

### Multiple Records (No DML)

```apex
List<Account> accounts = AccountTestModule.Builder()
    .withIndustry('Technology')
    .build(10);

// 10 records, none inserted
System.assertEquals(10, accounts.size());
System.assertEquals(null, accounts[0].Id);
```

### Multiple Records (With Insert)

```apex
List<Account> accounts = AccountTestModule.Builder()
    .withIndustry('Technology')
    .buildAndInsert(10);

// 10 records, all inserted
System.assertEquals(10, accounts.size());
System.assertNotEquals(null, accounts[0].Id);
```

## Setting Field Values

### Using SObjectField Token

Type-safe approach with compile-time validation:

```apex
public AccountBuilder withName(String name) {
    super.set(Account.Name, name);
    return this;
}

public AccountBuilder withRevenue(Decimal revenue) {
    super.set(Account.AnnualRevenue, revenue);
    return this;
}
```

### Using String Field Name

For dynamic field access:

```apex
public AccountBuilder withField(String fieldName, Object value) {
    super.set(fieldName, value);
    return this;
}
```

## Using Templates

Templates provide predefined field configurations:

### Defining Templates

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
                AnnualRevenue = 1000000,
                NumberOfEmployees = 500
            ),
            'startup' => new Account(
                Name = 'Startup Account',
                Industry = 'Technology',
                AnnualRevenue = 100000,
                NumberOfEmployees = 10
            )
        };
    }
}
```

### Using Templates in Builder

```apex
public AccountBuilder() {
    super(new Templates());  // Constructor with templates
}

public AccountBuilder enterprise() {
    super.useTemplate('enterprise');
    return this;
}

public AccountBuilder startup() {
    super.useTemplate('startup');
    return this;
}
```

### Template with Overrides

```apex
Account acc = (Account) AccountTestModule.Builder()
    .enterprise()                      // Apply template
    .withName('Custom Enterprise')     // Override name
    .buildAndInsert();

// Has template values plus custom name
System.assertEquals('Custom Enterprise', acc.Name);
System.assertEquals(1000000, acc.AnnualRevenue);
```

## Using Randomizers

Randomizers generate unique values for each record:

### Single Field Randomizer

```apex
public AccountBuilder withRandomIndustry() {
    super.withRandomizer(Account.Industry, new IndustryRandomizer());
    return this;
}

public class IndustryRandomizer implements TestModule.SingleFieldRandomizer {
    private List<String> industries = new List<String>{
        'Technology', 'Finance', 'Healthcare', 'Retail'
    };

    public Object generate(Integer index) {
        return industries[Math.mod(index, industries.size())];
    }
}
```

### Record Randomizer

For multiple fields:

```apex
public AccountBuilder withAccountRandomizer() {
    super.withRandomizer(new AccountRandomizer());
    return this;
}

public class AccountRandomizer extends TestModule.RecordRandomizer {
    public AccountRandomizer() {
        this.add(Account.Name, new NameRandomizer());
        this.add(Account.Industry, new IndustryRandomizer());
    }
}
```

### Using Randomizers

```apex
List<Account> accounts = AccountTestModule.Builder()
    .withAccountRandomizer()
    .buildAndInsert(100);

// Each account has unique name and cycling industry
System.assertEquals('Company 1', accounts[0].Name);
System.assertEquals('Company 2', accounts[1].Name);
```

## Complete Builder Example

```apex
@IsTest
public class AccountTestModule implements TestModule.BuilderProvider {

    public static AccountBuilder Builder() {
        return new AccountBuilder();
    }

    public class AccountBuilder extends TestModule.RecordBuilder {

        public AccountBuilder() {
            super(new Templates());
        }

        // Field setters
        public AccountBuilder withName(String name) {
            super.set(Account.Name, name);
            return this;
        }

        public AccountBuilder withIndustry(String industry) {
            super.set(Account.Industry, industry);
            return this;
        }

        public AccountBuilder withRevenue(Decimal revenue) {
            super.set(Account.AnnualRevenue, revenue);
            return this;
        }

        // Template shortcuts
        public AccountBuilder enterprise() {
            super.useTemplate('enterprise');
            return this;
        }

        public AccountBuilder startup() {
            super.useTemplate('startup');
            return this;
        }

        // Randomizer shortcuts
        public AccountBuilder withRandomIndustry() {
            super.withRandomizer(Account.Industry, new IndustryRandomizer());
            return this;
        }

        public AccountBuilder withAccountRandomizer() {
            super.withRandomizer(new AccountRandomizer());
            return this;
        }
    }

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

    public class IndustryRandomizer implements TestModule.SingleFieldRandomizer {
        private List<String> industries = new List<String>{
            'Technology', 'Finance', 'Healthcare', 'Retail'
        };

        public Object generate(Integer index) {
            return industries[Math.mod(index, industries.size())];
        }
    }

    public class NameRandomizer implements TestModule.SingleFieldRandomizer {
        public Object generate(Integer index) {
            return 'Company ' + (index + 1);
        }
    }

    public class AccountRandomizer extends TestModule.RecordRandomizer {
        public AccountRandomizer() {
            this.add(Account.Name, new NameRandomizer());
            this.add(Account.Industry, new IndustryRandomizer());
        }
    }
}
```

## Usage Examples

```apex
@IsTest
private class AccountServiceTest {

    @IsTest
    static void shouldCreateEnterpriseAccount() {
        Account acc = (Account) AccountTestModule.Builder()
            .enterprise()
            .withName('Acme Enterprise')
            .buildAndInsert();

        System.assertEquals('Acme Enterprise', acc.Name);
        System.assertEquals(1000000, acc.AnnualRevenue);
    }

    @IsTest
    static void shouldCreateBulkAccounts() {
        List<Account> accounts = AccountTestModule.Builder()
            .withAccountRandomizer()
            .buildAndInsert(50);

        System.assertEquals(50, accounts.size());

        // Verify unique names
        Set<String> names = new Set<String>();
        for (Account acc : accounts) {
            names.add(acc.Name);
        }
        System.assertEquals(50, names.size());
    }
}
```

[Next: Mocker Pattern →](/mocker)

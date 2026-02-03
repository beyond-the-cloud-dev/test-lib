# Randomizers

Randomizers generate unique field values when creating multiple records.

## Overview

Randomizers help you:

- Create bulk test data with unique values
- Avoid duplicate key violations
- Generate realistic test data
- Cycle through predefined value sets

## FieldRandomizer Interface

For generating values for a single field:

```apex
public interface FieldRandomizer {
    Object generate(Integer index);
}
```

The `index` parameter indicates which record is being generated (0-based).

### Basic Implementation

```apex
public class CompanyNameRandomizer implements TestModule.FieldRandomizer {
    public Object generate(Integer index) {
        return 'Company ' + (index + 1);
    }
}

// Generates: Company 1, Company 2, Company 3, ...
```

### Cycling Through Values

```apex
public class IndustryRandomizer implements TestModule.FieldRandomizer {
    private List<String> industries = new List<String>{
        'Technology', 'Finance', 'Healthcare', 'Retail'
    };

    public Object generate(Integer index) {
        return industries[Math.mod(index, industries.size())];
    }
}

// Generates: Technology, Finance, Healthcare, Retail, Technology, ...
```

## RecordRandomizer Interface

For generating values for multiple fields at once:

```apex
public interface RecordRandomizer {
    Map<SObjectField, TestModule.FieldRandomizer> randomizers();
}
```

### Implementation

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

## Built-in ListRandomizer

The `TestModule.ListRandomizer` cycles through a list of values:

```apex
// Using static factory method
TestModule.ListRandomizer(new List<Object>{ 'Technology', 'Finance', 'Healthcare' })

// Usage
List<SObject> accounts = AccountTestModule.Builder()
    .withRandomizer(Account.Industry,
        TestModule.ListRandomizer(new List<Object>{ 'Tech', 'Finance', 'Health' }))
    .build(6);

// Generates: Tech, Finance, Health, Tech, Finance, Health
Assert.areEqual('Tech', accounts[0].get('Industry'));
Assert.areEqual('Finance', accounts[1].get('Industry'));
Assert.areEqual('Health', accounts[2].get('Industry'));
Assert.areEqual('Tech', accounts[3].get('Industry'));
```

## Using Randomizers

### In Builder

```apex
public class AccountBuilder extends TestModule.RecordBuilder {

    public AccountBuilder withRandomIndustry() {
        super.withRandomizer(Account.Industry, new IndustryRandomizer());
        return this;
    }

    public AccountBuilder withAccountRandomizer() {
        super.withRandomizer(new AccountRandomizer());
        return this;
    }
}

// Usage
List<SObject> accounts = AccountTestModule.Builder()
    .withAccountRandomizer()
    .buildAndInsert(100);
```

### In Mocker

```apex
public class AccountMocker extends TestModule.RecordMocker {

    public AccountMocker withRandomIndustry() {
        super.withRandomizer(Account.Industry, new IndustryRandomizer());
        return this;
    }
}

// Usage
List<SObject> accounts = AccountTestModule.Mocker()
    .withRandomIndustry()
    .build(10);
```

### Combining Randomizers

You can combine a RecordRandomizer with additional FieldRandomizers:

```apex
List<SObject> accounts = AccountTestModule.Builder()
    .withRandomizer(new AccountRandomizer())
    .withRandomizer(Account.Industry,
        TestModule.ListRandomizer(new List<Object>{ 'Override' }))
    .build(2);

// FieldRandomizer overrides the RecordRandomizer for Industry
Assert.areEqual('Company 0', accounts[0].get('Name'));  // From AccountRandomizer
Assert.areEqual('Override', accounts[0].get('Industry'));  // From ListRandomizer
```

## Common Randomizer Patterns

### Sequential Names

```apex
public class CompanyNameRandomizer implements TestModule.FieldRandomizer {
    public Object generate(Integer index) {
        return 'Company ' + (index + 1);
    }
}

// Company 1, Company 2, Company 3...
```

### Email Generator

```apex
public class EmailRandomizer implements TestModule.FieldRandomizer {
    private String domain = 'example.com';

    public Object generate(Integer index) {
        return 'user' + (index + 1) + '@' + domain;
    }
}

// user1@example.com, user2@example.com...
```

### Amount Generator

```apex
public class AmountRandomizer implements TestModule.FieldRandomizer {
    public Object generate(Integer index) {
        return (index + 1) * 50000;
    }
}

// 50000, 100000, 150000...
```

### First/Last Name Randomizers

```apex
public class FirstNameRandomizer implements TestModule.FieldRandomizer {
    private List<String> firstNames = new List<String>{
        'John', 'Jane', 'Bob', 'Alice'
    };

    public Object generate(Integer index) {
        return firstNames[Math.mod(index, firstNames.size())];
    }
}

public class LastNameRandomizer implements TestModule.FieldRandomizer {
    public Object generate(Integer index) {
        return 'Contact ' + (index + 1);
    }
}
```

## Complete Example

```apex
@IsTest
public class ContactTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {

    public static ContactBuilder Builder() {
        return new ContactBuilder();
    }

    public static ContactMocker Mocker() {
        return new ContactMocker();
    }

    public class ContactBuilder extends TestModule.RecordBuilder {
        public ContactBuilder() {
            super(new Templates());
        }

        public ContactBuilder withContactRandomizer() {
            super.withRandomizer(new ContactRandomizer());
            return this;
        }
    }

    public class ContactMocker extends TestModule.RecordMocker {
        public ContactMocker() {
            super(new Contact(FirstName = 'Test', LastName = 'Contact'));
        }

        public ContactMocker withContactRandomizer() {
            super.withRandomizer(new ContactRandomizer());
            return this;
        }
    }

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

    public class ContactRandomizer implements TestModule.RecordRandomizer {
        public Map<SObjectField, TestModule.FieldRandomizer> randomizers() {
            return new Map<SObjectField, TestModule.FieldRandomizer>{
                Contact.FirstName => new FirstNameRandomizer(),
                Contact.LastName => new LastNameRandomizer()
            };
        }
    }

    public class FirstNameRandomizer implements TestModule.FieldRandomizer {
        private List<String> firstNames = new List<String>{
            'John', 'Jane', 'Bob', 'Alice'
        };

        public Object generate(Integer index) {
            return firstNames[Math.mod(index, firstNames.size())];
        }
    }

    public class LastNameRandomizer implements TestModule.FieldRandomizer {
        public Object generate(Integer index) {
            return 'Contact ' + (index + 1);
        }
    }
}
```

## Usage Examples

### Bulk Account Creation

```apex
@IsTest
static void testBulkAccounts() {
    List<SObject> accounts = AccountTestModule.Builder()
        .withAccountRandomizer()
        .buildAndInsert(100);

    Assert.areEqual(100, accounts.size());
    Assert.areEqual('Company 1', accounts[0].get('Name'));
    Assert.areEqual('Company 100', accounts[99].get('Name'));
}
```

### Creating Related Records

```apex
@IsTest
static void testRelatedRecords() {
    Account acc = (Account) AccountTestModule.Builder()
        .enterprise()
        .buildAndInsert();

    List<SObject> contacts = ContactTestModule.Builder()
        .set(Contact.AccountId, acc.Id)
        .withContactRandomizer()
        .buildAndInsert(5);

    Assert.areEqual(5, contacts.size());
    // John Contact 1, Jane Contact 2, Bob Contact 3, Alice Contact 4, John Contact 5
}
```

## Best Practices

1. **Keep randomizers simple** - One responsibility per randomizer
2. **Use meaningful values** - Generate realistic data
3. **Consider uniqueness** - Ensure generated values don't cause duplicates
4. **Make reusable** - Create generic randomizers for common patterns
5. **Implement RecordRandomizer** - When you need to randomize multiple related fields

[API Reference →](/api)

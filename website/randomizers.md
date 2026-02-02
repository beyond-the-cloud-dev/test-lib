# Randomizers

Randomizers generate unique field values when creating multiple records.

## Overview

Randomizers help you:

- Create bulk test data with unique values
- Avoid duplicate key violations
- Generate realistic test data
- Cycle through predefined value sets

## SingleFieldRandomizer Interface

For generating values for a single field:

```apex
public interface SingleFieldRandomizer {
    Object generate(Integer index);
}
```

The `index` parameter indicates which record is being generated (0-based).

### Basic Implementation

```apex
public class NameRandomizer implements TestModule.SingleFieldRandomizer {
    public Object generate(Integer index) {
        return 'Company ' + (index + 1);
    }
}

// Generates: Company 1, Company 2, Company 3, ...
```

### Cycling Through Values

```apex
public class IndustryRandomizer implements TestModule.SingleFieldRandomizer {
    private List<String> industries = new List<String>{
        'Technology', 'Finance', 'Healthcare', 'Retail'
    };

    public Object generate(Integer index) {
        return industries[Math.mod(index, industries.size())];
    }
}

// Generates: Technology, Finance, Healthcare, Retail, Technology, ...
```

## Randomizer Interface

For generating multiple field values at once:

```apex
public interface Randomizer {
    Map<SObjectField, Object> generate(Integer index);
}
```

### Direct Implementation

```apex
public class AccountRandomizer implements TestModule.Randomizer {
    public Map<SObjectField, Object> generate(Integer index) {
        return new Map<SObjectField, Object>{
            Account.Name => 'Company ' + (index + 1),
            Account.Industry => getIndustry(index),
            Account.AnnualRevenue => (index + 1) * 100000
        };
    }

    private String getIndustry(Integer index) {
        List<String> industries = new List<String>{
            'Technology', 'Finance', 'Healthcare'
        };
        return industries[Math.mod(index, industries.size())];
    }
}
```

## RecordRandomizer Class

A helper class for composing multiple SingleFieldRandomizers:

```apex
public class AccountRandomizer extends TestModule.RecordRandomizer {
    public AccountRandomizer() {
        this.add(Account.Name, new NameRandomizer());
        this.add(Account.Industry, new IndustryRandomizer());
        this.add(Account.AnnualRevenue, new RevenueRandomizer());
    }
}
```

### Chaining Randomizers

```apex
public class FullAccountRandomizer extends TestModule.RecordRandomizer {
    public FullAccountRandomizer() {
        // Base randomizer
        this.setParent(new BasicAccountRandomizer());

        // Additional fields
        this.add(Account.Phone, new PhoneRandomizer());
        this.add(Account.Website, new WebsiteRandomizer());
    }
}
```

## Built-in ListRandomizer

Cycles through a predefined list of values:

```apex
new TestModule.ListRandomizer(new List<Object>{
    'Technology', 'Finance', 'Healthcare', 'Retail'
})

// Usage
AccountTestModule.Builder()
    .withRandomizer(Account.Industry,
        new TestModule.ListRandomizer(new List<Object>{
            'Technology', 'Finance', 'Healthcare'
        })
    )
    .build(6);

// Generates: Technology, Finance, Healthcare, Technology, Finance, Healthcare
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
List<Account> accounts = AccountTestModule.Builder()
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
List<Account> accounts = AccountTestModule.Mocker()
    .withRandomIndustry()
    .build(10);
```

## Common Randomizer Patterns

### Sequential Names

```apex
public class CompanyNameRandomizer implements TestModule.SingleFieldRandomizer {
    private String prefix;

    public CompanyNameRandomizer() {
        this.prefix = 'Company';
    }

    public CompanyNameRandomizer(String prefix) {
        this.prefix = prefix;
    }

    public Object generate(Integer index) {
        return prefix + ' ' + (index + 1);
    }
}

// Company 1, Company 2, Company 3...
// or with custom prefix:
// Acme 1, Acme 2, Acme 3...
```

### Email Generator

```apex
public class EmailRandomizer implements TestModule.SingleFieldRandomizer {
    private String domain;

    public EmailRandomizer() {
        this.domain = 'example.com';
    }

    public EmailRandomizer(String domain) {
        this.domain = domain;
    }

    public Object generate(Integer index) {
        return 'user' + (index + 1) + '@' + domain;
    }
}

// user1@example.com, user2@example.com...
```

### Phone Number Generator

```apex
public class PhoneRandomizer implements TestModule.SingleFieldRandomizer {
    public Object generate(Integer index) {
        String areaCode = String.valueOf(100 + Math.mod(index, 900)).leftPad(3, '0');
        String prefix = String.valueOf(100 + Math.mod(index * 7, 900)).leftPad(3, '0');
        String suffix = String.valueOf(1000 + index).leftPad(4, '0');
        return '(' + areaCode + ') ' + prefix + '-' + suffix;
    }
}

// (100) 100-1000, (101) 107-1001...
```

### Date Generator

```apex
public class CloseDateRandomizer implements TestModule.SingleFieldRandomizer {
    private Date baseDate;
    private Integer dayIncrement;

    public CloseDateRandomizer() {
        this.baseDate = Date.today();
        this.dayIncrement = 7;
    }

    public Object generate(Integer index) {
        return baseDate.addDays(index * dayIncrement);
    }
}

// Today, Today+7, Today+14, Today+21...
```

### Amount Generator

```apex
public class AmountRandomizer implements TestModule.SingleFieldRandomizer {
    private Decimal baseAmount;
    private Decimal multiplier;

    public AmountRandomizer() {
        this.baseAmount = 10000;
        this.multiplier = 1.5;
    }

    public Object generate(Integer index) {
        return baseAmount * Math.pow(multiplier, index);
    }
}

// 10000, 15000, 22500, 33750...
```

### Picklist Cycler

```apex
public class StageRandomizer implements TestModule.SingleFieldRandomizer {
    private List<String> stages = new List<String>{
        'Prospecting',
        'Qualification',
        'Needs Analysis',
        'Value Proposition',
        'Negotiation',
        'Closed Won'
    };

    public Object generate(Integer index) {
        return stages[Math.mod(index, stages.size())];
    }
}
```

## Composite Randomizer Example

```apex
public class FullContactRandomizer extends TestModule.RecordRandomizer {
    public FullContactRandomizer() {
        this.add(Contact.FirstName, new FirstNameRandomizer());
        this.add(Contact.LastName, new LastNameRandomizer());
        this.add(Contact.Email, new EmailRandomizer());
        this.add(Contact.Phone, new PhoneRandomizer());
        this.add(Contact.Title, new TitleRandomizer());
    }
}

public class FirstNameRandomizer implements TestModule.SingleFieldRandomizer {
    private List<String> names = new List<String>{
        'John', 'Jane', 'Bob', 'Alice', 'Charlie', 'Diana'
    };

    public Object generate(Integer index) {
        return names[Math.mod(index, names.size())];
    }
}

public class LastNameRandomizer implements TestModule.SingleFieldRandomizer {
    private List<String> names = new List<String>{
        'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia'
    };

    public Object generate(Integer index) {
        return names[Math.mod(index, names.size())];
    }
}

public class TitleRandomizer implements TestModule.SingleFieldRandomizer {
    private List<String> titles = new List<String>{
        'CEO', 'CTO', 'CFO', 'VP Sales', 'Director', 'Manager'
    };

    public Object generate(Integer index) {
        return titles[Math.mod(index, titles.size())];
    }
}
```

## Usage Examples

### Bulk Account Creation

```apex
@IsTest
static void testBulkAccounts() {
    List<Account> accounts = AccountTestModule.Builder()
        .withAccountRandomizer()
        .buildAndInsert(100);

    // Verify unique names
    Set<String> names = new Set<String>();
    for (Account acc : accounts) {
        names.add(acc.Name);
    }
    System.assertEquals(100, names.size());
}
```

### Mixed Randomizers

```apex
@IsTest
static void testMixedRandomizers() {
    List<Account> accounts = AccountTestModule.Builder()
        .enterprise()                    // Base template
        .withRandomizer(Account.Name,    // Override name
            new CompanyNameRandomizer('Enterprise'))
        .withRandomIndustry()            // Random industry
        .buildAndInsert(10);

    System.assertEquals('Enterprise 1', accounts[0].Name);
    System.assertEquals('Enterprise 2', accounts[1].Name);
}
```

### Creating Related Records

```apex
@IsTest
static void testRelatedRecords() {
    Account acc = (Account) AccountTestModule.Builder()
        .enterprise()
        .buildAndInsert();

    List<Contact> contacts = ContactTestModule.Builder()
        .withAccount(acc.Id)
        .withRandomizer(new FullContactRandomizer())
        .buildAndInsert(5);

    System.assertEquals(5, contacts.size());
    // Each contact has unique name, email, phone, title
}
```

## Best Practices

1. **Keep randomizers simple** - One responsibility per randomizer
2. **Use meaningful values** - Generate realistic data
3. **Consider uniqueness** - Ensure generated values don't cause duplicates
4. **Make reusable** - Create generic randomizers for common patterns
5. **Test your randomizers** - Verify they generate expected values

[API Reference →](/api)

# Examples

Practical examples using Test Lib.

## Basic Builder Usage

### Single Record

```apex
@IsTest
static void testCreateAccount() {
    Account acc = (Account) AccountTestModule.Builder()
        .withName('Acme Corporation')
        .withIndustry('Technology')
        .buildAndInsert();

    System.assertNotEquals(null, acc.Id);
    System.assertEquals('Acme Corporation', acc.Name);
}
```

### Multiple Records

```apex
@IsTest
static void testCreateMultipleAccounts() {
    List<Account> accounts = AccountTestModule.Builder()
        .withIndustry('Technology')
        .buildAndInsert(5);

    System.assertEquals(5, accounts.size());
    for (Account acc : accounts) {
        System.assertEquals('Technology', acc.Industry);
    }
}
```

### Using Templates

```apex
@IsTest
static void testEnterpriseAccount() {
    Account acc = (Account) AccountTestModule.Builder()
        .enterprise()
        .buildAndInsert();

    System.assertEquals('Enterprise Account', acc.Name);
    System.assertEquals(1000000, acc.AnnualRevenue);
}

@IsTest
static void testStartupAccount() {
    Account acc = (Account) AccountTestModule.Builder()
        .startup()
        .buildAndInsert();

    System.assertEquals('Startup Account', acc.Name);
    System.assertEquals(100000, acc.AnnualRevenue);
}
```

## Randomizers

### Single Field Randomizer

```apex
@IsTest
static void testRandomIndustry() {
    List<Account> accounts = AccountTestModule.Builder()
        .withRandomIndustry()
        .buildAndInsert(4);

    // Industries cycle through: Technology, Finance, Healthcare, Retail
    System.assertEquals('Technology', accounts[0].Industry);
    System.assertEquals('Finance', accounts[1].Industry);
    System.assertEquals('Healthcare', accounts[2].Industry);
    System.assertEquals('Retail', accounts[3].Industry);
}
```

### Record Randomizer

```apex
@IsTest
static void testRecordRandomizer() {
    List<Account> accounts = AccountTestModule.Builder()
        .withAccountRandomizer()
        .buildAndInsert(3);

    // Each account has unique name and industry
    System.assertEquals('Company 1', accounts[0].Name);
    System.assertEquals('Company 2', accounts[1].Name);
    System.assertEquals('Company 3', accounts[2].Name);
}
```

### Custom Randomizer

```apex
public class EmailRandomizer implements TestModule.FieldRandomizer {
    public Object generate(Integer index) {
        return 'user' + (index + 1) + '@example.com';
    }
}

@IsTest
static void testCustomRandomizer() {
    List<Contact> contacts = ContactTestModule.Builder()
        .withRandomizer(Contact.Email, new EmailRandomizer())
        .buildAndInsert(3);

    System.assertEquals('user1@example.com', contacts[0].Email);
    System.assertEquals('user2@example.com', contacts[1].Email);
    System.assertEquals('user3@example.com', contacts[2].Email);
}
```

## Mocker Usage

### Basic Mock

```apex
@IsTest
static void testMockAccount() {
    Account acc = (Account) AccountTestModule.Mocker()
        .set(Account.Name, 'Mock Account')
        .build();

    // No database operation - acc.Id is null
    System.assertEquals(null, acc.Id);
    System.assertEquals('Mock Account', acc.Name);
}
```

### Mock with Fake ID

```apex
@IsTest
static void testMockWithFakeId() {
    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .build();

    // Has a valid-looking ID without database insert
    System.assertNotEquals(null, acc.Id);
    System.assert(String.valueOf(acc.Id).startsWith('001'));
}
```

### Mock Parent Relationship

```apex
@IsTest
static void testMockParentRelationship() {
    Account acc = (Account) AccountTestModule.Mocker()
        .withParentName('Parent Corporation')
        .build();

    // Parent relationship is populated
    System.assertEquals('Parent Corporation', acc.Parent.Name);
}
```

### Mock Child Relationships

```apex
@IsTest
static void testMockChildRelationship() {
    List<Contact> contacts = ContactTestModule.Mocker()
        .set(Contact.FirstName, 'John')
        .build(3);

    Account acc = (Account) AccountTestModule.Mocker()
        .withContacts(contacts)
        .build();

    // Child relationship is populated
    System.assertEquals(3, acc.Contacts.size());
}
```

## Related Records

### Account with Contacts

```apex
@IsTest
static void testAccountWithContacts() {
    // Create Account
    Account acc = (Account) AccountTestModule.Builder()
        .withName('Acme Corp')
        .buildAndInsert();

    // Create related Contacts
    List<Contact> contacts = ContactTestModule.Builder()
        .withAccount(acc.Id)
        .buildAndInsert(3);

    // Verify
    System.assertEquals(3, [SELECT COUNT() FROM Contact WHERE AccountId = :acc.Id]);
}
```

### Opportunity with Account

```apex
@IsTest
static void testOpportunityWithAccount() {
    Account acc = (Account) AccountTestModule.Builder()
        .enterprise()
        .buildAndInsert();

    Opportunity opp = (Opportunity) OpportunityTestModule.Builder()
        .withAccount(acc.Id)
        .withAmount(50000)
        .withCloseDate(Date.today().addDays(30))
        .buildAndInsert();

    System.assertEquals(acc.Id, opp.AccountId);
}
```

## Unit Testing with Mocker

### Testing Service Logic

```apex
@IsTest
static void testCalculateExpectedRevenue() {
    // Create mock opportunity without database
    Opportunity opp = (Opportunity) OpportunityTestModule.Mocker()
        .setFakeId()
        .set(Opportunity.Amount, 100000)
        .set(Opportunity.Probability, 80)
        .build();

    // Test pure business logic
    Decimal expected = RevenueCalculator.calculateExpected(opp);

    System.assertEquals(80000, expected);
}
```

### Testing Trigger Logic

```apex
@IsTest
static void testAccountTriggerLogic() {
    // Create mock account
    Account oldAcc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .set(Account.Rating, 'Cold')
        .build();

    Account newAcc = (Account) AccountTestModule.Mocker()
        .set(Account.Id, oldAcc.Id)
        .set(Account.Rating, 'Hot')
        .build();

    // Test trigger logic
    Boolean ratingChanged = AccountTriggerHandler.hasRatingChanged(oldAcc, newAcc);

    System.assert(ratingChanged);
}
```

### Testing Selector Results

```apex
@IsTest
static void testProcessQueryResults() {
    // Mock query results with relationships
    List<Contact> contacts = ContactTestModule.Mocker().build(2);

    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .withContacts(contacts)
        .withParentName('Holding Company')
        .build();

    // Test processing logic
    AccountDTO dto = AccountMapper.toDTO(acc);

    System.assertEquals(2, dto.contactCount);
    System.assertEquals('Holding Company', dto.parentName);
}
```

## Template Implementation

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
            ),
            'partner' => new Account(
                Name = 'Partner Account',
                Type = 'Partner',
                Industry = 'Consulting'
            )
        };
    }
}
```

### Using Templates

```apex
@IsTest
static void testTemplates() {
    Account enterprise = (Account) AccountTestModule.Builder()
        .enterprise()
        .buildAndInsert();

    Account startup = (Account) AccountTestModule.Builder()
        .startup()
        .buildAndInsert();

    System.assertEquals(1000000, enterprise.AnnualRevenue);
    System.assertEquals(100000, startup.AnnualRevenue);
}
```

## Complete Test Module Example

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

        public ContactBuilder withFirstName(String firstName) {
            super.set(Contact.FirstName, firstName);
            return this;
        }

        public ContactBuilder withLastName(String lastName) {
            super.set(Contact.LastName, lastName);
            return this;
        }

        public ContactBuilder withAccount(Id accountId) {
            super.set(Contact.AccountId, accountId);
            return this;
        }

        public ContactBuilder withEmail(String email) {
            super.set(Contact.Email, email);
            return this;
        }

        public ContactBuilder executive() {
            super.useTemplate('executive');
            return this;
        }
    }

    public class ContactMocker extends TestModule.RecordMocker {
        public ContactMocker() {
            super(new Templates());
        }

        public ContactMocker withAccountName(String accountName) {
            super.set('Account.Name', accountName);
            return this;
        }
    }

    public class Templates implements TestModule.Template {
        public SObject defaultTemplate() {
            return new Contact(
                FirstName = 'John',
                LastName = 'Doe',
                Email = 'john.doe@example.com'
            );
        }

        public Map<String, SObject> templates() {
            return new Map<String, SObject>{
                'executive' => new Contact(
                    FirstName = 'Jane',
                    LastName = 'Smith',
                    Title = 'CEO',
                    Email = 'jane.smith@example.com'
                )
            };
        }
    }
}
```

[API Reference →](/api)

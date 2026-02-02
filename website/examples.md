# Examples

Practical examples using Test Lib based on the actual codebase.

## Basic Builder Usage

### Single Record

```apex
@IsTest
static void testCreateAccount() {
    Account acc = (Account) AccountTestModule.Builder()
        .withName('Acme Corporation')
        .withIndustry('Technology')
        .buildAndInsert();

    Assert.isNotNull(acc.Id);
    Assert.areEqual('Acme Corporation', acc.Name);
}
```

### Multiple Records

```apex
@IsTest
static void testCreateMultipleAccounts() {
    List<SObject> accounts = AccountTestModule.Builder()
        .withIndustry('Technology')
        .buildAndInsert(5);

    Assert.areEqual(5, accounts.size());
    for (SObject acc : accounts) {
        Assert.areEqual('Technology', acc.get('Industry'));
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

    Assert.areEqual('Enterprise Account', acc.Name);
    Assert.areEqual(1000000, acc.AnnualRevenue);
}

@IsTest
static void testStartupAccount() {
    Account acc = (Account) AccountTestModule.Builder()
        .startup()
        .buildAndInsert();

    Assert.areEqual('Startup Account', acc.Name);
    Assert.areEqual(100000, acc.AnnualRevenue);
}
```

### Template with Override

```apex
@IsTest
static void testTemplateOverride() {
    Account acc = (Account) AccountTestModule.Builder()
        .enterprise()
        .withName('Custom Enterprise')
        .buildAndInsert();

    Assert.areEqual('Custom Enterprise', acc.Name);
    Assert.areEqual(1000000, acc.AnnualRevenue);  // From template
}
```

## Randomizers

### Single Field Randomizer

```apex
@IsTest
static void testRandomIndustry() {
    List<SObject> accounts = AccountTestModule.Builder()
        .withRandomIndustry()
        .build(4);

    // Industries cycle through: Technology, Finance, Healthcare, Retail
    Assert.areEqual('Technology', accounts[0].get('Industry'));
    Assert.areEqual('Finance', accounts[1].get('Industry'));
    Assert.areEqual('Healthcare', accounts[2].get('Industry'));
    Assert.areEqual('Retail', accounts[3].get('Industry'));
}
```

### Record Randomizer

```apex
@IsTest
static void testRecordRandomizer() {
    List<SObject> accounts = AccountTestModule.Builder()
        .withAccountRandomizer()
        .build(3);

    // Each account has unique name and cycling industry
    Assert.areEqual('Company 1', accounts[0].get('Name'));
    Assert.areEqual('Company 2', accounts[1].get('Name'));
    Assert.areEqual('Company 3', accounts[2].get('Name'));
}
```

### Using ListRandomizer

```apex
@IsTest
static void testListRandomizer() {
    List<SObject> accounts = AccountTestModule.Builder()
        .withRandomizer(Account.Industry,
            TestModule.ListRandomizer(new List<Object>{ 'Tech', 'Finance', 'Health' }))
        .build(5);

    Assert.areEqual('Tech', accounts[0].get('Industry'));
    Assert.areEqual('Finance', accounts[1].get('Industry'));
    Assert.areEqual('Health', accounts[2].get('Industry'));
    Assert.areEqual('Tech', accounts[3].get('Industry'));  // Cycles back
    Assert.areEqual('Finance', accounts[4].get('Industry'));
}
```

### Combining Randomizers

```apex
@IsTest
static void testCombinedRandomizers() {
    List<SObject> accounts = AccountTestModule.Builder()
        .withRandomizer(new AccountRandomizer())
        .withRandomizer(Account.Industry,
            TestModule.ListRandomizer(new List<Object>{ 'Override' }))
        .build(2);

    // Name from AccountRandomizer, Industry overridden
    Assert.areEqual('Company 1', accounts[0].get('Name'));
    Assert.areEqual('Override', accounts[0].get('Industry'));
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
    Assert.isNull(acc.Id);
    Assert.areEqual('Mock Account', acc.Name);
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
    Assert.isNotNull(acc.Id);
    Assert.isTrue(String.valueOf(acc.Id).startsWith('001'));
}

@IsTest
static void testUniqueFakeIds() {
    Account acc1 = (Account) AccountTestModule.Mocker().setFakeId().build();
    Account acc2 = (Account) AccountTestModule.Mocker().setFakeId().build();

    // Each call generates unique ID
    Assert.areNotEqual(acc1.Id, acc2.Id);
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
    Assert.areEqual('Parent Corporation', acc.Parent.Name);
}
```

### Deeply Nested Parent

```apex
@IsTest
static void testDeeplyNestedParent() {
    Contact con = (Contact) ContactTestModule.Mocker()
        .set('Account.Parent.Name', 'Grandparent Account')
        .build();

    Assert.areEqual('Grandparent Account', con.Account.Parent.Name);
}
```

### Mock Child Relationships

```apex
@IsTest
static void testMockChildRelationship() {
    List<Contact> contacts = new List<Contact>{
        (Contact) ContactTestModule.Mocker().withLastName('Smith').build(),
        (Contact) ContactTestModule.Mocker().withLastName('Jones').build()
    };

    Account acc = (Account) AccountTestModule.Mocker()
        .withContacts(contacts)
        .build();

    // Child relationship is populated
    Assert.areEqual(2, acc.Contacts.size());
    Assert.areEqual('Smith', acc.Contacts[0].LastName);
    Assert.areEqual('Jones', acc.Contacts[1].LastName);
}
```

### Mock Read-Only Fields

```apex
@IsTest
static void testMockReadOnlyFields() {
    Datetime createdDate = Datetime.newInstance(2025, 1, 15, 10, 30, 0);

    Account acc = (Account) AccountTestModule.Mocker()
        .setFakeId()
        .set('CreatedDate', createdDate)
        .set('Owner.Name', 'System Admin')
        .build();

    Assert.areEqual(createdDate, acc.CreatedDate);
    Assert.areEqual('System Admin', acc.Owner.Name);
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
    List<SObject> contacts = ContactTestModule.Builder()
        .set(Contact.AccountId, acc.Id)
        .buildAndInsert(3);

    // Verify
    Assert.areEqual(3, [SELECT COUNT() FROM Contact WHERE AccountId = :acc.Id]);
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
        .set(Opportunity.AccountId, acc.Id)
        .withAmount(50000)
        .withCloseDate(Date.today().addDays(30))
        .buildAndInsert();

    Assert.areEqual(acc.Id, opp.AccountId);
}
```

## Contact Test Module

### Using Contact Builder

```apex
@IsTest
static void testContactBuilder() {
    Contact con = (Contact) ContactTestModule.Builder()
        .withFirstName('John')
        .withLastName('Doe')
        .withEmail('john.doe@example.com')
        .buildAndInsert();

    Assert.areEqual('John', con.FirstName);
    Assert.areEqual('Doe', con.LastName);
}
```

### Contact Templates

```apex
@IsTest
static void testContactTemplates() {
    Contact business = (Contact) ContactTestModule.Builder()
        .business()
        .buildAndInsert();

    Contact personal = (Contact) ContactTestModule.Builder()
        .personal()
        .buildAndInsert();

    Assert.areEqual('Business', business.FirstName);
    Assert.areEqual('Personal', personal.FirstName);
}
```

### Contact Mocker

```apex
@IsTest
static void testContactMocker() {
    Contact con = (Contact) ContactTestModule.Mocker()
        .withFakeId()
        .withAccountName('Parent Account')
        .build();

    Assert.isNotNull(con.Id);
    Assert.areEqual('Parent Account', con.Account.Name);
}
```

## Opportunity Test Module

### Using Opportunity Builder

```apex
@IsTest
static void testOpportunityBuilder() {
    Opportunity opp = (Opportunity) OpportunityTestModule.Builder()
        .withName('Big Deal')
        .withStageName('Qualification')
        .withAmount(500000)
        .withCloseDate(Date.today().addDays(60))
        .buildAndInsert();

    Assert.areEqual('Big Deal', opp.Name);
    Assert.areEqual(500000, opp.Amount);
}
```

### Opportunity Templates

```apex
@IsTest
static void testOpportunityTemplates() {
    Opportunity prospecting = (Opportunity) OpportunityTestModule.Builder()
        .prospecting()
        .buildAndInsert();

    Opportunity closedWon = (Opportunity) OpportunityTestModule.Builder()
        .closedWon()
        .buildAndInsert();

    Assert.areEqual('Prospecting', prospecting.StageName);
    Assert.areEqual('Closed Won', closedWon.StageName);
    Assert.areEqual(100000, closedWon.Amount);
}
```

### Opportunity Mocker

```apex
@IsTest
static void testOpportunityMocker() {
    Opportunity opp = (Opportunity) OpportunityTestModule.Mocker()
        .withFakeId()
        .withAccountName('Customer Account')
        .withAmount(75000)
        .build();

    Assert.isNotNull(opp.Id);
    Assert.areEqual('Customer Account', opp.Account.Name);
    Assert.areEqual(75000, opp.Amount);
}
```

## Builder + Mocker Integration

```apex
@IsTest
static void testBuilderThenMocker() {
    // Create real account in database
    Account realAccount = (Account) AccountTestModule.Builder()
        .withName('Real Account')
        .buildAndInsert();

    // Create mock contact referencing real account's name
    Contact mockContact = (Contact) ContactTestModule.Mocker()
        .withFakeId()
        .set('Account.Name', realAccount.Name)
        .build();

    Assert.isNotNull(realAccount.Id);
    Assert.isNotNull(mockContact.Id);
    Assert.areEqual('Real Account', mockContact.Account.Name);
}
```

## Static Utilities

### Using IdGenerator

```apex
@IsTest
static void testIdGenerator() {
    Id accountId = TestModule.IdGenerator.get(Account.SObjectType);
    Id contactId = TestModule.IdGenerator.get(Contact.SObjectType);

    Assert.isTrue(String.valueOf(accountId).startsWith('001'));
    Assert.isTrue(String.valueOf(contactId).startsWith('003'));
    Assert.areNotEqual(accountId, contactId);
}
```

### Using fakeId()

```apex
@IsTest
static void testFakeId() {
    Id fakeId = TestModule.fakeId(Account.SObjectType);

    Assert.isTrue(String.valueOf(fakeId).startsWith('001'));
}
```

[API Reference →](/api)

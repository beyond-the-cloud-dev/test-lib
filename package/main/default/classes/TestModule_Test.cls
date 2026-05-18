/**
 * Copyright (c) 2026 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/test-lib/blob/main/LICENSE)
**/
@IsTest
private class TestModule_Test {
    // Builder

    @IsTest
    static void builderBasicBuild() {
        Account acc = (Account) new AccountTestModule().Builder().build();

        Assert.areEqual('Test Account', acc.Name);
        Assert.areEqual('Technology', acc.Industry);
        Assert.isNull(acc.Id);
    }

    @IsTest
    static void builderBuildAndInsert() {
        Account acc = (Account) new AccountTestModule().Builder().buildAndInsert();

        Assert.isNotNull(acc.Id);
        Assert.areEqual('Test Account', acc.Name);
    }

    @IsTest
    static void builderSetFieldBySObjectField() {
        Account acc = (Account) new AccountTestModule().Builder().set(Account.Name, 'Custom Name').set(Account.AnnualRevenue, 500000).build();

        Assert.areEqual('Custom Name', acc.Name);
        Assert.areEqual(500000, acc.AnnualRevenue);
    }

    @IsTest
    static void builderSetFieldByString() {
        Account acc = (Account) new AccountTestModule().Builder().set('Name', 'String Field Name').set('Industry', 'Finance').build();

        Assert.areEqual('String Field Name', acc.Name);
        Assert.areEqual('Finance', acc.Industry);
    }

    @IsTest
    static void builderWithConvenienceMethods() {
        Account acc = (Account) new AccountTestModule().Builder().withName('Convenience Name').withIndustry('Healthcare').build();

        Assert.areEqual('Convenience Name', acc.Name);
        Assert.areEqual('Healthcare', acc.Industry);
    }

    @IsTest
    static void builderUseTemplate() {
        Account acc = (Account) new AccountTestModule().Builder().enterprise().build();

        Assert.areEqual('Enterprise Account', acc.Name);
        Assert.areEqual(1000000, acc.AnnualRevenue);
    }

    @IsTest
    static void builderTemplateOverride() {
        Account acc = (Account) new AccountTestModule().Builder().enterprise().withName('Custom Enterprise').build();

        Assert.areEqual('Custom Enterprise', acc.Name);
        Assert.areEqual(1000000, acc.AnnualRevenue);
    }

    @IsTest
    static void builderBuildMultiple() {
        List<SObject> accounts = new AccountTestModule().Builder().build(5);

        Assert.areEqual(5, accounts.size());
        for (SObject acc : accounts) {
            Assert.areEqual('Test Account', acc.get('Name'));
        }
    }

    @IsTest
    static void builderBuildAndInsertMultiple() {
        List<SObject> accounts = new AccountTestModule().Builder().buildAndInsert(3);

        Assert.areEqual(3, accounts.size());
        for (SObject acc : accounts) {
            Assert.isNotNull(acc.Id);
        }
    }

    @IsTest
    static void builderWithRandomizer() {
        List<SObject> accounts = new AccountTestModule().Builder().withRandomizer(new AccountRandomizer()).build(3);

        Assert.areEqual(3, accounts.size());
        Assert.areEqual('Company 0', accounts[0].get(Account.Name));
        Assert.areEqual('Company 1', accounts[1].get(Account.Name));
        Assert.areEqual('Company 2', accounts[2].get(Account.Name));
        Assert.areEqual(100000, accounts[0].get(Account.AnnualRevenue));
        Assert.areEqual(200000, accounts[1].get(Account.AnnualRevenue));
    }

    @IsTest
    static void builderWithFieldRandomizer() {
        List<SObject> accounts = new AccountTestModule().Builder().withRandomizer(Account.Name, new NameRandomizer()).build(3);

        Assert.areEqual(3, accounts.size());
        Assert.areEqual('Name 0', accounts[0].get(Account.Name));
        Assert.areEqual('Name 1', accounts[1].get(Account.Name));
        Assert.areEqual('Name 2', accounts[2].get(Account.Name));
    }

    @IsTest
    static void builderWithListRandomizer() {
        List<SObject> accounts = new AccountTestModule()
            .Builder()
            .withRandomizer(Account.Industry, new TestModule.ListRandomizer(new List<Object>{ 'Tech', 'Finance', 'Health' }))
            .build(5);

        Assert.areEqual(5, accounts.size());
        Assert.areEqual('Tech', accounts[0].get(Account.Industry));
        Assert.areEqual('Finance', accounts[1].get(Account.Industry));
        Assert.areEqual('Health', accounts[2].get(Account.Industry));
        Assert.areEqual('Tech', accounts[3].get(Account.Industry));
        Assert.areEqual('Finance', accounts[4].get(Account.Industry));
    }

    @IsTest
    static void builderCombinedRandomizers() {
        List<SObject> accounts = new AccountTestModule()
            .Builder()
            .withRandomizer(new AccountRandomizer())
            .withRandomizer(Account.Industry, new TestModule.ListRandomizer(new List<Object>{ 'Override' }))
            .build(2);

        Assert.areEqual('Company 0', accounts[0].get(Account.Name));
        Assert.areEqual('Override', accounts[0].get(Account.Industry));
    }

    @IsTest
    static void builderRandomizerPreservesUnsetFields() {
        List<SObject> accounts = new AccountTestModule().Builder().withIndustry('Finance').withRandomizer(new AccountRandomizer()).build(2);

        Assert.areEqual('Finance', accounts[0].get(Account.Industry));
        Assert.areEqual('Finance', accounts[1].get(Account.Industry));
    }

    @IsTest
    static void builderTemplateNotFound() {
        Boolean exceptionThrown = false;
        try {
            new AccountTestModule().Builder().useTemplate('nonexistent').build();
        } catch (TestModule.TestModuleException e) {
            exceptionThrown = true;
            Assert.isTrue(e.getMessage().contains('not found'));
        }
        Assert.isTrue(exceptionThrown, 'Expected TestModuleException for missing template');
    }

    @IsTest
    static void builderDefaultTemplateApplied() {
        Account acc = (Account) new AccountTestModule().Builder().build();

        Assert.areEqual('Test Account', acc.Name);
        Assert.areEqual('Technology', acc.Industry);
    }

    @IsTest
    static void builderNamedTemplates() {
        Account enterprise = (Account) new AccountTestModule().Builder().enterprise().build();
        Account startup = (Account) new AccountTestModule().Builder().startup().build();

        Assert.areEqual('Enterprise Account', enterprise.Name);
        Assert.areEqual(1000000, enterprise.AnnualRevenue);
        Assert.areEqual('Startup Account', startup.Name);
        Assert.areEqual(100000, startup.AnnualRevenue);
    }

    @IsTest
    static void builderThenMockerIntegration() {
        Account realAccount = (Account) new AccountTestModule().Builder().withName('Real Account').buildAndInsert();

        Contact mockContact = (Contact) new ContactTestModule().Mocker().withLastName('Mock Contact').withFakeId().set('Account.Name', realAccount.Name).build();

        Assert.isNotNull(realAccount.Id);
        Assert.isNotNull(mockContact.Id);
        Assert.areEqual('Real Account', mockContact.Account.Name);
    }

    @IsTest
    static void builderComplexScenario() {
        Account enterprise = (Account) new AccountTestModule().Builder().enterprise().withName('Global Corp').buildAndInsert();

        List<Contact> contacts = (List<Contact>) new ContactTestModule().Builder().set(Contact.AccountId, enterprise.Id).buildAndInsert(2);

        Assert.areEqual(2, contacts.size());
        for (Contact c : contacts) {
            Assert.areEqual(enterprise.Id, c.AccountId);
        }

        List<Contact> queriedContacts = [SELECT Id FROM Contact WHERE AccountId = :enterprise.Id];
        Assert.areEqual(2, queriedContacts.size());
    }

    // Mocker

    @IsTest
    static void mockerBasicBuild() {
        Account acc = (Account) new AccountTestModule().Mocker().build();

        Assert.areEqual('Test Account', acc.Name);
        Assert.areEqual('Technology', acc.Industry);
    }

    @IsTest
    static void mockerSetFieldBySObjectField() {
        Account acc = (Account) new AccountTestModule().Mocker().set(Account.Name, 'Mock Account').build();

        Assert.areEqual('Mock Account', acc.Name);
    }

    @IsTest
    static void mockerSetFieldByString() {
        Account acc = (Account) new AccountTestModule().Mocker().set('Name', 'String Mock').set('Industry', 'Healthcare').build();

        Assert.areEqual('String Mock', acc.Name);
        Assert.areEqual('Healthcare', acc.Industry);
    }

    @IsTest
    static void mockerWithConvenienceMethods() {
        Account acc = (Account) new AccountTestModule().Mocker().withName('Convenience Mock').withIndustry('Finance').build();

        Assert.areEqual('Convenience Mock', acc.Name);
        Assert.areEqual('Finance', acc.Industry);
    }

    @IsTest
    static void mockerNestedField() {
        Account acc = (Account) new AccountTestModule().Mocker().withParentName('Parent Account').build();

        Assert.areEqual('Parent Account', acc.Parent.Name);
    }

    @IsTest
    static void mockerDeeplyNestedField() {
        Contact con = (Contact) new ContactTestModule().Mocker().set('Account.Parent.Name', 'Grandparent Account').build();

        Assert.areEqual('Grandparent Account', con.Account.Parent.Name);
    }

    @IsTest
    static void mockerSetChildren() {
        List<Contact> contacts = new List<Contact>{
            (Contact) new ContactTestModule().Mocker().withLastName('Smith').build(),
            (Contact) new ContactTestModule().Mocker().withLastName('Jones').build()
        };

        Account acc = (Account) new AccountTestModule().Mocker().withName('Parent Account').withContacts(contacts).build();

        Assert.areEqual(2, acc.Contacts.size());
        Assert.areEqual('Smith', acc.Contacts[0].LastName);
        Assert.areEqual('Jones', acc.Contacts[1].LastName);
    }

    @IsTest
    static void mockerMultipleChildRelationships() {
        List<Contact> contacts = new List<Contact>{ (Contact) new ContactTestModule().Mocker().withLastName('Smith').build() };
        List<Opportunity> opportunities = new List<Opportunity>{ new Opportunity(Name = 'Big Deal', StageName = 'Prospecting', CloseDate = Date.today()) };

        Account acc = (Account) new AccountTestModule().Mocker().withContacts(contacts).withOpportunities(opportunities).build();

        Assert.areEqual(1, acc.Contacts.size());
        Assert.areEqual(1, acc.Opportunities.size());
    }

    @IsTest
    static void mockerBuildMultiple() {
        List<SObject> accounts = new AccountTestModule().Mocker().build(3);

        Assert.areEqual(3, accounts.size());
        for (SObject acc : accounts) {
            Assert.areEqual('Test Account', acc.get('Name'));
        }
    }

    @IsTest
    static void mockerSetFakeId() {
        Account acc = (Account) new AccountTestModule().Mocker().withFakeId().build();

        Assert.isNotNull(acc.Id);
        Assert.isTrue(String.valueOf(acc.Id).startsWith('001'));
    }

    @IsTest
    static void mockerSetFakeIdUnique() {
        Account acc1 = (Account) new AccountTestModule().Mocker().withFakeId().build();
        Account acc2 = (Account) new AccountTestModule().Mocker().withFakeId().build();

        Assert.areNotEqual(acc1.Id, acc2.Id);
    }

    @IsTest
    static void mockerSetReadOnly() {
        Datetime createdDate = Datetime.newInstance(2025, 1, 15, 10, 30, 0);

        Account acc = (Account) new AccountTestModule().Mocker().withFakeId().withCreatedDate(createdDate).build();

        Assert.areEqual(createdDate, acc.CreatedDate);
    }

    @IsTest
    static void mockerSetReadOnlyNestedField() {
        Account acc = (Account) new AccountTestModule().Mocker().set('Owner.Name', 'System Admin').build();

        Assert.areEqual('System Admin', acc.Owner.Name);
    }

    @IsTest
    static void mockerWithBulkRandomizer() {
        List<SObject> accounts = new AccountTestModule().Mocker().withRandomizer(new AccountRandomizer()).build(3);

        Assert.areEqual(3, accounts.size());
        Assert.areEqual('Company 0', accounts[0].get('Name'));
        Assert.areEqual('Company 1', accounts[1].get('Name'));
        Assert.areEqual('Company 2', accounts[2].get('Name'));
    }

    @IsTest
    static void mockerWithFieldRandomizer() {
        List<SObject> accounts = new AccountTestModule().Mocker().withRandomizer(Account.Name, new NameRandomizer()).build(3);

        Assert.areEqual(3, accounts.size());
        Assert.areEqual('Name 0', accounts[0].get('Name'));
        Assert.areEqual('Name 1', accounts[1].get('Name'));
        Assert.areEqual('Name 2', accounts[2].get('Name'));
    }

    @IsTest
    static void mockerWithListRandomizer() {
        List<SObject> accounts = new AccountTestModule().Mocker().withRandomizer(Account.Industry, new TestModule.ListRandomizer(new List<Object>{ 'A', 'B' })).build(4);

        Assert.areEqual('A', accounts[0].get('Industry'));
        Assert.areEqual('B', accounts[1].get('Industry'));
        Assert.areEqual('A', accounts[2].get('Industry'));
        Assert.areEqual('B', accounts[3].get('Industry'));
    }

    @IsTest
    static void fakeIdStaticUtility() {
        Id accountId = TestModule.IdGenerator.get(Account.SObjectType);
        Id contactId = TestModule.IdGenerator.get(Contact.SObjectType);

        Assert.isTrue(String.valueOf(accountId).startsWith('001'));
        Assert.isTrue(String.valueOf(contactId).startsWith('003'));
        Assert.areNotEqual(accountId, contactId);
    }

    public class AccountTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
        public AccountBuilder Builder() {
            return new AccountBuilder();
        }

        public AccountMocker Mocker() {
            return new AccountMocker();
        }
    }

    public class AccountBuilder extends TestModule.RecordBuilder {
        public AccountBuilder() {
            super(new Templates());
        }

        public AccountBuilder withName(String name) {
            super.set(Account.Name, name);
            return this;
        }

        public AccountBuilder withIndustry(String industry) {
            super.set(Account.Industry, industry);
            return this;
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

    public class AccountMocker extends TestModule.RecordMocker {
        public AccountMocker() {
            super(new Account(Name = 'Test Account', Industry = 'Technology'));
        }

        public AccountMocker withName(String name) {
            super.set(Account.Name, name);
            return this;
        }

        public AccountMocker withIndustry(String industry) {
            super.set(Account.Industry, industry);
            return this;
        }

        public AccountMocker withContacts(List<Contact> contacts) {
            super.setChildren('Contacts', contacts);
            return this;
        }

        public AccountMocker withOpportunities(List<Opportunity> opportunities) {
            super.setChildren('Opportunities', opportunities);
            return this;
        }

        public AccountMocker withParentName(String parentName) {
            super.set('Parent.Name', parentName);
            return this;
        }

        public AccountMocker withFakeId() {
            super.setFakeId();
            return this;
        }

        public AccountMocker withCreatedDate(Datetime createdDate) {
            super.set('CreatedDate', createdDate);
            return this;
        }
    }

    public class Templates implements TestModule.Template {
        public SObject defaultTemplate() {
            return new Account(Name = 'Test Account', Industry = 'Technology');
        }

        public Map<String, SObject> templates() {
            return new Map<String, SObject>{
                'enterprise' => new Account(Name = 'Enterprise Account', Industry = 'Technology', AnnualRevenue = 1000000),
                'startup' => new Account(Name = 'Startup Account', Industry = 'Technology', AnnualRevenue = 100000)
            };
        }
    }

    public class ContactTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
        public ContactBuilder Builder() {
            return new ContactBuilder();
        }

        public ContactMocker Mocker() {
            return new ContactMocker();
        }
    }

    public class ContactBuilder extends TestModule.RecordBuilder {
        public ContactBuilder() {
            super(new Contact(LastName = 'Test Contact'));
        }
    }

    public class ContactMocker extends TestModule.RecordMocker {
        public ContactMocker() {
            super(new Contact(LastName = 'Test Contact'));
        }

        public ContactMocker withLastName(String lastName) {
            super.set(Contact.LastName, lastName);
            return this;
        }

        public ContactMocker withFakeId() {
            super.setFakeId();
            return this;
        }
    }

    public class AccountRandomizer implements TestModule.RecordRandomizer {
        public Map<SObjectField, TestModule.FieldRandomizer> randomizers() {
            return new Map<SObjectField, TestModule.FieldRandomizer>{ Account.Name => new CompanyNameRandomizer(), Account.AnnualRevenue => new RevenueRandomizer() };
        }
    }

    public class CompanyNameRandomizer implements TestModule.FieldRandomizer {
        public Object generate(Integer index) {
            return 'Company ' + index;
        }
    }

    public class RevenueRandomizer implements TestModule.FieldRandomizer {
        public Object generate(Integer index) {
            return (index + 1) * 100000;
        }
    }

    public class NameRandomizer implements TestModule.FieldRandomizer {
        public Object generate(Integer index) {
            return 'Name ' + index;
        }
    }
}

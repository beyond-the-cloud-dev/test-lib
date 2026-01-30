@IsTest
private class TestModuleExamples {
    @IsTest
    static void basicBuild() {
        Account acc = (Account) new AccountTestModule().build();

        Assert.areEqual('Test Account', acc.Name);
        Assert.areEqual('Technology', acc.Industry);
        Assert.isNull(acc.Id);
    }

    @IsTest
    static void buildAndInsert() {
        Account acc = (Account) new AccountTestModule().buildAndInsert();

        Assert.isNotNull(acc.Id);
    }

    @IsTest
    static void withFieldOverrides() {
        Account acc = (Account) new AccountTestModule()
            .withName('Acme Corp')
            .withIndustry('Finance')
            .withAnnualRevenue(5000000)
            .build();

        Assert.areEqual('Acme Corp', acc.Name);
        Assert.areEqual('Finance', acc.Industry);
        Assert.areEqual(5000000, acc.AnnualRevenue);
    }

    @IsTest
    static void buildMultipleWithAutoDeduplication() {
        List<SObject> accounts = new AccountTestModule()
            .withName('Test Account')
            .build(5);

        Assert.areEqual(5, accounts.size());
        Assert.areEqual('Test Account 0', accounts[0].get(Account.Name));
        Assert.areEqual('Test Account 4', accounts[4].get(Account.Name));
    }

    @IsTest
    static void buildMultipleAndInsert() {
        List<SObject> accounts = new AccountTestModule().buildAndInsert(3);

        Assert.areEqual(3, accounts.size());
        for (SObject acc : accounts) {
            Assert.isNotNull(acc.Id);
        }
    }

    @IsTest
    static void useTypedVariant() {
        Account enterprise = (Account) new AccountTestModule()
            .useEnterpriseVariant()
            .build();

        Account smb = (Account) new AccountTestModule()
            .useSmallBusinessVariant()
            .build();

        Assert.areEqual('Enterprise', enterprise.Type);
        Assert.areEqual(1000000, enterprise.AnnualRevenue);
        Assert.areEqual('Small Business', smb.Type);
        Assert.areEqual(50000, smb.AnnualRevenue);
    }

    @IsTest
    static void variantWithOverrides() {
        Account acc = (Account) new AccountTestModule()
            .useEnterpriseVariant()
            .withName('Custom Enterprise')
            .withAnnualRevenue(9999999)
            .build();

        Assert.areEqual('Custom Enterprise', acc.Name);
        Assert.areEqual(9999999, acc.AnnualRevenue);
        Assert.areEqual('Enterprise', acc.Type);
    }

    @IsTest
    static void mockWithFakeId() {
        Account acc = (Account) new AccountTestModule()
            .withName('Mock Account')
            .withFakeId()
            .build();

        Assert.isNotNull(acc.Id);
        Assert.areEqual('Mock Account', acc.Name);
    }

    @IsTest
    static void mockWithSystemFields() {
        Account acc = (Account) new AccountTestModule()
            .withFakeId()
            .withCreatedDate(Datetime.newInstance(2025, 1, 15))
            .build();

        Assert.isNotNull(acc.Id);
        Assert.areEqual(Datetime.newInstance(2025, 1, 15), acc.CreatedDate);
    }

    @IsTest
    static void mockWithParentRelationship() {
        Contact con = (Contact) new ContactTestModule()
            .withLastName('Doe')
            .withFakeId()
            .withAccountName('Parent Account')
            .build();

        Assert.areEqual('Parent Account', con.Account.Name);
    }

    @IsTest
    static void mockWithChildRelationships() {
        Account acc = (Account) new AccountTestModule()
            .withName('Acme Corp')
            .withContacts(
                new List<Contact>{
                    (Contact) new ContactTestModule()
                        .withLastName('Smith')
                        .build(),
                    (Contact) new ContactTestModule()
                        .withLastName('Jones')
                        .build()
                }
            )
            .build();

        Assert.areEqual(2, acc.Contacts.size());
        Assert.areEqual('Smith', acc.Contacts[0].LastName);
        Assert.areEqual('Jones', acc.Contacts[1].LastName);
    }

    @IsTest
    static void mockWithMultipleChildRelationships() {
        Account acc = (Account) new AccountTestModule()
            .withName('Acme Corp')
            .withContacts(
                new List<Contact>{
                    (Contact) new ContactTestModule()
                        .withLastName('Smith')
                        .build()
                }
            )
            .withOpportunities(
                new List<Opportunity>{
                    new Opportunity(
                        Name = 'Big Deal',
                        Amount = 500000,
                        StageName = 'Prospecting',
                        CloseDate = Date.today()
                    )
                }
            )
            .build();

        Assert.areEqual(1, acc.Contacts.size());
        Assert.areEqual(1, acc.Opportunities.size());
    }

    @IsTest
    static void randomDataWithBuiltInGenerators() {
        Contact con = (Contact) new ContactTestModule()
            .setRandom(Contact.Email, TestModule.Random.email())
            .setRandom(Contact.Phone, TestModule.Random.phone())
            .build();

        Assert.isTrue(((String) con.Email).contains('@'));
        Assert.isTrue(((String) con.Phone).startsWith('+1'));
    }

    @IsTest
    static void randomDataMultipleRecords() {
        List<SObject> contacts = new ContactTestModule()
            .setRandom(Contact.Email, TestModule.Random.email())
            .build(5);

        Set<String> emails = new Set<String>();
        for (SObject c : contacts) {
            emails.add((String) c.get(Contact.Email));
        }
        Assert.areEqual(5, emails.size());
    }

    @IsTest
    static void customRandomizer() {
        List<SObject> accounts = new AccountTestModule()
            .setRandom(new AccountRandomizer())
            .build(3);

        Assert.areEqual('Company 0', accounts[0].get(Account.Name));
        Assert.areEqual('Company 1', accounts[1].get(Account.Name));
        Assert.areEqual(100000, accounts[0].get(Account.AnnualRevenue));
        Assert.areEqual(200000, accounts[1].get(Account.AnnualRevenue));
    }

    @IsTest
    static void explicitParentChild() {
        Account acc = (Account) new AccountTestModule().buildAndInsert();

        Contact con = (Contact) new ContactTestModule()
            .withAccountId(acc.Id)
            .buildAndInsert();

        Assert.areEqual(acc.Id, con.AccountId);
    }

    @IsTest
    static void complexTestSetup() {
        Account enterprise = (Account) new AccountTestModule()
            .useEnterpriseVariant()
            .withName('Global Corp')
            .buildAndInsert();

        Account smb = (Account) new AccountTestModule()
            .useSmallBusinessVariant()
            .withName('Regional LLC')
            .buildAndInsert();

        new ContactTestModule()
            .withAccountId(enterprise.Id)
            .withLastName('Decision Maker')
            .buildAndInsert();

        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE AccountId = :enterprise.Id
        ];
        Assert.areEqual(1, contacts.size());
    }

    @IsTest
    static void mockModeBlocksInsert() {
        Boolean exceptionThrown = false;
        try {
            new AccountTestModule().withFakeId().buildAndInsert();
        } catch (TestModule.TestModuleException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(
            exceptionThrown,
            'Should throw exception when trying to insert mock record'
        );
    }

    private class AccountRandomizer implements TestModule.Randomizer {
        public void apply(SObject record, Integer index) {
            record.put(Account.Name, 'Company ' + index);
            record.put(Account.AnnualRevenue, (index + 1) * 100000);
        }
    }
}

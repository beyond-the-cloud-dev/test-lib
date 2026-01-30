@IsTest
public class AccountTestModule extends TestModule {
    public AccountTestModule() {
        super(
            new Account(
                Name = 'Test Account',
                Industry = 'Technology',
                BillingCountry = 'US'
            )
        );
        setUniqueFields(new Set<SObjectField>{ Account.Name });
    }

    protected override Map<String, SObject> variants() {
        return new Map<String, SObject>{
            'enterprise' => new Account(
                Name = 'Enterprise Account',
                Type = 'Enterprise',
                AnnualRevenue = 1000000,
                NumberOfEmployees = 500
            ),
            'small-business' => new Account(
                Name = 'Small Business Account',
                Type = 'Small Business',
                AnnualRevenue = 50000,
                NumberOfEmployees = 10
            )
        };
    }

    public AccountTestModule withName(String name) {
        set(Account.Name, name);
        return this;
    }

    public AccountTestModule withIndustry(String industry) {
        set(Account.Industry, industry);
        return this;
    }

    public AccountTestModule withType(String accType) {
        set(Account.Type, accType);
        return this;
    }

    public AccountTestModule withAnnualRevenue(Decimal revenue) {
        set(Account.AnnualRevenue, revenue);
        return this;
    }

    public AccountTestModule useEnterpriseVariant() {
        useVariant('enterprise');
        return this;
    }

    public AccountTestModule useSmallBusinessVariant() {
        useVariant('small-business');
        return this;
    }

    public AccountTestModule withFakeId() {
        setFakeId(Account.SObjectType);
        return this;
    }

    public AccountTestModule withCreatedDate(Datetime createdDate) {
        setReadOnly('CreatedDate', createdDate);
        return this;
    }

    public AccountTestModule withParentName(String parentName) {
        setReadOnly('Parent.Name', parentName);
        return this;
    }

    public AccountTestModule withContacts(List<Contact> contacts) {
        setChildren('Contacts', contacts);
        return this;
    }

    public AccountTestModule withOpportunities(
        List<Opportunity> opportunities
    ) {
        setChildren('Opportunities', opportunities);
        return this;
    }
}

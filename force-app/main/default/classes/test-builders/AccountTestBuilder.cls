public with sharing class AccountTestBuilder extends TestModule implements TestModule.Builder, TestModule.Randomizer {
    public AccountTestBuilder() {
        super(Account.SObjectType);
    }

    public AccountTestBuilder withName(String name) {
        this.set(Account.Name, name);
        return this;
    }

    public AccountTestBuilder withIndustry(String industry) {
        this.set(Account.Industry, industry);
        return this;
    }

    public AccountTestBuilder withAnnualRevenue(Decimal annualRevenue) {
        this.set(Account.AnnualRevenue, annualRevenue);
        return this;
    }

    public Map<SObjectField, Object> randomize(Integer index) {
        return new Map<SObjectField, Object>{
            Account.Name => 'Test Account ' + index,
            Account.Industry => 'Technology',
            Account.AnnualRevenue => 1000000,
            Account.BillingCity => 'San Francisco',
            Account.BillingState => 'CA',
            Account.BillingCountry => 'USA',
            Account.BillingPostalCode => '10001',
            Account.BillingStreet => '123 Main St',
            Account.BillingStreet => '123 Main St'
        }
    }
}
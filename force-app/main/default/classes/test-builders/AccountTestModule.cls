/*
Account account1 = AccountTestModule.builder().withName('Test').get();
Account account2 = AccountTestModule.builder().withName('Test 2').insertAndGet();

Account account3 = AccountTestModule.mocker().withName('Test 3').with('Contacts', new List<...>()).get();
*/
public with sharing class AccountTestModule {
    public static Builder builder() {
        return new Builder();
    }

    public static Mocker mocker() {
        return new Mocker();
    }

    public class Builder extends TestModule.Builder implements TestModule.Builder, TestModule.Randomizer, TestModule.Template {
        public Builder() {
            super(
                new Account(
                    Name = 'Test Account'
                    // defaults fields
                )
            );
            setRandom(Account.Name, 'REGEXP_OR_EXPRESSION EG. ACCOUCT-{0}');
        }

        public Builder withName(String name) {
            this.set(Account.Name, name);
            return this;
        }

        public Builder withIndustry(String industry) {
            this.set(Account.Industry, industry);
            return this;
        }

        // forced by implementation TestModule.Randomizer
        public Map<SObjectField, Object> randomize(Integer index) {
            List<String> industries = new List<String>{ 'Technology', 'Finance', 'Healthcare', 'Education', 'Government', 'Other' };
            List<String> names = new List<String>{ 'Test Account', 'Test Account 2', 'Test Account 3', 'Test Account 4', 'Test Account 5', 'Test Account 6' };

            return new Map<SObjectField, Object>{
                Account.Name => names[index],
                Account.Industry => industries[index]
            };
        }

        public Map<String, Account> templates() {
            return new Map<String, Account>{
                'default' => new Account(
                    Name = 'Test Account'
                    // defaults fields
                ),
                'enterprise' => new Account(
                    Name = 'Test Account',
                    Industry = 'Technology'
                )
            };
        }
    }

    public class Mocker extends TestModule.Mocker implements TestModule.Mocker, TestModule.Randomizer {
        public Mocker() {
            super(
                new Account(
                    Name = 'Test Account'
                    // defaults fields
                )
            );
        }

        public Mocker withName(String name) {
            this.set(Account.Name, name);
            return this;
        }

        // set relationships

        // set not writable fields

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
            };
        }
    }
}
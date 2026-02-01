/*
Account account1 = AccountTestModule.builder().withName('Test').build();
Account account2 = AccountTestModule.builder().withName('Test 2').buildAndInsert();

Account account3 = AccountTestModule.mocker().withName('Test 3').withContacts(new List<...>()).build();
*/
public with sharing class AccountTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static Builder builder() {
        return new Builder();
    }

    public static Mocker mocker() {
        return new Mocker();
    }

    public interface IBuilder extends TestModule.IBuilder {
        IBuilder withName(String name);
        IBuilder withIndustry(String industry);
    }

    public interface IMocker extends TestModule.IMocker {
        IMocker withContacts(List<Contact> contacts);
    }

    public class Builder extends TestModule.Builder implements IBuilder, TestModule.IBuilder, TestModule.IRandomizer, TestModule.IVariant {
        public Builder() {
            super(
                new Account(
                    Name = 'Test Account'
                    // default fields
                )
            );
        }

        public Builder withName(String name) {
            this.set(Account.Name, name);
            return this;
        }

        public Builder withIndustry(String industry) {
            this.set(Account.Industry, industry);
            return this;
        }

        public Map<SObjectField, Object> randomize(Integer index) {
            List<String> industries = new List<String>{ 'Technology', 'Finance', 'Healthcare', 'Education', 'Government', 'Other' };
            List<String> names = new List<String>{ 'Test Account', 'Test Account 2', 'Test Account 3', 'Test Account 4', 'Test Account 5', 'Test Account 6' };

            return new Map<SObjectField, Object>{
                Account.Name => names[index],
                Account.Industry => industries[index]
            };
        }

        public Map<String, SObject> variants() {
            return new Map<String, SObject>{
                'default' => new Account(
                    Name = 'Test Account'
                    // default fields
                ),
                'enterprise' => new Account(
                    Name = 'Test Account',
                    Industry = 'Technology'
                )
            };
        }
    }

    public class Mocker extends TestModule.Mocker implements TestModule.IMocker, TestModule.IRandomizer {
        public Mocker() {
            super(
                new Account(
                    Name = 'Test Account'
                    // default fields
                )
            );
        }

        public Mocker withContacts(List<Contact> contacts) {
            this.setChildren('Contacts', contacts);
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
                Account.BillingStreet => '123 Main St'
            };
        }
    }
}

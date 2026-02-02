@IsTest
public class AccountTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static AccountBuilder Builder() {
        return new AccountBuilder();
    }

    public static AccountMocker Mocker() {
        return new AccountMocker();
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

        public AccountBuilder withRandomIndustry() {
            super.withRandomizer(Account.Industry, new IndustryRandomizer());
            return this;
        }

        public AccountBuilder withAccountRandomizer() {
            super.withRandomizer(new AccountRandomizer());
            return this;
        }
    }

    public class AccountMocker extends TestModule.RecordMocker {
        public AccountMocker() {
            super(new Account(Name = 'Test Account', Industry = 'Technology'));
        }

        public AccountMocker withContacts(List<Contact> contacts) {
            super.setChildren('Contacts', contacts);
            return this;
        }

        public AccountMocker withParentName(String parentName) {
            super.set('Parent.Name', parentName);
            return this;
        }

        public AccountMocker withRandomIndustry() {
            super.withRandomizer(Account.Industry, new IndustryRandomizer());
            return this;
        }

        public AccountMocker withAccountRandomizer() {
            super.withRandomizer(new AccountRandomizer());
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

    public class IndustryRandomizer implements TestModule.SingleFieldRandomizer {
        private List<String> industries = new List<String>{ 'Technology', 'Finance', 'Healthcare', 'Retail' };

        public Object generate(Integer index) {
            return industries[Math.mod(index, industries.size())];
        }
    }

    public class CompanyNameRandomizer implements TestModule.SingleFieldRandomizer {
        public Object generate(Integer index) {
            return 'Company ' + (index + 1);
        }
    }

    public class AccountRandomizer extends TestModule.RecordRandomizer {
        public AccountRandomizer() {
            this.add(Account.Name, new CompanyNameRandomizer());
            this.add(Account.Industry, new IndustryRandomizer());
        }
    }
}

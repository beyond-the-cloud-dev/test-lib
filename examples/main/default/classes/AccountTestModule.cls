@IsTest
public class AccountTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static Builder Builder() {
        return new Builder();
    }

    public static Mocker Mocker() {
        return new Mocker();
    }

    public class Builder extends TestModule.RecordBuilder {
        private Builder() {
            super(new Templates());
        }

        public Builder withName(String name) {
            super.set(Account.Name, name);
            return this;
        }

        public Builder withIndustry(String industry) {
            super.set(Account.Industry, industry);
            return this;
        }

        public Builder enterprise() {
            super.useTemplate('enterprise');
            return this;
        }

        public Builder startup() {
            super.useTemplate('startup');
            return this;
        }

        public Builder withRandomIndustry() {
            super.withRandomizer(Account.Industry, new IndustryRandomizer());
            return this;
        }

        public Builder withAccountRandomizer() {
            super.withRandomizer(new AccountRandomizer());
            return this;
        }
    }

    private class Mocker extends TestModule.RecordMocker {
        private Mocker() {
            super(new Account(Name = 'Test Account', Industry = 'Technology'));
        }

        public Mocker withContacts(List<Contact> contacts) {
            super.setChildren('Contacts', contacts);
            return this;
        }

        public Mocker withParentName(String parentName) {
            super.set('Parent.Name', parentName);
            return this;
        }

        public Mocker withRandomIndustry() {
            super.withRandomizer(Account.Industry, new IndustryRandomizer());
            return this;
        }

        public Mocker withAccountRandomizer() {
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

    public class AccountRandomizer implements TestModule.RecordRandomizer {
        public Map<SObjectField, TestModule.FieldRandomizer> randomizers() {
            return new Map<SObjectField, TestModule.FieldRandomizer>{
                Account.Name => new CompanyNameRandomizer(),
                Account.Industry => new IndustryRandomizer()
            };
        }
    }

    public class IndustryRandomizer implements TestModule.FieldRandomizer {
        private List<String> industries = new List<String>{ 'Technology', 'Finance', 'Healthcare', 'Retail' };

        public Object generate(Integer index) {
            return industries[Math.mod(index, industries.size())];
        }
    }

    public class CompanyNameRandomizer implements TestModule.FieldRandomizer {
        public Object generate(Integer index) {
            return 'Company ' + (index + 1);
        }
    }
}

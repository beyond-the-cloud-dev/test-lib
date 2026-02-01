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

        public Account build() {
            return (Account) super.preBuild();
        }

        public Account buildAndInsert() {
            return (Account) super.preBuildAndInsert();
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

        public Account build() {
            return (Account) super.preBuild();
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
}

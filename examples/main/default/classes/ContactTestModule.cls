@IsTest
public class ContactTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
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

        public Builder withFirstName(String firstName) {
            super.set(Contact.FirstName, firstName);
            return this;
        }

        public Builder withLastName(String lastName) {
            super.set(Contact.LastName, lastName);
            return this;
        }

        public Builder withEmail(String email) {
            super.set(Contact.Email, email);
            return this;
        }

        public Builder business() {
            super.useTemplate('business');
            return this;
        }

        public Builder personal() {
            super.useTemplate('personal');
            return this;
        }

        public Builder withContactRandomizer() {
            super.withRandomizer(new ContactRandomizer());
            return this;
        }
    }

    private class Mocker extends TestModule.RecordMocker {
        private Mocker() {
            super(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test.contact@example.com'));
        }

        public Mocker withFirstName(String firstName) {
            super.set(Contact.FirstName, firstName);
            return this;
        }

        public Mocker withLastName(String lastName) {
            super.set(Contact.LastName, lastName);
            return this;
        }

        public Mocker withEmail(String email) {
            super.set(Contact.Email, email);
            return this;
        }

        public Mocker withAccountName(String accountName) {
            super.set('Account.Name', accountName);
            return this;
        }

        public Mocker withFakeId() {
            super.setFakeId();
            return this;
        }

        public Mocker withContactRandomizer() {
            super.withRandomizer(new ContactRandomizer());
            return this;
        }
    }

    public class Templates implements TestModule.Template {
        public SObject defaultTemplate() {
            return new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test.contact@example.com');
        }

        public Map<String, SObject> templates() {
            return new Map<String, SObject>{
                'business' => new Contact(FirstName = 'Business', LastName = 'Contact', Email = 'business.contact@example.com'),
                'personal' => new Contact(FirstName = 'Personal', LastName = 'Contact', Email = 'personal.contact@example.com')
            };
        }
    }

    public class ContactRandomizer implements TestModule.RecordRandomizer {
        public Map<SObjectField, TestModule.FieldRandomizer> randomizers() {
            return new Map<SObjectField, TestModule.FieldRandomizer>{
                Contact.FirstName => new FirstNameRandomizer(),
                Contact.LastName => new LastNameRandomizer()
            };
        }
    }

    public class FirstNameRandomizer implements TestModule.FieldRandomizer {
        private List<String> firstNames = new List<String>{ 'John', 'Jane', 'Bob', 'Alice' };

        public Object generate(Integer index) {
            return firstNames[Math.mod(index, firstNames.size())];
        }
    }

    public class LastNameRandomizer implements TestModule.FieldRandomizer {
        public Object generate(Integer index) {
            return 'Contact ' + (index + 1);
        }
    }
}

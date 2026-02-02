@IsTest
public class ContactTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static ContactBuilder Builder() {
        return new ContactBuilder();
    }

    public static ContactMocker Mocker() {
        return new ContactMocker();
    }

    public class ContactBuilder extends TestModule.RecordBuilder {
        public ContactBuilder() {
            super(new Templates());
        }

        public ContactBuilder withFirstName(String firstName) {
            super.set(Contact.FirstName, firstName);
            return this;
        }

        public ContactBuilder withLastName(String lastName) {
            super.set(Contact.LastName, lastName);
            return this;
        }

        public ContactBuilder withEmail(String email) {
            super.set(Contact.Email, email);
            return this;
        }

        public ContactBuilder business() {
            super.useTemplate('business');
            return this;
        }

        public ContactBuilder personal() {
            super.useTemplate('personal');
            return this;
        }

        public ContactBuilder withContactRandomizer() {
            super.withRandomizer(new ContactRandomizer());
            return this;
        }
    }

    public class ContactMocker extends TestModule.RecordMocker {
        public ContactMocker() {
            super(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test.contact@example.com'));
        }

        public ContactMocker withFirstName(String firstName) {
            super.set(Contact.FirstName, firstName);
            return this;
        }

        public ContactMocker withLastName(String lastName) {
            super.set(Contact.LastName, lastName);
            return this;
        }

        public ContactMocker withEmail(String email) {
            super.set(Contact.Email, email);
            return this;
        }

        public ContactMocker withAccountName(String accountName) {
            super.set('Account.Name', accountName);
            return this;
        }

        public ContactMocker withFakeId() {
            super.setFakeId();
            return this;
        }

        public ContactMocker withContactRandomizer() {
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

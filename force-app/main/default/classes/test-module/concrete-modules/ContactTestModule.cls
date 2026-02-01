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

        public ContactBuilder business() {
            super.useTemplate('business');
            return this;
        }

        public ContactBuilder personal() {
            super.useTemplate('personal');
            return this;
        }

        public Contact build() {
            return (Contact) super.preBuild();
        }

        public Contact buildAndInsert() {
            return (Contact) super.preBuildAndInsert();
        }
    }

    public class ContactMocker extends TestModule.RecordMocker {
        public ContactMocker() {
            super(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test.contact@example.com'));
        }

        public Contact build() {
            return (Contact) super.preBuild();
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
}

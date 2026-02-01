public with sharing class ContactTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static ContactBuilder builder() {
        return new ContactBuilder();
    }

    public static ContactMocker mocker() {
        return new ContactMocker();
    }

    public class ContactBuilder extends TestModule.Builder {
        public ContactBuilder() {
            super(new ContactTemplates());
        }

        public ContactBuilder enterprise() {
            this.useTemplate('business');
            return this;
        }

        public ContactBuilder personal() {
            this.useTemplate('personal');
            return this;
        }

        public Contact build() {
            return (Contact) super.preBuild();
        }
    }

    public class ContactMocker extends TestModule.Mocker {
        public ContactMocker() {
            super(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test.contact@example.com'));
        }

        public Contact build() {
            return (Contact) super.preBuild();
        }
    }

    public class ContactTemplates implements TestModule.Template {
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

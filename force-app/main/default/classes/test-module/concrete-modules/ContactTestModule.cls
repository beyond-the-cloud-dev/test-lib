public with sharing class ContactTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static ContactBuilder builder() {
        return new ContactBuilder();
    }

    public static Mocker mocker() {
        return new Mocker();
    }

    public interface Builder {
        Builder withFirstName(String firstName);
        Builder withLastName(String lastName);
        // templates
        Builder enterprise();
        Builder personal();
        // build
        Contact build();
    }

    // Inner implementations

    public class ContactBuilder extends TestModule.RecordBuilder implements Builder {
        public ContactBuilder() {
            super(new Templates());
        }

        public ContactBuilder withFirstName(String firstName) {
            return with(Contact.FirstName, firstName);
        }

        public ContactBuilder withLastName(String lastName) {
            return with(Contact.LastName, lastName);
        }

        public ContactBuilder with(SObjectField field, Object value) {
            super.set(field, value);
            return this;
        }

        public ContactBuilder enterprise() {
            return this.withTemplate('business');
        }

        public ContactBuilder personal() {
            return this.withTemplate('personal');
        }

        public ContactBuilder withTemplate(String templateName) {
            super.useTemplate(templateName);
            return this;
        }

        public Contact build() {
            return (Contact) super.preBuild();
        }
    }

    public class Mocker extends TestModule.RecordMocker {
        public Mocker() {
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

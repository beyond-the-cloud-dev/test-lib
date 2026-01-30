@IsTest
public class ContactTestModule extends TestModule {
    public ContactTestModule() {
        super(
            new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'test.contact@example.com'
            )
        );
        setUniqueFields(
            new Set<SObjectField>{ Contact.LastName, Contact.Email }
        );
    }

    public ContactTestModule withFirstName(String firstName) {
        set(Contact.FirstName, firstName);
        return this;
    }

    public ContactTestModule withLastName(String lastName) {
        set(Contact.LastName, lastName);
        return this;
    }

    public ContactTestModule withEmail(String email) {
        set(Contact.Email, email);
        return this;
    }

    public ContactTestModule withAccountId(Id accountId) {
        set(Contact.AccountId, accountId);
        return this;
    }

    public ContactTestModule withFakeId() {
        setFakeId(Contact.SObjectType);
        return this;
    }

    public ContactTestModule withAccountName(String accountName) {
        setReadOnly('Account.Name', accountName);
        return this;
    }

    public ContactTestModule withCreatedDate(Datetime createdDate) {
        setReadOnly('CreatedDate', createdDate);
        return this;
    }
}

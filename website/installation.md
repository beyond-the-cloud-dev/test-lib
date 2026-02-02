# Installation

Install Test Lib in your Salesforce org.

## Using Salesforce CLI

### Deploy Source Code

```bash
# Clone the repository
git clone https://github.com/beyond-the-cloud-dev/test-lib.git
cd test-lib

# Deploy to your org
sf project deploy start --target-org your-org-alias
```

### Deploy Specific Classes

If you only want the core framework:

```bash
sf project deploy start \
  --source-dir force-app/main/default/classes \
  --target-org your-org-alias
```

## Manual Installation

### Using Setup UI

1. Navigate to **Setup** → **Apex Classes**
2. Click **New**
3. Copy the code from [TestModule.cls](https://github.com/beyond-the-cloud-dev/test-lib/blob/main/force-app/main/default/classes/TestModule.cls)
4. Save the class

## Dependencies

Test Lib has **zero code dependencies**. It's a pure Apex library with no external requirements.

## API Version

Requires Salesforce API version **57.0** or higher.

## Verification

Test the installation by creating a simple test:

```apex
@IsTest
private class TestLibVerification {

    @IsTest
    static void shouldGenerateFakeId() {
        // Test fakeId generation
        Id fakeAccountId = TestModule.IdGenerator.get(Account.SObjectType);

        Assert.isNotNull(fakeAccountId);
        Assert.isTrue(String.valueOf(fakeAccountId).startsWith('001'));
    }

    @IsTest
    static void shouldBuildAccount() {
        // Test basic builder
        Account acc = (Account) AccountTestModule.Builder()
            .withName('Test Account')
            .build();

        Assert.areEqual('Test Account', acc.Name);
    }

    @IsTest
    static void shouldMockAccount() {
        // Test basic mocker
        Account acc = (Account) AccountTestModule.Mocker()
            .setFakeId()
            .build();

        Assert.isNotNull(acc.Id);
    }
}
```

If the tests pass, you're all set!

## Project Structure

After installation, you'll have:

```
force-app/main/default/classes/
├── TestModule.cls                    # Core framework
├── TestModule.cls-meta.xml
├── TestModule_Test.cls               # Framework tests
├── TestModule_Test.cls-meta.xml
└── concrete-modules/                 # Example implementations
    ├── AccountTestModule.cls
    ├── AccountTestModule.cls-meta.xml
    ├── ContactTestModule.cls
    ├── ContactTestModule.cls-meta.xml
    ├── OpportunityTestModule.cls
    └── OpportunityTestModule.cls-meta.xml
```

## Creating Your First Module

After installation, create a Test Module for your SObjects:

```apex
@IsTest
public class AccountTestModule {

    public static AccountBuilder Builder() {
        return new AccountBuilder();
    }

    public static AccountMocker Mocker() {
        return new AccountMocker();
    }

    public class AccountBuilder extends TestModule.RecordBuilder {
        public AccountBuilder() {
            super(new Account(Name = 'Test Account'));
        }

        public AccountBuilder withName(String name) {
            super.set(Account.Name, name);
            return this;
        }
    }

    public class AccountMocker extends TestModule.RecordMocker {
        public AccountMocker() {
            super(new Account(Name = 'Test Account'));
        }
    }
}
```

## Next Steps

- [Getting Started Guide](/getting-started)
- [Builder Pattern](/builder)
- [Mocker Pattern](/mocker)
- [API Reference](/api)
- [Examples](/examples)

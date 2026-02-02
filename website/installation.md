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
  --source-dir force-app/main/default/classes/test-module \
  --target-org your-org-alias
```

## Manual Installation

### Using Setup UI

1. Navigate to **Setup** → **Apex Classes**
2. Click **New**
3. Copy the code from [TestModule.cls](https://github.com/beyond-the-cloud-dev/test-lib/blob/main/force-app/main/default/classes/test-module/TestModule.cls)
4. Save the class

## Package Installation

### Unlocked Package (Recommended)

```bash
sf package install \
  --package "Test Lib@1.0.0" \
  --target-org your-org-alias \
  --wait 10
```

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
    static void shouldCreateFakeId() {
        // Test fakeId generation
        Id fakeAccountId = TestModule.fakeId(Account.SObjectType);

        System.assertNotEquals(null, fakeAccountId);
        System.assertEquals('001', String.valueOf(fakeAccountId).substring(0, 3));
    }
}
```

If the test passes, you're all set!

## Project Structure

After installation, you'll have:

```
force-app/main/default/classes/test-module/
├── TestModule.cls                    # Core framework
├── TestModule.cls-meta.xml
├── TestModule_Test.cls               # Framework tests
├── TestModule_Test.cls-meta.xml
└── concrete-modules/                 # Example implementations
    ├── AccountTestModule.cls
    ├── ContactTestModule.cls
    └── OpportunityTestModule.cls
```

## Creating Your First Module

After installation, create a Test Module for your SObjects:

```apex
@IsTest
public class AccountTestModule {

    public static AccountBuilder Builder() {
        return new AccountBuilder();
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
}
```

## Next Steps

- [Getting Started Guide](/getting-started)
- [Builder Pattern](/builder)
- [Mocker Pattern](/mocker)
- [API Reference](/api)
- [Examples](/examples)

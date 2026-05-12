<div align="center">
  <a href="https://beyond-the-cloud-dev.github.io/test-lib/">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="./website/public/logo.png">
      <img alt="Test Lib logo" src="./website/public/logo.png" height="98">
    </picture>
  </a>
  <h1>Test Lib (BETA)</h1>

<a href="https://beyondthecloud.dev"><img alt="Beyond The Cloud logo" src="https://img.shields.io/badge/MADE_BY_BEYOND_THE_CLOUD-555?style=for-the-badge"></a>

<img alt="API version" src="https://img.shields.io/badge/api-v65.0-blue?style=for-the-badge">
<a href="https://github.com/beyond-the-cloud-dev/test-lib/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-mit-green?style=for-the-badge"></a>
<img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/beyond-the-cloud-dev/test-lib?style=for-the-badge&logo=github&color=blue">
<img alt="GitHub Release" src="https://img.shields.io/github/v/release/beyond-the-cloud-dev/test-lib?display_name=tag&style=for-the-badge&color=blue">
<!-- <img alt="Codecov" src="https://img.shields.io/codecov/c/github/beyond-the-cloud-dev/test-lib?style=for-the-badge"> -->
</div>

# Getting Started

The Test Lib allows for easy test data creation in Apex.

Test Lib is part of [Apex Fluently](https://apexfluently.beyondthecloud.dev/), a suite of production-ready Salesforce libraries by [Beyond the Cloud](https://blog.beyondthecloud.dev/blog).

**Test Module**

```java
@IsTest
public class ContactTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static Builder Builder() {
        return new Builder();
    }

    public static Mocker Mocker() {
        return new Mocker();
    }

    public class Builder extends TestModule.RecordBuilder {
        public Builder() {
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

    public class Mocker extends TestModule.RecordMocker {
        public Mocker() {
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
```

## Deploy to Salesforce

<a href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=test-lib&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

# Documentation 

Visit the [documentation](https://testlib.beyondthecloud.dev/) to view the full documentation.

## Features

Read about the features in the [basic features](https://testlib.beyondthecloud.dev/getting-started.html).

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- Each original class should contain copyright mark: Copyright (c) 2026 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
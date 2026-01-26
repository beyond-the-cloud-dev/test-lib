# Testing Guide

Comprehensive guide to testing in this Salesforce template.

## Overview

This template includes:

- **LWC Jest** for Lightning Web Component testing
- **Apex Test Framework** for server-side testing
- **Code Coverage** reporting with CodeCov
- **CI/CD Integration** for automated testing

## LWC Jest Testing

### Running Tests

```bash
# Run all tests
npm test

# Watch mode (auto-run on file changes)
npm run test:unit:watch

# Debug mode
npm run test:unit:debug

# Generate coverage report
npm run test:unit:coverage
```

### Test File Structure

Tests are located alongside components in `__tests__/` folders:

```
lwc/myComponent/
├── myComponent.html
├── myComponent.js
├── myComponent.css
├── myComponent.js-meta.xml
└── __tests__/
    └── myComponent.test.js
```

### Basic Test Structure

```javascript
import { createElement } from "lwc";
import MyComponent from "c/myComponent";

describe("c-my-component", () => {
  afterEach(() => {
    // Clean up DOM after each test
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders correctly", () => {
    // Create element
    const element = createElement("c-my-component", {
      is: MyComponent,
    });

    // Add to DOM
    document.body.appendChild(element);

    // Assertions
    expect(element).toBeTruthy();
  });
});
```

### Testing User Interactions

```javascript
it("handles button click", async () => {
  const element = createElement("c-my-component", {
    is: MyComponent,
  });
  document.body.appendChild(element);

  // Find button
  const button = element.shadowRoot.querySelector("button");

  // Click button
  button.click();

  // Wait for async operations
  await Promise.resolve();

  // Assert result
  const result = element.shadowRoot.querySelector(".result");
  expect(result.textContent).toBe("Button clicked");
});
```

### Testing Wire Adapters

```javascript
import { createElement } from "lwc";
import MyComponent from "c/myComponent";
import { getRecord } from "lightning/uiRecordApi";

// Mock the wire adapter
jest.mock(
  "lightning/uiRecordApi",
  () => {
    const { createLdsTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return {
      getRecord: createLdsTestWireAdapter(jest.fn()),
    };
  },
  { virtual: true },
);

describe("c-my-component with wire", () => {
  it("displays record data", async () => {
    const element = createElement("c-my-component", {
      is: MyComponent,
    });
    document.body.appendChild(element);

    // Emit data from wire
    getRecord.emit({
      data: {
        fields: {
          Name: { value: "Test Account" },
        },
      },
    });

    await Promise.resolve();

    const name = element.shadowRoot.querySelector(".account-name");
    expect(name.textContent).toBe("Test Account");
  });

  it("handles wire error", async () => {
    const element = createElement("c-my-component", {
      is: MyComponent,
    });
    document.body.appendChild(element);

    // Emit error from wire
    getRecord.error();

    await Promise.resolve();

    const error = element.shadowRoot.querySelector(".error-message");
    expect(error).toBeTruthy();
  });
});
```

### Testing Apex Calls

```javascript
import { createElement } from "lwc";
import MyComponent from "c/myComponent";
import getAccounts from "@salesforce/apex/AccountController.getAccounts";

// Mock Apex method
jest.mock(
  "@salesforce/apex/AccountController.getAccounts",
  () => {
    return {
      default: jest.fn(),
    };
  },
  { virtual: true },
);

describe("c-my-component with apex", () => {
  it("loads accounts successfully", async () => {
    const mockAccounts = [
      { Id: "001", Name: "Account 1" },
      { Id: "002", Name: "Account 2" },
    ];

    // Mock resolved promise
    getAccounts.mockResolvedValue(mockAccounts);

    const element = createElement("c-my-component", {
      is: MyComponent,
    });
    document.body.appendChild(element);

    // Wait for promises to resolve
    await Promise.resolve();
    await Promise.resolve();

    const accounts = element.shadowRoot.querySelectorAll(".account-item");
    expect(accounts.length).toBe(2);
  });

  it("handles apex error", async () => {
    // Mock rejected promise
    getAccounts.mockRejectedValue(new Error("Failed to load accounts"));

    const element = createElement("c-my-component", {
      is: MyComponent,
    });
    document.body.appendChild(element);

    await Promise.resolve();
    await Promise.resolve();

    const error = element.shadowRoot.querySelector(".error-message");
    expect(error.textContent).toContain("Failed to load accounts");
  });
});
```

### Coverage Requirements

- **Minimum**: 80% code coverage
- **Target**: 90%+ code coverage
- Coverage is measured by CodeCov in CI/CD
- View coverage report: `npm run test:unit:coverage`

### Best Practices

1. **Test user behavior, not implementation**

   ```javascript
   // Good - Tests behavior
   it("displays success message after save", async () => {
     element.save();
     await Promise.resolve();
     expect(element.shadowRoot.querySelector(".success")).toBeTruthy();
   });

   // Bad - Tests implementation
   it("calls saveRecord method", () => {
     const spy = jest.spyOn(element, "saveRecord");
     element.save();
     expect(spy).toHaveBeenCalled();
   });
   ```

2. **One assertion per test (when possible)**

   ```javascript
   // Good
   it("displays account name", () => {
     expect(element.accountName).toBe("Test Account");
   });

   it("displays account industry", () => {
     expect(element.accountIndustry).toBe("Technology");
   });

   // Acceptable for related assertions
   it("displays all account fields", () => {
     expect(element.accountName).toBe("Test Account");
     expect(element.accountIndustry).toBe("Technology");
     expect(element.accountRevenue).toBe(1000000);
   });
   ```

3. **Clean up after each test**
   ```javascript
   afterEach(() => {
     while (document.body.firstChild) {
       document.body.removeChild(document.body.firstChild);
     }
     // Reset mocks
     jest.clearAllMocks();
   });
   ```

## Apex Testing

### Test Class Structure

```apex
@isTest
private class AccountServiceTest {

    @TestSetup
    static void setup() {
        // Create test data
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Industry = 'Technology'
            ));
        }
        insert accounts;
    }

    @isTest
    static void testGetActiveAccounts() {
        // Given
        Test.startTest();

        // When
        List<Account> accounts = AccountService.getActiveAccounts(10);

        // Then
        Test.stopTest();

        System.assertEquals(10, accounts.size(), 'Should return 10 accounts');
        System.assertNotEquals(null, accounts[0].Name, 'Account should have name');
    }

    @isTest
    static void testGetActiveAccountsError() {
        // Test error handling
    }
}
```

### Test Data Factory

Create reusable test data:

```apex
@isTest
public class TestDataFactory {

    public static Account createAccount(String name) {
        return new Account(
            Name = name,
            Industry = 'Technology',
            BillingCity = 'San Francisco'
        );
    }

    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(createAccount('Test Account ' + i));
        }
        return accounts;
    }

    public static Contact createContact(Id accountId) {
        return new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = accountId,
            Email = 'test@example.com'
        );
    }
}
```

Usage:

```apex
@isTest
static void testAccountUpdate() {
    // Create test account
    Account acc = TestDataFactory.createAccount('Test');
    insert acc;

    // Test your logic
    acc.Industry = 'Finance';
    update acc;

    // Assert
    Account updated = [SELECT Industry FROM Account WHERE Id = :acc.Id];
    System.assertEquals('Finance', updated.Industry);
}
```

### Running Apex Tests

```bash
# Run all tests
sf apex run test --test-level RunLocalTests

# Run specific test class
sf apex run test --tests AccountServiceTest

# Run tests with code coverage
sf apex run test --test-level RunLocalTests --code-coverage

# Run tests and output to file
sf apex run test --test-level RunLocalTests --result-format human > test-results.txt
```

### Apex Testing Best Practices

1. **Use Test.startTest() and Test.stopTest()**

   ```apex
   @isTest
   static void testBulkOperation() {
       List<Account> accounts = TestDataFactory.createAccounts(200);
       insert accounts;

       Test.startTest(); // Resets governor limits
       AccountService.processAccounts(accounts);
       Test.stopTest(); // Forces async operations to complete

       // Assertions
   }
   ```

2. **Test bulk operations**

   ```apex
   @isTest
   static void testBulkInsert() {
       List<Account> accounts = new List<Account>();
       for (Integer i = 0; i < 200; i++) {
           accounts.add(new Account(Name = 'Test ' + i));
       }

       Test.startTest();
       insert accounts;
       Test.stopTest();

       System.assertEquals(200, [SELECT COUNT() FROM Account]);
   }
   ```

3. **Test positive and negative scenarios**

   ```apex
   @isTest
   static void testPositiveScenario() {
       // Test expected behavior
   }

   @isTest
   static void testNegativeScenario() {
       // Test error handling
       try {
           AccountService.invalidOperation();
           System.assert(false, 'Should have thrown exception');
       } catch (Exception e) {
           System.assert(true, 'Exception expected');
       }
   }
   ```

## CI/CD Testing

### GitHub Actions Integration

Tests run automatically on:

- Pull requests to main branch
- Pushes to main branch
- Manual workflow dispatch

### Workflow Configuration

See [`.github/workflows/ci.yml`](https://github.com/beyond-the-cloud-dev/template/blob/main/.github/workflows/ci.yml):

- Scratch org creation
- Source deployment
- Apex test execution
- LWC Jest tests
- Code coverage upload to CodeCov

### Viewing Test Results

1. **In GitHub**: PR checks show test results
2. **CodeCov**: View coverage reports at codecov.io
3. **Locally**: Run tests before pushing

## Next Steps

- [Deployment Guide](/guide/deployment) - Set up CI/CD
- [LWC Examples](/examples/lwc-examples) - See example tests
- [Best Practices](/examples/best-practices) - Testing best practices

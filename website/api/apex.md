# Apex Classes Reference

This page documents the Apex classes in this project.

## Documentation Template

Use this template when documenting your Apex classes.

---

## Class Name

**Path**: `force-app/main/default/classes/ClassName.cls`

**Type**: Service / Controller / Selector / Helper / Utility

**Sharing**: `with sharing` / `without sharing` / `inherited sharing`

### Description

Brief description of what this class does and its purpose.

### Public Methods

#### `methodName(Type param1, Type param2)`

Description of what this method does.

**Parameters**:

- `param1` (Type) - Description of first parameter
- `param2` (Type) - Description of second parameter

**Returns**: Return type description

**Throws**:

- `ExceptionType` - When this exception occurs

**Example**:

```apex
Type result = ClassName.methodName(value1, value2);
```

### Usage Example

```apex
// Example usage
public class ExampleUsage {
    public static void example() {
        // Your example code
    }
}
```

### Test Class

**Path**: `force-app/main/default/classes/ClassNameTest.cls`

See test class for more examples and usage patterns.

---

## How to Document Your Classes

### 1. Class Header

Document each class with:

- Class name
- File path
- Type (Service, Controller, etc.)
- Sharing mode
- Description

### 2. Method Documentation

For each public method:

```apex
/**
 * @description Method description
 * @param param1 Description of param1
 * @param param2 Description of param2
 * @return Description of return value
 * @throws ExceptionType When exception occurs
 * @example
 * ClassName.methodName(param1, param2);
 */
public static ReturnType methodName(Type1 param1, Type2 param2) {
    // Implementation
}
```

### 3. Usage Examples

Provide realistic code examples:

```apex
// Demonstrate how to use the class
List<Account> accounts = AccountService.getActiveAccounts(10);
for (Account acc : accounts) {
    System.debug(acc.Name);
}
```

### 4. Important Notes

Highlight important information:

::: warning
This method runs without sharing. Ensure proper security checks before use.
:::

::: tip
Use bulkified version for better performance with large data sets.
:::

## Example: Account Service

**Path**: `force-app/main/default/classes/AccountService.cls`

**Type**: Service

**Sharing**: `with sharing`

### Description

Service class for Account-related business logic. Handles account queries, updates, and business rules.

### Public Methods

#### `getActiveAccounts(Integer recordLimit)`

Retrieves active accounts with their related contacts.

**Parameters**:

- `recordLimit` (Integer) - Maximum number of accounts to return (1-200)

**Returns**: `List<Account>` - List of active accounts with contacts

**Throws**:

- `IllegalArgumentException` - If limit is less than 1 or greater than 200

**Example**:

```apex
List<Account> accounts = AccountService.getActiveAccounts(50);
System.debug('Found ' + accounts.size() + ' active accounts');
```

#### `updateAccountIndustry(Id accountId, String newIndustry)`

Updates the industry field for a specific account.

**Parameters**:

- `accountId` (Id) - The account ID to update
- `newIndustry` (String) - The new industry value

**Returns**: `Account` - The updated account record

**Throws**:

- `AccountService.AccountException` - If account not found or update fails

**Example**:

```apex
Account updatedAccount = AccountService.updateAccountIndustry(
    accountId,
    'Technology'
);
```

#### `bulkUpdateIndustries(Map<Id, String> accountIndustries)`

Bulk updates industries for multiple accounts.

**Parameters**:

- `accountIndustries` (Map<Id, String>) - Map of account IDs to new industry values

**Returns**: `List<Database.SaveResult>` - Results of the update operation

**Example**:

```apex
Map<Id, String> updates = new Map<Id, String>{
    acc1Id => 'Finance',
    acc2Id => 'Healthcare'
};
List<Database.SaveResult> results = AccountService.bulkUpdateIndustries(updates);
```

### Inner Classes

#### `AccountException`

Custom exception for account-related errors.

```apex
public class AccountException extends Exception {}
```

### Usage Example

```apex
public class AccountProcessor {
    public static void processAccounts() {
        // Get active accounts
        List<Account> accounts = AccountService.getActiveAccounts(100);

        // Update industries in bulk
        Map<Id, String> updates = new Map<Id, String>();
        for (Account acc : accounts) {
            if (acc.Industry == null) {
                updates.put(acc.Id, 'Other');
            }
        }

        if (!updates.isEmpty()) {
            List<Database.SaveResult> results =
                AccountService.bulkUpdateIndustries(updates);

            // Handle results
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    System.debug('Error: ' + result.getErrors());
                }
            }
        }
    }
}
```

### Governor Limits Considerations

- `getActiveAccounts()`: Uses 1 SOQL query
- `updateAccountIndustry()`: Uses 1 SOQL query, 1 DML statement
- `bulkUpdateIndustries()`: Uses 1 SOQL query, 1 DML statement (bulkified)

::: tip
Always use `bulkUpdateIndustries()` for multiple updates to avoid governor limits.
:::

### Test Class

**Path**: `force-app/main/default/classes/AccountServiceTest.cls`

Coverage: 95%

---

## Example: Account Controller

**Path**: `force-app/main/default/classes/AccountController.cls`

**Type**: LWC Controller

**Sharing**: `with sharing`

### Description

Aura-enabled controller for Account-related Lightning Web Components. Provides cacheable methods for component data access.

### Public Methods

#### `searchAccounts(String searchTerm, Integer maxResults)`

Searches for accounts by name. Cacheable for better performance.

**Annotations**: `@AuraEnabled(cacheable=true)`

**Parameters**:

- `searchTerm` (String) - Search term to find accounts
- `maxResults` (Integer) - Maximum results to return

**Returns**: `List<Account>` - Matching accounts

**Example LWC Usage**:

```javascript
import { LightningElement, wire } from "lwc";
import searchAccounts from "@salesforce/apex/AccountController.searchAccounts";

export default class AccountSearch extends LightningElement {
  searchTerm = "";

  @wire(searchAccounts, {
    searchTerm: "$searchTerm",
    maxResults: 10,
  })
  accounts;
}
```

#### `createAccount(String accountName, String industry)`

Creates a new account record.

**Annotations**: `@AuraEnabled`

**Parameters**:

- `accountName` (String) - Name of the new account
- `industry` (String) - Industry classification

**Returns**: `Id` - ID of newly created account

**Throws**:

- `AuraHandledException` - If creation fails

**Example LWC Usage**:

```javascript
import { LightningElement } from "lwc";
import createAccount from "@salesforce/apex/AccountController.createAccount";

export default class AccountCreate extends LightningElement {
  async handleSave() {
    try {
      const accountId = await createAccount({
        accountName: "New Account",
        industry: "Technology",
      });
      console.log("Created account:", accountId);
    } catch (error) {
      console.error("Error:", error);
    }
  }
}
```

---

## Class Types and Patterns

### Service Classes

Business logic and complex operations.

```apex
public with sharing class AccountService {
    // Business logic methods
}
```

### Controller Classes

LWC/Aura enabled methods.

```apex
public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return AccountSelector.getAll();
    }
}
```

### Selector Classes

SOQL queries and data access.

```apex
public with sharing class AccountSelector {
    public static List<Account> getAll() {
        return [SELECT Id, Name FROM Account];
    }
}
```

### Helper Classes

Utility and helper methods.

```apex
public class DateHelper {
    public static Date getFirstDayOfMonth() {
        // Implementation
    }
}
```

## Best Practices for Class Documentation

1. **JSDoc-style comments**: Use JavaDoc format
2. **Document parameters**: Explain what each parameter does
3. **Include examples**: Show real-world usage
4. **Note exceptions**: Document what can go wrong
5. **Governor limits**: Mention SOQL/DML usage
6. **Link to tests**: Reference test classes
7. **Update regularly**: Keep docs in sync with code

## Next Steps

- [LWC Components Reference](/api/lwc) - Component documentation
- [Apex Examples](/examples/apex-examples) - More code examples
- [Development Guide](/guide/development) - Apex development

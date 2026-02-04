# Introduction

Test Lib is a lightweight Apex library for creating test data with a fluent, chainable API.

## Why Test Lib?

- **Clean Syntax** - Fluent API for readable, maintainable test code
- **Builder Pattern** - Create real database records with `buildAndInsert()`
- **Mocker Pattern** - Create in-memory records without DML operations
- **Templates** - Predefined configurations for common scenarios
- **Randomizers** - Generate unique values for bulk record creation
- **Relationships** - Mock parent lookups and child collections

## Quick Example

```apex
// Builder - creates real records in database
Account acc = (Account) AccountTestModule.Builder()
    .enterprise()
    .buildAndInsert();

// Mocker - creates in-memory records (no DML)
Contact con = (Contact) ContactTestModule.Mocker()
    .setFakeId()
    .set('Account.Name', acc.Name)
    .build();
```

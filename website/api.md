# API Reference

Complete API documentation for Test Lib.

## TestModule Class

The core class containing all interfaces and base implementations.

```apex
@IsTest
@TestVisible
private class TestModule {
    // Interfaces, base classes, and utilities
}
```

## Static Utilities

### IdGenerator

A static utility for generating fake IDs.

```apex
public static final RandomIdGenerator IdGenerator
```

**Usage:**

```apex
Id fakeAccountId = TestModule.IdGenerator.get(Account.SObjectType);
Id fakeContactId = TestModule.IdGenerator.get(Contact.SObjectType);

// Returns valid-looking IDs like 001000000000001, 003000000000002
```

### fakeId()

Convenience method for generating fake IDs.

```apex
public static Id fakeId(SObjectType objectType)
```

**Example:**

```apex
Id fakeId = TestModule.fakeId(Account.SObjectType);
```

### ListRandomizer()

Factory method for creating a list-based randomizer.

```apex
public static FieldRandomizer ListRandomizer(List<Object> values)
```

**Example:**

```apex
TestModule.ListRandomizer(new List<Object>{ 'Technology', 'Finance', 'Healthcare' })
```

## Interfaces

### BuilderProvider

Interface for classes that provide a Builder.

```apex
public interface BuilderProvider {
    Builder Builder();
}
```

### MockerProvider

Interface for classes that provide a Mocker.

```apex
public interface MockerProvider {
    Mocker Mocker();
}
```

### Builder

Interface for building real SObject records.

```apex
public interface Builder {
    Builder set(SObjectField field, Object value);
    Builder set(String field, Object value);
    Builder useTemplate(String templateName);
    Builder withRandomizer(TestModule.RecordRandomizer randomizer);
    Builder withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer);

    SObject build();
    SObject buildAndInsert();
    List<SObject> build(Integer amount);
    List<SObject> buildAndInsert(Integer amount);
}
```

### Mocker

Interface for building in-memory SObject mocks.

```apex
public interface Mocker {
    Mocker set(SObjectField field, Object value);
    Mocker set(String field, Object value);  // Supports dot notation for parent relationships
    Mocker setChildren(String relationship, List<SObject> children);
    Mocker setFakeId();
    Mocker withRandomizer(TestModule.RecordRandomizer randomizer);
    Mocker withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer);

    SObject build();
    List<SObject> build(Integer amount);
}
```

### Template

Interface for defining record templates.

```apex
public interface Template {
    SObject defaultTemplate();
    Map<String, SObject> templates();
}
```

### FieldRandomizer

Interface for generating random values for a single field.

```apex
public interface FieldRandomizer {
    Object generate(Integer index);
}
```

### RecordRandomizer

Interface for generating random values for multiple fields.

```apex
public interface RecordRandomizer {
    Map<SObjectField, TestModule.FieldRandomizer> randomizers();
}
```

## Base Classes

### RecordBuilder

Abstract base class for building real records.

```apex
public abstract class RecordBuilder implements Builder {
    public RecordBuilder(SObject prototype);
    public RecordBuilder(Template templates);
}
```

**Constructors:**
- `RecordBuilder(SObject prototype)` - Initialize with a prototype record
- `RecordBuilder(Template templates)` - Initialize with templates (uses defaultTemplate)

**Methods:**

| Method | Description |
|--------|-------------|
| `set(SObjectField, Object)` | Set field value using field token |
| `set(String, Object)` | Set field value using field name |
| `useTemplate(String)` | Apply a named template |
| `withRandomizer(RecordRandomizer)` | Add record randomizer |
| `withRandomizer(SObjectField, FieldRandomizer)` | Add single field randomizer |
| `build()` | Build single record (no DML) |
| `buildAndInsert()` | Build and insert single record |
| `build(Integer)` | Build multiple records |
| `buildAndInsert(Integer)` | Build and insert multiple records |

### RecordMocker

Abstract base class for building mock records.

```apex
public abstract class RecordMocker implements Mocker {
    public RecordMocker(SObject prototype);
    public RecordMocker(Template templates);
}
```

**Methods:**

| Method | Description |
|--------|-------------|
| `set(SObjectField, Object)` | Set field value using field token |
| `set(String, Object)` | Set field value (supports dot notation for parent relationships) |
| `setChildren(String, List<SObject>)` | Set child relationship records |
| `setFakeId()` | Generate and set a fake ID |
| `withRandomizer(RecordRandomizer)` | Add record randomizer |
| `withRandomizer(SObjectField, FieldRandomizer)` | Add single field randomizer |
| `build()` | Build single mock record |
| `build(Integer)` | Build multiple mock records |

### ListRandomizer

Built-in randomizer that cycles through a list of values.

```apex
public class ListRandomizer implements FieldRandomizer {
    public ListRandomizer(List<Object> values);
    public Object generate(Integer index);
}
```

**Example:**

```apex
// Using static factory method
TestModule.ListRandomizer(new List<Object>{ 'Technology', 'Finance', 'Healthcare' })

// Or instantiate directly
new TestModule.ListRandomizer(new List<Object>{ 'A', 'B', 'C' })
```

## Method Details

### set(SObjectField, Object)

Set a field value using the SObjectField token.

```apex
Builder set(SObjectField field, Object value)
```

**Example:**

```apex
AccountTestModule.Builder()
    .set(Account.Name, 'Acme Corp')
    .set(Account.Industry, 'Technology')
    .build();
```

### set(String, Object)

Set a field value using a string field name. In Mocker, supports dot notation for parent relationships.

```apex
Builder set(String field, Object value)
```

**Example:**

```apex
// Simple field
AccountTestModule.Builder()
    .set('Name', 'Acme Corp')
    .build();

// Parent relationship (Mocker only)
AccountTestModule.Mocker()
    .set('Parent.Name', 'Parent Corp')
    .set('Owner.Name', 'John Doe')
    .build();

// Deeply nested (Mocker only)
ContactTestModule.Mocker()
    .set('Account.Parent.Name', 'Grandparent Corp')
    .build();
```

### useTemplate(String)

Apply a named template to the record.

```apex
Builder useTemplate(String templateName)
```

**Example:**

```apex
AccountTestModule.Builder()
    .useTemplate('enterprise')
    .build();
```

::: warning
Throws `TestModuleException` if templates are not configured or template name not found.
:::

### setChildren(String, List\<SObject\>)

Set child relationship records (Mocker only).

```apex
Mocker setChildren(String relationship, List<SObject> children)
```

**Example:**

```apex
List<SObject> contacts = ContactTestModule.Mocker().build(3);

Account acc = (Account) AccountTestModule.Mocker()
    .setChildren('Contacts', (List<Contact>) contacts)
    .build();

// Access children
Assert.areEqual(3, acc.Contacts.size());
```

### setFakeId()

Generate and set a fake ID for the record (Mocker only).

```apex
Mocker setFakeId()
```

**Example:**

```apex
Account acc = (Account) AccountTestModule.Mocker()
    .setFakeId()
    .build();

// acc.Id is now a valid-looking fake ID like 001000000000001
Assert.isTrue(String.valueOf(acc.Id).startsWith('001'));
```

### withRandomizer(RecordRandomizer)

Add a record randomizer that generates values for multiple fields.

```apex
Builder withRandomizer(TestModule.RecordRandomizer randomizer)
```

**Example:**

```apex
List<SObject> accounts = AccountTestModule.Builder()
    .withRandomizer(new AccountRandomizer())
    .build(10);
```

### withRandomizer(SObjectField, FieldRandomizer)

Add a field randomizer for a specific field.

```apex
Builder withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer)
```

**Example:**

```apex
List<SObject> accounts = AccountTestModule.Builder()
    .withRandomizer(Account.Industry, TestModule.ListRandomizer(new List<Object>{ 'Tech', 'Finance' }))
    .build(10);
```

### build() / build(Integer)

Build records without DML.

```apex
SObject build()
List<SObject> build(Integer amount)
```

**Example:**

```apex
// Single record
Account acc = (Account) AccountTestModule.Builder().build();

// Multiple records
List<SObject> accounts = AccountTestModule.Builder().build(10);
```

### buildAndInsert() / buildAndInsert(Integer)

Build and insert records (Builder only).

```apex
SObject buildAndInsert()
List<SObject> buildAndInsert(Integer amount)
```

**Example:**

```apex
// Single record
Account acc = (Account) AccountTestModule.Builder().buildAndInsert();

// Multiple records with randomizer
List<SObject> accounts = AccountTestModule.Builder()
    .withAccountRandomizer()
    .buildAndInsert(100);
```

## Exception

### TestModuleException

Custom exception for Test Lib errors.

```apex
public class TestModuleException extends Exception {}
```

**Thrown when:**
- `useTemplate()` called without templates configured
- Template name not found

## Examples

[See complete examples →](/examples)

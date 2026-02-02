# API Reference

Complete API documentation for Test Lib.

## TestModule Class

The core class containing all interfaces and base implementations.

```apex
@IsTest
@TestVisible
private class TestModule {
    // Interfaces and implementations
}
```

## Static Methods

### fakeId()

Generate a fake ID for an SObject type.

```apex
public static Id fakeId(SObjectType sot)
```

**Parameters:**
- `sot` - The SObjectType to generate an ID for

**Returns:** A valid-looking fake ID

**Example:**

```apex
Id fakeAccountId = TestModule.fakeId(Account.SObjectType);
// Returns: 001000000000001
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
    Builder withRandomizer(Randomizer randomizer);
    Builder withRandomizer(SObjectField field, FieldRandomizer randomizer);

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
    Mocker set(String field, Object value);
    Mocker setChildren(String relationship, List<SObject> children);
    Mocker setFakeId();
    Mocker withRandomizer(Randomizer randomizer);
    Mocker withRandomizer(SObjectField field, FieldRandomizer randomizer);

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

### Randomizer

Interface for generating random values for multiple fields.

```apex
public interface Randomizer {
    Map<SObjectField, Object> generate(Integer index);
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
- `RecordBuilder(Template templates)` - Initialize with templates

**Methods:**

| Method | Description |
|--------|-------------|
| `set(SObjectField, Object)` | Set field value using field token |
| `set(String, Object)` | Set field value using field name |
| `useTemplate(String)` | Apply a named template |
| `withRandomizer(Randomizer)` | Set record randomizer |
| `withRandomizer(SObjectField, FieldRandomizer)` | Set single field randomizer |
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
| `set(String, Object)` | Set field value using field name (supports dot notation) |
| `setChildren(String, List<SObject>)` | Set child relationship records |
| `setFakeId()` | Generate and set a fake ID |
| `withRandomizer(Randomizer)` | Set record randomizer |
| `withRandomizer(SObjectField, FieldRandomizer)` | Set single field randomizer |
| `build()` | Build single mock record |
| `build(Integer)` | Build multiple mock records |

### RecordRandomizer

Virtual class for composing multiple field randomizers.

```apex
public virtual class RecordRandomizer implements Randomizer {
    public RecordRandomizer setParent(Randomizer parent);
    public RecordRandomizer add(SObjectField field, FieldRandomizer randomizer);
    public Map<SObjectField, Object> generate(Integer index);
}
```

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
new TestModule.ListRandomizer(new List<Object>{'Technology', 'Finance', 'Healthcare'})
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

Set a field value using a string field name. Supports dot notation for parent relationships in Mocker.

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
List<Contact> contacts = ContactTestModule.Mocker().build(3);

Account acc = (Account) AccountTestModule.Mocker()
    .setChildren('Contacts', contacts)
    .build();

// Access children
System.assertEquals(3, acc.Contacts.size());
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
List<Account> accounts = AccountTestModule.Builder().build(10);
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
List<Account> accounts = AccountTestModule.Builder()
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

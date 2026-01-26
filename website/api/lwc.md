# LWC Components Reference

This page documents the Lightning Web Components in this project.

## Documentation Template

Use this template when documenting your LWC components.

---

## Component Name

**Path**: `force-app/main/default/lwc/componentName/`

### Description

Brief description of what this component does and its purpose.

### Properties

| Property      | Type    | Default | Description                          |
| ------------- | ------- | ------- | ------------------------------------ |
| `recordId`    | String  | -       | The ID of the record to display      |
| `showDetails` | Boolean | false   | Whether to show detailed information |
| `maxRecords`  | Number  | 10      | Maximum number of records to display |

### Events

| Event          | Type        | Description                               |
| -------------- | ----------- | ----------------------------------------- |
| `itemselected` | CustomEvent | Fired when a user selects an item         |
| `refresh`      | CustomEvent | Fired when the component needs to refresh |

### Public Methods

#### `refresh()`

Refreshes the component data.

**Returns**: `Promise<void>`

**Example**:

```javascript
this.template.querySelector("c-my-component").refresh();
```

#### `getSelectedItems()`

Returns the currently selected items.

**Returns**: `Array<Object>`

### Usage Example

```html
<template>
  <c-my-component
    record-id="{recordId}"
    show-details="{showDetails}"
    max-records="{maxRecords}"
    onitemselected="{handleItemSelected}"
  ></c-my-component>
</template>
```

```javascript
import { LightningElement, api } from "lwc";

export default class ParentComponent extends LightningElement {
  recordId = "001XXXXXXXXXXXX";
  showDetails = true;
  maxRecords = 20;

  handleItemSelected(event) {
    const selectedItem = event.detail;
    console.log("Selected:", selectedItem);
  }
}
```

### Testing

See test file: `__tests__/componentName.test.js`

---

## How to Document Your Components

### 1. Create Component Section

For each component, add a section with:

- Component name as heading
- Path to component
- Description
- Properties table
- Events table (if applicable)
- Public methods (if any)
- Usage examples
- Link to tests

### 2. Properties Table

Document all public properties:

```markdown
| Property       | Type | Default      | Description  |
| -------------- | ---- | ------------ | ------------ |
| `propertyName` | Type | defaultValue | What it does |
```

### 3. Events Table

Document all custom events:

```markdown
| Event       | Type        | Description   |
| ----------- | ----------- | ------------- |
| `eventname` | CustomEvent | When it fires |
```

### 4. Code Examples

Provide realistic usage examples:

```html
<!-- Template example -->
<template>
  <c-your-component property="{value}" onevent="{handler}"></c-your-component>
</template>
```

```javascript
// JavaScript example
import { LightningElement } from "lwc";

export default class Example extends LightningElement {
  // Your code
}
```

### 5. Screenshots (Optional)

Add screenshots if helpful:

```markdown
![Component Screenshot](../public/images/component-screenshot.png)
```

## Example: Account Search Component

**Path**: `force-app/main/default/lwc/accountSearch/`

### Description

A search component that allows users to find and select Salesforce accounts. Features real-time search, debouncing, and keyboard navigation.

### Properties

| Property          | Type   | Default              | Description                             |
| ----------------- | ------ | -------------------- | --------------------------------------- |
| `placeholder`     | String | 'Search accounts...' | Placeholder text for search input       |
| `minSearchLength` | Number | 2                    | Minimum characters before search starts |
| `maxResults`      | Number | 10                   | Maximum number of results to show       |
| `debounceDelay`   | Number | 300                  | Delay in ms before search executes      |

### Events

| Event             | Type        | Description                                                         |
| ----------------- | ----------- | ------------------------------------------------------------------- |
| `accountselected` | CustomEvent | Fired when user selects an account. Detail contains account object. |
| `searchcompleted` | CustomEvent | Fired when search completes. Detail contains results count.         |

### Public Methods

#### `clearSearch()`

Clears the search input and results.

**Example**:

```javascript
this.template.querySelector("c-account-search").clearSearch();
```

#### `focusInput()`

Focuses the search input field programmatically.

### Usage Example

```html
<template>
  <c-account-search
    placeholder="Find an account..."
    min-search-length="{3}"
    max-results="{5}"
    onaccountselected="{handleAccountSelected}"
  ></c-account-search>
</template>
```

```javascript
import { LightningElement } from "lwc";

export default class AccountSelector extends LightningElement {
  selectedAccount;

  handleAccountSelected(event) {
    this.selectedAccount = event.detail;
    console.log("Selected Account:", this.selectedAccount.Name);
  }
}
```

### Wire Adapters Used

- None (uses imperative Apex)

### Apex Methods Called

- `AccountController.searchAccounts(searchTerm, maxResults)`

---

## Best Practices for Component Documentation

1. **Keep it updated**: Update docs when component changes
2. **Be thorough**: Document all public APIs
3. **Provide examples**: Real-world usage examples help users
4. **Link to tests**: Reference test files for more examples
5. **Add screenshots**: Visual aids for complex UIs
6. **Document dependencies**: List required Apex controllers, custom labels, etc.

## Next Steps

- [Apex Classes Reference](/api/apex) - Server-side documentation
- [LWC Examples](/examples/lwc-examples) - More component examples
- [Development Guide](/guide/development) - Component development

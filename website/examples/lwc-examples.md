# LWC Examples

Practical Lightning Web Component examples and patterns.

## Basic Component Structure

### Simple Display Component

```javascript
// myDisplay.js
import { LightningElement, api } from "lwc";

export default class MyDisplay extends LightningElement {
  @api title = "Default Title";
  @api description;

  get hasDescription() {
    return this.description != null;
  }
}
```

```html
<!-- myDisplay.html -->
<template>
  <lightning-card title="{title}">
    <div class="slds-m-around_medium">
      <template if:true="{hasDescription}">
        <p>{description}</p>
      </template>
      <template if:false="{hasDescription}">
        <p>No description provided</p>
      </template>
    </div>
  </lightning-card>
</template>
```

```css
/* myDisplay.css */
p {
  color: #080707;
  font-size: 14px;
}
```

## Wire Adapters

### Wire getRecord

```javascript
import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

const FIELDS = ["Account.Name", "Account.Industry", "Account.AnnualRevenue"];

export default class AccountDisplay extends LightningElement {
  @api recordId;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  account;

  get name() {
    return getFieldValue(this.account.data, FIELDS[0]);
  }

  get industry() {
    return getFieldValue(this.account.data, FIELDS[1]);
  }

  get revenue() {
    return getFieldValue(this.account.data, FIELDS[2]);
  }

  get hasError() {
    return this.account.error != null;
  }
}
```

```html
<template>
  <template if:true="{account.data}">
    <lightning-card title="Account Details">
      <div class="slds-m-around_medium">
        <p><strong>Name:</strong> {name}</p>
        <p><strong>Industry:</strong> {industry}</p>
        <p><strong>Revenue:</strong> {revenue}</p>
      </div>
    </lightning-card>
  </template>

  <template if:true="{hasError}">
    <c-error-panel errors="{account.error}"></c-error-panel>
  </template>
</template>
```

### Wire Apex Method

```javascript
import { LightningElement, wire } from "lwc";
import getAccounts from "@salesforce/apex/AccountController.getAccounts";

export default class AccountList extends LightningElement {
  @wire(getAccounts, { limit: 10 })
  accounts;

  get hasAccounts() {
    return this.accounts.data && this.accounts.data.length > 0;
  }
}
```

## Imperative Apex Calls

### Call Apex Imperatively

```javascript
import { LightningElement } from "lwc";
import createAccount from "@salesforce/apex/AccountController.createAccount";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AccountCreate extends LightningElement {
  accountName = "";
  industry = "";
  isLoading = false;

  handleNameChange(event) {
    this.accountName = event.target.value;
  }

  handleIndustryChange(event) {
    this.industry = event.target.value;
  }

  async handleSave() {
    this.isLoading = true;

    try {
      const accountId = await createAccount({
        name: this.accountName,
        industry: this.industry,
      });

      this.showToast("Success", "Account created successfully", "success");
      this.resetForm();
    } catch (error) {
      this.showToast("Error", error.body.message, "error");
    } finally {
      this.isLoading = false;
    }
  }

  resetForm() {
    this.accountName = "";
    this.industry = "";
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
```

## Custom Events

### Child Component (Event Dispatcher)

```javascript
// accountTile.js
import { LightningElement, api } from "lwc";

export default class AccountTile extends LightningElement {
  @api account;

  handleSelect() {
    const event = new CustomEvent("accountselect", {
      detail: this.account.Id,
    });
    this.dispatchEvent(event);
  }
}
```

```html
<!-- accountTile.html -->
<template>
  <lightning-card title="{account.Name}" onclick="{handleSelect}">
    <div class="slds-m-around_medium">
      <p>Industry: {account.Industry}</p>
    </div>
  </lightning-card>
</template>
```

### Parent Component (Event Listener)

```javascript
// accountList.js
import { LightningElement, wire } from "lwc";
import getAccounts from "@salesforce/apex/AccountController.getAccounts";

export default class AccountList extends LightningElement {
  @wire(getAccounts)
  accounts;

  selectedAccountId;

  handleAccountSelect(event) {
    this.selectedAccountId = event.detail;
    console.log("Selected account:", this.selectedAccountId);
  }
}
```

```html
<!-- accountList.html -->
<template>
  <template if:true="{accounts.data}">
    <template for:each="{accounts.data}" for:item="account">
      <c-account-tile
        key="{account.Id}"
        account="{account}"
        onaccountselect="{handleAccountSelect}"
      >
      </c-account-tile>
    </template>
  </template>

  <template if:true="{selectedAccountId}">
    <p>Selected: {selectedAccountId}</p>
  </template>
</template>
```

## Lightning Data Service

### Create Record

```javascript
import { LightningElement } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import NAME_FIELD from "@salesforce/schema/Account.Name";
import INDUSTRY_FIELD from "@salesforce/schema/Account.Industry";

export default class AccountCreate extends LightningElement {
  async handleCreate() {
    const fields = {};
    fields[NAME_FIELD.fieldApiName] = "New Account";
    fields[INDUSTRY_FIELD.fieldApiName] = "Technology";

    const recordInput = { apiName: ACCOUNT_OBJECT.objectApiName, fields };

    try {
      const account = await createRecord(recordInput);
      console.log("Account created:", account.id);
    } catch (error) {
      console.error("Error creating account:", error);
    }
  }
}
```

### Update Record

```javascript
import { LightningElement, api } from "lwc";
import { updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Account.Id";
import NAME_FIELD from "@salesforce/schema/Account.Name";

export default class AccountUpdate extends LightningElement {
  @api recordId;

  async handleUpdate() {
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[NAME_FIELD.fieldApiName] = "Updated Name";

    const recordInput = { fields };

    try {
      await updateRecord(recordInput);
      console.log("Account updated");
    } catch (error) {
      console.error("Error updating account:", error);
    }
  }
}
```

## Navigation

### Navigate to Record Page

```javascript
import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class AccountNavigator extends NavigationMixin(
  LightningElement,
) {
  @api recordId;

  navigateToRecord() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Account",
        actionName: "view",
      },
    });
  }

  navigateToEdit() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Account",
        actionName: "edit",
      },
    });
  }

  navigateToNew() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Account",
        actionName: "new",
      },
    });
  }
}
```

### Navigate to App Page

```javascript
import { NavigationMixin } from "lightning/navigation";
import { LightningElement } from "lwc";

export default class AppNavigator extends NavigationMixin(LightningElement) {
  navigateToApp() {
    this[NavigationMixin.Navigate]({
      type: "standard__app",
      attributes: {
        appTarget: "c__MyApp",
      },
    });
  }

  navigateToWebPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "https://beyondthecloud.dev",
      },
    });
  }
}
```

## Pubsub Pattern (Lightning Message Service)

### Publish Message

```javascript
import { LightningElement, wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import ACCOUNT_SELECTED_CHANNEL from "@salesforce/messageChannel/AccountSelected__c";

export default class AccountPublisher extends LightningElement {
  @wire(MessageContext)
  messageContext;

  handleAccountSelect(accountId) {
    const message = {
      accountId: accountId,
    };
    publish(this.messageContext, ACCOUNT_SELECTED_CHANNEL, message);
  }
}
```

### Subscribe to Message

```javascript
import { LightningElement, wire } from "lwc";
import { subscribe, MessageContext } from "lightning/messageService";
import ACCOUNT_SELECTED_CHANNEL from "@salesforce/messageChannel/AccountSelected__c";

export default class AccountSubscriber extends LightningElement {
  subscription = null;
  selectedAccountId;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToChannel();
  }

  subscribeToChannel() {
    this.subscription = subscribe(
      this.messageContext,
      ACCOUNT_SELECTED_CHANNEL,
      (message) => this.handleMessage(message),
    );
  }

  handleMessage(message) {
    this.selectedAccountId = message.accountId;
  }
}
```

## Common Patterns

### Loading State

```javascript
import { LightningElement } from "lwc";
import getAccounts from "@salesforce/apex/AccountController.getAccounts";

export default class AccountList extends LightningElement {
  accounts = [];
  error;
  isLoading = false;

  async connectedCallback() {
    await this.loadAccounts();
  }

  async loadAccounts() {
    this.isLoading = true;
    try {
      this.accounts = await getAccounts();
      this.error = undefined;
    } catch (error) {
      this.error = error;
      this.accounts = [];
    } finally {
      this.isLoading = false;
    }
  }
}
```

```html
<template>
  <template if:true="{isLoading}">
    <lightning-spinner alternative-text="Loading"></lightning-spinner>
  </template>

  <template if:true="{accounts}">
    <!-- Display accounts -->
  </template>

  <template if:true="{error}">
    <div class="slds-text-color_error">Error: {error.message}</div>
  </template>
</template>
```

### Debounced Search

```javascript
import { LightningElement } from "lwc";
import searchAccounts from "@salesforce/apex/AccountController.searchAccounts";

export default class AccountSearch extends LightningElement {
  searchTerm = "";
  accounts = [];
  debounceTimeout;

  handleSearchTermChange(event) {
    const searchTerm = event.target.value;

    // Clear previous timeout
    clearTimeout(this.debounceTimeout);

    // Set new timeout
    this.debounceTimeout = setTimeout(() => {
      this.searchTerm = searchTerm;
      this.performSearch();
    }, 300); // Wait 300ms after user stops typing
  }

  async performSearch() {
    if (this.searchTerm.length < 2) {
      this.accounts = [];
      return;
    }

    try {
      this.accounts = await searchAccounts({
        searchTerm: this.searchTerm,
      });
    } catch (error) {
      console.error("Search error:", error);
    }
  }
}
```

## Next Steps

- [Apex Examples](/examples/apex-examples) - Server-side examples
- [Best Practices](/examples/best-practices) - LWC best practices
- [Testing Guide](/guide/testing) - Learn to test components

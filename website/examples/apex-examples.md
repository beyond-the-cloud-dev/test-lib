# Apex Examples

Practical Apex code examples and patterns for Salesforce development.

## Service Layer Pattern

### Account Service

```apex
/**
 * @description Service class for Account operations
 */
public with sharing class AccountService {

    /**
     * @description Gets active accounts with contacts
     * @param recordLimit Maximum number of records
     * @return List of accounts with related contacts
     */
    public static List<Account> getActiveAccounts(Integer recordLimit) {
        if (recordLimit < 1 || recordLimit > 200) {
            throw new IllegalArgumentException('Limit must be between 1 and 200');
        }

        return [
            SELECT Id, Name, Industry, AnnualRevenue,
                   (SELECT Id, Name, Email FROM Contacts LIMIT 10)
            FROM Account
            WHERE IsActive__c = true
            ORDER BY CreatedDate DESC
            LIMIT :recordLimit
        ];
    }

    /**
     * @description Updates account industries in bulk
     * @param accountIndustries Map of account IDs to new industries
     * @return List of Database.SaveResult
     */
    public static List<Database.SaveResult> updateIndustries(
        Map<Id, String> accountIndustries
    ) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accountId : accountIndustries.keySet()) {
            accountsToUpdate.add(new Account(
                Id = accountId,
                Industry = accountIndustries.get(accountId)
            ));
        }

        return Database.update(accountsToUpdate, false);
    }

    /**
     * @description Deactivates accounts older than specified days
     * @param daysOld Number of days
     * @return Number of accounts deactivated
     */
    public static Integer deactivateOldAccounts(Integer daysOld) {
        Date cutoffDate = Date.today().addDays(-daysOld);

        List<Account> accountsToDeactivate = [
            SELECT Id
            FROM Account
            WHERE CreatedDate < :cutoffDate
            AND IsActive__c = true
        ];

        for (Account acc : accountsToDeactivate) {
            acc.IsActive__c = false;
        }

        update accountsToDeactivate;
        return accountsToDeactivate.size();
    }
}
```

## LWC Controller Pattern

### Aura-Enabled Controller

```apex
/**
 * @description Lightning Web Component controller for Accounts
 */
public with sharing class AccountController {

    /**
     * @description Searches accounts by name
     * @param searchTerm Search string
     * @param maxResults Maximum results to return
     * @return List of matching accounts
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(
        String searchTerm,
        Integer maxResults
    ) {
        String searchPattern = '%' + searchTerm + '%';

        return [
            SELECT Id, Name, Industry, Phone, BillingCity
            FROM Account
            WHERE Name LIKE :searchPattern
            ORDER BY Name
            LIMIT :maxResults
        ];
    }

    /**
     * @description Creates a new account
     * @param name Account name
     * @param industry Account industry
     * @return Id of created account
     */
    @AuraEnabled
    public static Id createAccount(String name, String industry) {
        try {
            Account newAccount = new Account(
                Name = name,
                Industry = industry
            );

            insert newAccount;
            return newAccount.Id;

        } catch (Exception e) {
            throw new AuraHandledException('Error creating account: ' + e.getMessage());
        }
    }

    /**
     * @description Updates account record
     * @param accountId Account ID to update
     * @param fieldName Field API name
     * @param fieldValue New value
     */
    @AuraEnabled
    public static void updateAccountField(
        Id accountId,
        String fieldName,
        Object fieldValue
    ) {
        try {
            Account acc = new Account(Id = accountId);
            acc.put(fieldName, fieldValue);
            update acc;

        } catch (Exception e) {
            throw new AuraHandledException('Error updating account: ' + e.getMessage());
        }
    }
}
```

## Selector Pattern

### Account Selector

```apex
/**
 * @description Selector class for Account queries
 */
public with sharing class AccountSelector {

    /**
     * @description Gets accounts by IDs
     * @param accountIds Set of account IDs
     * @return List of accounts
     */
    public static List<Account> getByIds(Set<Id> accountIds) {
        return [
            SELECT Id, Name, Industry, AnnualRevenue,
                   BillingCity, BillingState, BillingCountry
            FROM Account
            WHERE Id IN :accountIds
        ];
    }

    /**
     * @description Gets accounts by industry
     * @param industries Set of industry values
     * @param recordLimit Maximum records
     * @return List of accounts
     */
    public static List<Account> getByIndustry(
        Set<String> industries,
        Integer recordLimit
    ) {
        return [
            SELECT Id, Name, Industry, AnnualRevenue
            FROM Account
            WHERE Industry IN :industries
            ORDER BY AnnualRevenue DESC NULLS LAST
            LIMIT :recordLimit
        ];
    }

    /**
     * @description Gets accounts with contacts
     * @param accountIds Set of account IDs
     * @return List of accounts with contacts
     */
    public static List<Account> getWithContacts(Set<Id> accountIds) {
        return [
            SELECT Id, Name,
                   (SELECT Id, FirstName, LastName, Email
                    FROM Contacts
                    WHERE IsActive__c = true)
            FROM Account
            WHERE Id IN :accountIds
        ];
    }

    /**
     * @description Dynamic SOQL query builder
     * @param fields List of field API names
     * @param whereClause WHERE condition
     * @param orderBy ORDER BY clause
     * @param recordLimit LIMIT value
     * @return List of accounts
     */
    public static List<Account> queryAccounts(
        List<String> fields,
        String whereClause,
        String orderBy,
        Integer recordLimit
    ) {
        String query = 'SELECT ' + String.join(fields, ', ') +
                       ' FROM Account';

        if (String.isNotBlank(whereClause)) {
            query += ' WHERE ' + whereClause;
        }

        if (String.isNotBlank(orderBy)) {
            query += ' ORDER BY ' + orderBy;
        }

        if (recordLimit != null) {
            query += ' LIMIT ' + recordLimit;
        }

        return Database.query(query);
    }
}
```

## Trigger Handler Pattern

### Account Trigger

```apex
/**
 * @description Trigger on Account
 */
trigger AccountTrigger on Account (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    handler.execute();
}
```

### Trigger Handler

```apex
/**
 * @description Handler for Account trigger
 */
public class AccountTriggerHandler extends TriggerHandler {

    private List<Account> newAccounts;
    private List<Account> oldAccounts;
    private Map<Id, Account> newAccountMap;
    private Map<Id, Account> oldAccountMap;

    public AccountTriggerHandler() {
        this.newAccounts = (List<Account>) Trigger.new;
        this.oldAccounts = (List<Account>) Trigger.old;
        this.newAccountMap = (Map<Id, Account>) Trigger.newMap;
        this.oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        validateAccounts(newAccounts);
        setDefaultValues(newAccounts);
    }

    public override void beforeUpdate() {
        validateAccounts(newAccounts);
        preventIndustryChange(newAccountMap, oldAccountMap);
    }

    public override void afterInsert() {
        createDefaultContacts(newAccounts);
    }

    public override void afterUpdate() {
        if (hasIndustryChanged(newAccountMap, oldAccountMap)) {
            updateRelatedOpportunities(newAccountMap.keySet());
        }
    }

    private void validateAccounts(List<Account> accounts) {
        for (Account acc : accounts) {
            if (String.isBlank(acc.Name)) {
                acc.addError('Account name is required');
            }

            if (acc.AnnualRevenue != null && acc.AnnualRevenue < 0) {
                acc.AnnualRevenue.addError('Annual Revenue cannot be negative');
            }
        }
    }

    private void setDefaultValues(List<Account> accounts) {
        for (Account acc : accounts) {
            if (String.isBlank(acc.Industry)) {
                acc.Industry = 'Other';
            }

            if (acc.IsActive__c == null) {
                acc.IsActive__c = true;
            }
        }
    }

    private void preventIndustryChange(
        Map<Id, Account> newMap,
        Map<Id, Account> oldMap
    ) {
        for (Id accountId : newMap.keySet()) {
            Account newAccount = newMap.get(accountId);
            Account oldAccount = oldMap.get(accountId);

            if (newAccount.Industry != oldAccount.Industry &&
                oldAccount.IsLocked__c == true) {
                newAccount.Industry.addError(
                    'Cannot change industry for locked accounts'
                );
            }
        }
    }

    private void createDefaultContacts(List<Account> accounts) {
        List<Contact> contactsToInsert = new List<Contact>();

        for (Account acc : accounts) {
            contactsToInsert.add(new Contact(
                AccountId = acc.Id,
                LastName = 'Default Contact',
                Email = 'contact@' + acc.Name.toLowerCase() + '.com'
            ));
        }

        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }

    private Boolean hasIndustryChanged(
        Map<Id, Account> newMap,
        Map<Id, Account> oldMap
    ) {
        for (Id accountId : newMap.keySet()) {
            if (newMap.get(accountId).Industry != oldMap.get(accountId).Industry) {
                return true;
            }
        }
        return false;
    }

    private void updateRelatedOpportunities(Set<Id> accountIds) {
        // Implementation here
    }
}
```

### Base Trigger Handler

```apex
/**
 * @description Base class for trigger handlers
 */
public virtual class TriggerHandler {

    public void execute() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) beforeInsert();
            if (Trigger.isUpdate) beforeUpdate();
            if (Trigger.isDelete) beforeDelete();
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert) afterInsert();
            if (Trigger.isUpdate) afterUpdate();
            if (Trigger.isDelete) afterDelete();
            if (Trigger.isUndelete) afterUndelete();
        }
    }

    public virtual void beforeInsert() {}
    public virtual void beforeUpdate() {}
    public virtual void beforeDelete() {}
    public virtual void afterInsert() {}
    public virtual void afterUpdate() {}
    public virtual void afterDelete() {}
    public virtual void afterUndelete() {}
}
```

## Batch Apex

### Account Batch Processor

```apex
/**
 * @description Batch class to process accounts
 */
public class AccountBatchProcessor implements Database.Batchable<SObject> {

    private String industry;
    private Integer daysOld;

    public AccountBatchProcessor(String industry, Integer daysOld) {
        this.industry = industry;
        this.daysOld = daysOld;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date cutoffDate = Date.today().addDays(-daysOld);

        return Database.getQueryLocator([
            SELECT Id, Name, Industry, LastModifiedDate
            FROM Account
            WHERE Industry = :industry
            AND LastModifiedDate < :cutoffDate
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : scope) {
            acc.IsArchived__c = true;
            acc.ArchiveDate__c = Date.today();
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Send completion email
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors,
                   JobItemsProcessed, TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        System.debug('Batch job completed: ' + job.Status);
        System.debug('Records processed: ' + job.TotalJobItems);
    }
}
```

**Execute batch:**

```apex
AccountBatchProcessor batch = new AccountBatchProcessor('Technology', 365);
Database.executeBatch(batch, 200);
```

## Queueable Apex

### Account Processor Queueable

```apex
/**
 * @description Queueable for account processing
 */
public class AccountProcessor implements Queueable {

    private List<Id> accountIds;
    private String updateType;

    public AccountProcessor(List<Id> accountIds, String updateType) {
        this.accountIds = accountIds;
        this.updateType = updateType;
    }

    public void execute(QueueableContext context) {
        List<Account> accounts = [
            SELECT Id, Name, Industry
            FROM Account
            WHERE Id IN :accountIds
        ];

        for (Account acc : accounts) {
            if (updateType == 'ENRICH') {
                enrichAccount(acc);
            } else if (updateType == 'ARCHIVE') {
                archiveAccount(acc);
            }
        }

        update accounts;

        // Chain another queueable if needed
        if (hasMoreWork()) {
            System.enqueueJob(new AccountProcessor(getNextBatch(), updateType));
        }
    }

    private void enrichAccount(Account acc) {
        // Callout to external service or complex processing
        acc.Description = 'Enriched on ' + System.now();
    }

    private void archiveAccount(Account acc) {
        acc.IsArchived__c = true;
        acc.ArchiveDate__c = Date.today();
    }

    private Boolean hasMoreWork() {
        return false; // Implement your logic
    }

    private List<Id> getNextBatch() {
        return new List<Id>(); // Implement your logic
    }
}
```

**Execute queueable:**

```apex
List<Id> accountIds = new List<Id>{acc1.Id, acc2.Id};
System.enqueueJob(new AccountProcessor(accountIds, 'ENRICH'));
```

## Utility Classes

### Date Helper

```apex
/**
 * @description Utility class for date operations
 */
public class DateHelper {

    /**
     * @description Gets the first day of current month
     */
    public static Date getFirstDayOfMonth() {
        Date today = Date.today();
        return Date.newInstance(today.year(), today.month(), 1);
    }

    /**
     * @description Gets the last day of current month
     */
    public static Date getLastDayOfMonth() {
        Date firstDay = getFirstDayOfMonth();
        return firstDay.addMonths(1).addDays(-1);
    }

    /**
     * @description Checks if date is weekend
     */
    public static Boolean isWeekend(Date dateToCheck) {
        DateTime dt = DateTime.newInstance(dateToCheck, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday';
    }

    /**
     * @description Gets business days between two dates
     */
    public static Integer getBusinessDays(Date startDate, Date endDate) {
        Integer businessDays = 0;
        Date currentDate = startDate;

        while (currentDate <= endDate) {
            if (!isWeekend(currentDate)) {
                businessDays++;
            }
            currentDate = currentDate.addDays(1);
        }

        return businessDays;
    }
}
```

## Next Steps

- [LWC Examples](/examples/lwc-examples) - Component examples
- [Best Practices](/examples/best-practices) - Coding best practices
- [Development Guide](/guide/development) - Development workflow

/**
 * Visualforce controller extension for the InvoicePdf page.
 * Loads an Invoice with its client/contact details and child Invoice Lines for PDF rendering.
 * Read-only: performs no DML.
 */
public with sharing class InvoicePdfController {

    public Invoice__c invoice { get; private set; }
    public List<Invoice_Line__c> lines { get; private set; }

    public InvoicePdfController(ApexPages.StandardController stdController) {
        load(stdController.getId());
    }

    @TestVisible
    private void load(Id invoiceId) {
        invoice = [
            SELECT Id, Name, Invoice_Date__c, Due_Date__c, Status__c, Payment_Terms__c,
                   Service_Period_Start__c, Service_Period_End__c,
                   Subtotal__c, Tax_Rate__c, Tax_Amount__c, Total__c, Total_Hours__c, Amount_Paid__c, Balance__c, Notes__c,
                   Account__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,
                   Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,
                   Billing_Contact__c, Billing_Contact__r.Name, Billing_Contact__r.Email, Billing_Contact__r.Phone
            FROM Invoice__c
            WHERE Id = :invoiceId
            LIMIT 1
        ];
        lines = [
            SELECT Id, Service_Start_Date__c, Service_End_Date__c, Days__c, Description__c, Hours__c, Rate__c, Amount__c
            FROM Invoice_Line__c
            WHERE Invoice__c = :invoiceId
            ORDER BY Service_Start_Date__c NULLS LAST, Name
        ];
    }
}

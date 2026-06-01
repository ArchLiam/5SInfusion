@isTest
private class InvoicePdfControllerTest {

    @isTest
    static void loadsInvoiceAndLines() {
        Account acct = new Account(Name = 'Gamma Test', BillingCity = 'Austin', BillingState = 'TX');
        insert acct;
        Contact c = new Contact(LastName = 'Payer', AccountId = acct.Id, Email = 'payer@example.com');
        insert c;
        Invoice__c inv = new Invoice__c(
            Account__c = acct.Id, Billing_Contact__c = c.Id,
            Invoice_Date__c = Date.today(), Due_Date__c = Date.today().addDays(30),
            Status__c = 'Draft', Tax_Rate__c = 0
        );
        insert inv;
        insert new List<Invoice_Line__c>{
            new Invoice_Line__c(Invoice__c = inv.Id, Description__c = 'Line A',
                Service_Start_Date__c = Date.today(), Service_End_Date__c = Date.today(), Hours__c = 2, Rate__c = 100),
            new Invoice_Line__c(Invoice__c = inv.Id, Description__c = 'Line B',
                Service_Start_Date__c = Date.today(), Service_End_Date__c = Date.today(), Hours__c = 1, Rate__c = 200)
        };

        Test.setCurrentPage(Page.InvoicePdf);
        ApexPages.currentPage().getParameters().put('id', inv.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(inv);

        Test.startTest();
        InvoicePdfController ctrl = new InvoicePdfController(sc);
        Test.stopTest();

        System.assertEquals(inv.Id, ctrl.invoice.Id, 'Invoice should load');
        System.assertEquals('Gamma Test', ctrl.invoice.Account__r.Name, 'Account relationship should load');
        System.assertEquals(2, ctrl.lines.size(), 'Both invoice lines should load');
    }
}

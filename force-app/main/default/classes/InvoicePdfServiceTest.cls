@isTest
private class InvoicePdfServiceTest {

    private static Invoice__c makeInvoice() {
        Account acct = new Account(Name = 'Acme Test');
        insert acct;
        Invoice__c inv = new Invoice__c(
            Account__c = acct.Id,
            Invoice_Date__c = Date.today(),
            Due_Date__c = Date.today().addDays(30),
            Status__c = 'Draft',
            Tax_Rate__c = 0
        );
        insert inv;
        insert new Invoice_Line__c(
            Invoice__c = inv.Id, Description__c = 'Consulting',
            Service_Start_Date__c = Date.today(), Service_End_Date__c = Date.today(),
            Hours__c = 3, Rate__c = 150
        );
        return inv;
    }

    @isTest
    static void generatesAndAttachesPdf() {
        Invoice__c inv = makeInvoice();

        Test.startTest();
        Id docId = InvoicePdfService.generateInvoicePdf(inv.Id);
        Test.stopTest();

        System.assertNotEquals(null, docId, 'Should return a ContentDocumentId');
        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :inv.Id
        ];
        System.assertEquals(1, links.size(), 'PDF should be linked to the invoice');
    }

    @isTest
    static void invocableGeneratesPdf() {
        Invoice__c inv = makeInvoice();

        InvoicePdfInvocable.Request req = new InvoicePdfInvocable.Request();
        req.invoiceId = inv.Id;

        Test.startTest();
        InvoicePdfInvocable.generate(new List<InvoicePdfInvocable.Request>{ req });
        Test.stopTest(); // the enqueued InvoicePdfQueueable runs at stopTest

        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :inv.Id
        ];
        System.assert(!links.isEmpty(), 'PDF should be attached after the queueable runs');
    }
}

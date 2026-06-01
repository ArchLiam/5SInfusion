/**
 * Renders the InvoicePdf Visualforce page for an Invoice and stores the result
 * as a Salesforce File (ContentVersion) linked to the Invoice record.
 *
 * Two entry points share one implementation:
 *  - generateInvoicePdf  : @AuraEnabled, called by the invoicePdfAction LWC quick action.
 *  - InvoicePdfInvocable : @InvocableMethod wrapper, lets Flow (re)generate + email later.
 */
public with sharing class InvoicePdfService {

    @AuraEnabled
    public static Id generateInvoicePdf(Id invoiceId) {
        try {
            return generateAndAttach(invoiceId);
        } catch (Exception e) {
            throw new AuraHandledException('Could not generate invoice PDF: ' + e.getMessage());
        }
    }

    /**
     * Renders the PDF and inserts a ContentVersion linked to the Invoice.
     * @return the ContentDocumentId of the stored file.
     */
    public static Id generateAndAttach(Id invoiceId) {
        Invoice__c inv = [SELECT Id, Name FROM Invoice__c WHERE Id = :invoiceId LIMIT 1];

        PageReference pdfPage = Page.InvoicePdf;
        pdfPage.getParameters().put('id', invoiceId);

        // getContentAsPDF() returns a stub in test context, so guard it.
        Blob pdfBody = Test.isRunningTest()
            ? Blob.valueOf('TEST PDF for ' + inv.Name)
            : pdfPage.getContentAsPDF();

        String fileName = inv.Name + ' ' + Datetime.now().format('yyyy-MM-dd HH-mm-ss');
        ContentVersion cv = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName + '.pdf',
            VersionData = pdfBody,
            IsMajorVersion = true,
            FirstPublishLocationId = invoiceId
        );
        insert cv;

        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
    }
}

/**
 * Flow-callable wrapper around InvoicePdfService. Enables a future (phase 2)
 * Flow to regenerate the invoice PDF and email it without changing the core service.
 */
public with sharing class InvoicePdfInvocable {

    public class Request {
        @InvocableVariable(required=true label='Invoice Id')
        public Id invoiceId;
    }

    public class Result {
        @InvocableVariable(label='Content Document Id')
        public Id contentDocumentId;
    }

    @InvocableMethod(label='Generate Invoice PDF' description='Generates the invoice PDF asynchronously (after the calling transaction commits) and attaches it to the Invoice record.')
    public static List<Result> generate(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            // Defer rendering to a separate transaction so getContentAsPDF() sees
            // the Invoice Lines the calling flow just created (uncommitted DML is
            // invisible to the PDF renderer in the same transaction).
            System.enqueueJob(new InvoicePdfQueueable(req.invoiceId));
            results.add(new Result());
        }
        return results;
    }
}

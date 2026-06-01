/**
 * Generates and attaches the invoice PDF in a separate (async) transaction.
 *
 * Why async: the Generate Invoice flow creates the Invoice Lines and then asks
 * for the PDF in the SAME transaction. PageReference.getContentAsPDF() renders
 * the page without seeing uncommitted DML, so an inline render produces an empty
 * PDF ($0 totals, no line rows). Enqueuing this Queueable defers the render until
 * after the flow's transaction commits, so the lines are visible.
 */
public with sharing class InvoicePdfQueueable implements Queueable, Database.AllowsCallouts {

    private final Id invoiceId;

    public InvoicePdfQueueable(Id invoiceId) {
        this.invoiceId = invoiceId;
    }

    public void execute(QueueableContext context) {
        InvoicePdfService.generateAndAttach(invoiceId);
    }
}

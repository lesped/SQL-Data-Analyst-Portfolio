Select Customer.CustomerId,
Invoice.InvoiceId,
Invoice.InvoiceDate as DATE_facture,
Invoice.Total as CA_client,
first_value (Invoice.Total) over(partition by Customer.CustomerId order by Invoice.InvoiceDate) as premiere_facture,
(Invoice.Total) - (first_value (Invoice.Total) over(partition by Customer.CustomerId order by Invoice.InvoiceDate)) as difference
FROM Customer join Invoice on Customer.CustomerId = Invoice.CustomerId ;
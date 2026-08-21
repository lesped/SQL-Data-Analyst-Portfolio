Select
Customer.CustomerId,
Invoice.InvoiceId,
Invoice.InvoiceDate as "date",
invoice.total as "CA", 
FIRST_VALUE(total) over(partition by Customer.CustomerId order by Invoice.InvoiceDate) as premiere_facture
from customer join invoice on Customer.CustomerId = Invoice.CustomerId ;
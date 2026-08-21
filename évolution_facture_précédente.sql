With depenses_clients AS (
  SELECT Invoice.CustomerId,
  Invoice.InvoiceId,
  Invoice.InvoiceDate,
  Invoice.Total as CA_client,
  LAG(Invoice.total) over(partition by Invoice.CustomerId order by Invoice.InvoiceDate) as facture_precedente
  from Invoice)
  
Select *,
  CA_client - facture_precedente as ecart
  from depenses_clients ;
  
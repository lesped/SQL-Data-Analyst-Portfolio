With client_CA as ( SELECT
                   Customer.CustomerId,
                   Customer.FirstName as prenom,
                   Customer.LastName as nom,
                   sum(invoice.Total) as Ca_client,
                   MAX(invoice.invoicedate) as derniere_facture,
                   count (invoice.InvoiceId) as nb_factures
FROM
                   Customer JOIN
                   Invoice ON Customer.CustomerId = invoice.CustomerId
group by customer.CustomerId,
         Customer.FirstName,
         Customer.LastName),
                     
rang_client as (SELECT *, ntile(5) over(order by Ca_client DESC) as ntile_ca from client_CA),

segmentation as (
  
  select *, case
                 WHEN ntile_ca =1 then 'VIP'
                 WHEN nb_factures >10 THEN 'Actif'
                 WHEN nb_factures =1 THEN 'à risque'
                 ELSE 'Standard'
                 End AS segment_client
From rang_client
                 )

Select * from segmentation;
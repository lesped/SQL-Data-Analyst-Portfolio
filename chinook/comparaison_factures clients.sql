With depenses_clients as (Select invoice.CustomerId,
invoice.InvoiceDate,
Invoice.Total as CA_client,
first_value (total) over(partition by invoice.CustomerId order by invoice.InvoiceDate ASC) as premiere_facture,
LAST_VALUE(total) OVER (
    PARTITION BY Invoice.CustomerId
    ORDER BY Invoice.InvoiceDate
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND UNBOUNDED FOLLOWING
) as derniere_facture
from invoice
order by invoice.InvoiceDate),

clients_synthese as (SELECT DISTINCT CustomerId,
                     premiere_facture,
                     derniere_facture from depenses_clients),

evolution as (select *, ((derniere_facture-premiere_facture)/premiere_facture)*100 as evolution_pct from clients_synthese),

Segmentation as (SELECt *, case 
                 	       When evolution_pct >= 50 THEN 'croissance forte'
                 		   When evolution_pct >= 10 THEN 'croissance modere'
                 		   WHEN evolution_pct > -10 THEN 'stable'
                 		   else 'declin'
                 		   end as segment_client
                 from evolution)
SELECT * from Segmentation ;
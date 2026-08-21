With client_pays as (select
                     Customer.CustomerId,
                     Customer.FirstName as prenom,
                     Customer.LastName as nom,
                     invoice.BillingCountry as country,
                     sum (invoice.Total) as CA_client,
                     extract (YEAR from invoice.InvoiceDate) as annee
from customer join 
Invoice on customer.CustomerId = invoice.CustomerId
group by Customer.CustomerId,
         Customer.LastName,
         Customer.FirstName,
		 invoice.BillingCountry,
 		 extract (YEAR from invoice.InvoiceDate)
                    ),


client_evolution as (select *, lag(CA_client) over (partition by customerid order by annee) as CA_annee_precedente from client_pays
                    ),

evolution_ca as (select *, ((CA_client-CA_annee_precedente)/NULLIF(CA_annee_precedente,0))*100) as evolution_pct
from client_evolution
),
                 
segmentation as (select *,
                 CASE 
                 WHEN evolution_pct is NULL THEN 'premiere_annee'                 
                 WHEN evolution_pct<0 THEN 'Baisse'
                 WHEN evolution_pct=0 THEN 'Stable'
                 ElSE 'Augmentation'
                 END as segmentation
from evolution_ca
                ),

baisse_consecutive as (select *, lag (segmentation) over(partition by customerid order by annee) as evo_annee_prec
                 from segmentation),
                 
                
baisse_consecutive2 as (select *, CASE
                        WHEN segmentation = 'Baisse' and evo_annee_prec = 'Baisse' THEN 'Danger'
                        Else 'à maintenir'
                        end as deux_baisses
                        From baisse_consecutive),
                        
annee_precedente as (select *,
                     MAX(annee) OVER (PARTITION BY customerid) as last_annee
                     from baisse_consecutive2),
                     
ca_total_client as (select *,
                    sum(CA_client) over (partition by country, annee) as ca_total_pays_annee
                    from annee_precedente),
                    
part_pays AS (
    SELECT *,
           (CA_client / ca_total_pays_annee) * 100 AS repartition_pays
    FROM ca_total_client
)

SELECT
    customerid,
    prenom,
    nom,
    country,
    annee,
    CA_client,
    CA_annee_precedente,
    evolution_pct,
    segmentation,
    deux_baisses,
    repartition_pays
FROM part_pays
WHERE annee = last_annee
  AND repartition_pays >= 10
  AND deux_baisses = 'Danger'
ORDER BY repartition_pays DESC;
              
                    
                    

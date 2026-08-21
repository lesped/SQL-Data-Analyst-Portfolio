WITH Ca_clients as (SELECT customer.CustomerId,
Customer.firstname as prenom,
customer.lastname as nom,
Sum(invoice.total) as CA_total,
COUNT (invoice.invoiceid) as Nb_factures
FROM customer join invoice on customer.customerid = invoice.CustomerId
group by customer.CustomerId,
customer.firstname,
customer.lastname),

Rang_clients AS (SELECT *, DENSE_RANK() over (order by CA_total desc) as "rang_client" from Ca_clients)

SELECT * from Rang_clients order by rang_client limit 10 ;


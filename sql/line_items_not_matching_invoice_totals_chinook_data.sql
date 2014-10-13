/* Do we have any invoices where the value in the total field
   doesn't match the sum of the line items?
*/

SET search_path TO chinook;

DROP VIEW IF EXISTS chinook."vInvoice";

SELECT 
	inv."InvoiceId", 
	inv."CustomerId", 
	inv."Total", 
	SUM(line."Quantity" * line."UnitPrice") as "LineItemsTotal"
FROM chinook."Invoice" inv LEFT OUTER JOIN chinook."InvoiceLine" line
ON inv."InvoiceId" = line."InvoiceId"
GROUP BY inv."InvoiceId"
HAVING inv."Total" <> sum(line."Quantity" * line."UnitPrice")
;

/* We do!  How can we fix this?  Via a view! */
CREATE OR REPLACE VIEW chinook."vInvoice" AS (
	SELECT 
		inv."BillingAddress", inv."BillingCity", inv."BillingCountry", 
		inv."BillingPostalCode", inv."BillingState", inv."CustomerId", 
		inv."InvoiceDate", inv."InvoiceId",
		SUM(line."Quantity" * line."UnitPrice") as "Total"
	FROM 
		chinook."Invoice" inv 
		LEFT OUTER JOIN chinook."InvoiceLine" line
		ON inv."InvoiceId" = line."InvoiceId"
	GROUP BY inv."InvoiceId"
	ORDER BY inv."InvoiceDate" DESC
);

/* Double-check: compare view to tables */
SELECT 
	inv."InvoiceId", 
	inv."CustomerId", 
	inv."Total", 
	vinv."Total" as "ViewTotal",
	SUM(line."Quantity" * line."UnitPrice") as "LineItemsTotal"
FROM chinook."Invoice" inv LEFT OUTER JOIN chinook."InvoiceLine" line
ON inv."InvoiceId" = line."InvoiceId"
FULL OUTER JOIN chinook."vInvoice" vinv
ON inv."InvoiceId" = vinv."InvoiceId"
GROUP BY inv."InvoiceId", vinv."Total"
HAVING inv."Total" <> sum(line."Quantity" * line."UnitPrice")
	OR vinv."Total" <> sum(line."Quantity" * line."UnitPrice")
;

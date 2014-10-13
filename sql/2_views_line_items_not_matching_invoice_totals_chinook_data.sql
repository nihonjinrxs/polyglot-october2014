/***************************************
  Polyglot Programming DC : October 2014
  Manipulating Data in Style with SQL
  **************************************
  Author:  Ryan B. Harvey
  Created: 2014-08-02
  **************************************
  This script inspects the Invoice and
  InvoiceLine tables in the Chinook
  database to find problems with stored
  totals not matching InvoiceLine record
  sums, then fixes this issue via a view
  that computes the total for an invoice
  on the fly.
  
  Note that this depends on a bad import
  of Chinook data that doesn't take into
  account character set issues, and thus
  leaves out many records in tables.
  Although we would normally not want 
  this to happen, doing it intentionally
  here provides some interesting real-
  world data integrity problems to 
  inspect, so I've done this on purpose.
****************************************/

/* Setup -- set search path and drop view if exists */
SET search_path TO chinook;
DROP VIEW IF EXISTS chinook."vInvoice";

/* Do we have any invoices where the value in the total field
   doesn't match the sum of the line items?
*/
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


/*

==================================================
    DDL Script: CREATE gold Tables
==================================================

    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

*/

--========================================================================

-- Objects in gold layer are virtual
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key, --surrogate key
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_name,
	ci.cst_firstname AS firstname,
	ci.cst_lastname AS lastname,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE 
		WHEN cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master table. So we prefer those values
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM silver.crm_custinfo AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid;

--========================================================================
-- This is a dimension table
CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pd.prd_start_dt, pd.prd_key) AS product_key, -- AS this is a dimension creating a surrogate key
	pd.prd_id AS product_id,
	pd.prd_key AS product_number,
	pd.prd_nm AS product_name,
	pd.cat_id AS category_id,
	pa.cat AS category,
	pa.subcat AS sub_category,
	pa.maintenance,
	pd.prd_cost AS cost,
	pd.prd_line AS product_line,
	pd.prd_start_dt AS product_start_dt
FROM silver.crm_prdinfo AS pd
LEFT JOIN silver.erp_px_cat_g1v2 AS pa
ON pd.cat_id = pa.id
WHERE pd.prd_end_dt IS NULL; --filters out all historical data 

--========================================================================
CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_num,
	pd.product_key ,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pd
ON sd.sls_prd_key = pd.product_number
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id ;


/*
	Table: bronze.crm_custinfo (Data quality check)
*/

-- Analyse the data.
SELECT * 
FROM bronze.crm_custinfo;

-- Check for nulls or Duplicates in primary key
SELECT 
	cst_id,
	count(*) AS Duplicates
FROM bronze.crm_custinfo
GROUP BY cst_id
Having count(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces for columns with string columns
-- Similarly use same logic to check lastname as well
SELECT
	cst_firstname
FROM bronze.crm_custinfo
WHERE cst_firstname != TRIM(cst_firstname);

-- Data standardization and consistency
-- Checks for all the unique values 
SELECT DISTINCT
	cst_gndr
FROM bronze.crm_custinfo;

SELECT DISTINCT
	cst_marital_status
FROM bronze.crm_custinfo;

/*
	Table: bronze.crm_prdinfo (Data quality check)
*/

--Analyse the data 
SELECT *
FROM bronze.crm_prdinfo;

-- Checks for nulls (No nulls and duplicates)
SELECT 
	prd_id,
	COUNT(*) AS duplicates
FROM bronze.crm_prdinfo
GROUP BY prd_id
HAVING prd_id IS NULL OR COUNT(*) > 1;

-- Checks for unwanted spaces
SELECT
	prd_nm
FROM bronze.crm_prdinfo
WHERE prd_nm != TRIM(prd_nm);

-- check for nulls or negative costs
SELECT
	prd_cost
FROM bronze.crm_prdinfo
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Data standardization and consistency
SELECT DISTINCT
	prd_line	
FROM bronze.crm_prdinfo;	

-- check for invalid order date (end date is smaller than start date)
SELECT *
FROM bronze.crm_prdinfo
WHERE prd_end_dt < prd_start_dt;

/*
	Table: bronze.crm_sales_details (Data quality check)
*/

SELECT *
FROM bronze.crm_sales_details;

-- Unwanted spaces and nulls
SELECT
	sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)
or sls_ord_num IS NULL;

-- check sls_prd_key, sls_cust_id were present in other tables that were related
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prdinfo)
--	WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_custinfo)

-- check for invalid dates.
-- we have dates with value zeroes, so replace them with NULLS
-- length of date must be 8,if len != 8 then the format is incorrect
-- boundaries like year range
-- order date should always be smaller than ship and due date
-- similarly check for all dates
SELECT
	NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101 OR sls_order_dt < 19900101;

-- Data consistency: between Sales, Quantity, and price
-- Sales = Quantity * price
-- Values must not be 0, NULL, or negative.
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_price <=0 OR sls_quantity <=0 OR sls_sales <=0
OR sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

/*
	Table: erp_cust_az12
*/

-- TO connect it with other tables, check the integrattion model
--cid has extra letters NAS in it which is not present in cst_key from crm_custinfo
SELECT *
FROM bronze.erp_cust_az12;

--check birthdate datatype, very early dates and future dates
SELECT DISTINCT
	bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1925-01-01' OR bdate > GETDATE()

--Data standardization
SELECT DISTINCT
	gen
FROM bronze.erp_cust_az12;

/*
	Table: erp_loc_a101
*/
--cid for joinning tables with cust_info table.
SELECT *
FROM bronze.erp_loc_a101;

-- data standardization
SELECT DISTINCT
	cntry
FROM bronze.erp_loc_a101;

/*
	Table: erp_px_cat_g1v2
*/
-- data connection id with prd_key from prd_info
SELECT *
FROM bronze.erp_px_cat_g1v2;

SELECT
	*
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat!=TRIM(Subcat) OR maintenance!=TRIM(maintenance);


SELECT DISTINCT
	cat -- similarly check for subcat, maintenance
FROM bronze.erp_px_cat_g1v2

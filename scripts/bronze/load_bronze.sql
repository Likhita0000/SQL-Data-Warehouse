/*
=============================================
	Stored procedure: Load Bronze Layer
=============================================

This script procedure loads data into the bronze schema from external CSV files.
It does the following tasks:
	-Truncates the bronze tables before loading data.
	-Uses the 'bulk Insert' to load data from CSV files.

Usage example:
	EXEC bronze.load_bronze;
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	--declaring variables helps to understand when we started loading the table and when we ended.
	DECLARE @start_time DATETIME, @end_time DATETIME

	--if an error occurs in this TRY part then CATCH will be executed
	BEGIN TRY

		--PRINT statements helps to identify bottlenecks, optimize performance, monitor trends and detect issues
		PRINT '========================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '========================================';
	
		PRINT'-----------------------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT'-----------------------------------------';
		
		SET @start_time = GETDATE();

		--clear the table before inserting
		PRINT '$TRUNCATING Table: bronze.crm_custinfo';
		TRUNCATE TABLE bronze.crm_custinfo;

		--Data Ingestion
		PRINT '$INSERting Table: bronze.crm_custinfo';
		BULK INSERT bronze.crm_custinfo
		FROM 'C:\Users\kadiy\Downloads\warehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		--calculate the duration
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';

		PRINT '===========================================';
		SET @start_time = GETDATE();
		PRINT '$TRUNCATING Table: bronze.crm_prdinfo';
		TRUNCATE TABLE bronze.crm_prdinfo;

		PRINT '$INSERTING Table: bronze.crm_prdinfo';
		BULK INSERT bronze.crm_prdinfo
		FROM 'C:\Users\kadiy\Downloads\warehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		
		PRINT '===========================================';
		SET @start_time = GETDATE();
		PRINT '$TRUNCATING Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '$INSERTING Table: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\kadiy\Downloads\warehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';

		PRINT'-----------------------------------------';
		PRINT'LOADING ERP TABLES';
		PRINT'-----------------------------------------';

		PRINT '===========================================';
		SET @start_time = GETDATE();
		PRINT '$TRUNCATING Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '$INSERTING Table: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\kadiy\Downloads\warehouse\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';

		PRINT '===========================================';
		SET @start_time = GETDATE();
		PRINT '$TRUNCATING Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '$INSERTING Table: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\kadiy\Downloads\warehouse\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		
		PRINT '===========================================';
		SET @start_time = GETDATE();
		PRINT '$TRUNCATING Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '$INSERTING Table: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\kadiy\Downloads\warehouse\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	END TRY
--CATCH tells what to execute if TRY sql statements fail due to some error
	BEGIN CATCH
		PRINT '===============================================';
		PRINT 'ERROR OCCURED WHILE LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '===============================================';
	END CATCH
END

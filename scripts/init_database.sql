/*
====================================================
CREATE DATABASE AND SCHEMAS
====================================================

This script creates a new database named 'DataWarehouse' after checking if it already exists.
Also this script sets up three schemas within the database: bronze, silver, gold.

*/

USE master;
GO
  
--DROP and RECREATE the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

--CREATE 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO

--CREATE SCHEMAS: bronze, silver, gold
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

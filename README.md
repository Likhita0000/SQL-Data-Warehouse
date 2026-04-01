# SQL Data Warehouse Project

## Overview
A modern data warehouse built in SQL Server using Medallion architecture
to consolidate two source systems into a single trusted analytical layer.
The project covers end-to-end data engineering — from raw data ingestion
to a business-ready star schema model ready for reporting and analytics.

## Architecture
This project follows the Medallion architecture with three layers.

Bronze Layer — Raw data landing zone. Data is loaded exactly as-is from
two CSV source systems using bulk insert stored procedures. No transformations
are applied. This layer exists purely for traceability and debugging.

Silver Layer — Transformation layer. All data quality issues are identified
and resolved here. Clean standardized data is prepared for the final layer.

Gold Layer — Business layer. A star schema is built using views for direct
consumption by reporting tools and analysts.

## Data Sources
Two flat CSV source systems were used to simulate real-world disconnected
business systems.

Source 1 — CRM data containing customer information across three tables.
Source 2 — ERP data containing product, category, and sales information
across three tables.

Total — six source tables consolidated into one analytical model.

## Data Quality Issues Resolved in Silver Layer
- Duplicate customer records removed using ROW_NUMBER() window function
  partitioned by customer ID ordered by create date
- Coded abbreviations like M and F standardized to Male and Female
  using CASE WHEN with UPPER and TRIM
- Integer date columns converted to proper DATE type after handling
  zeros and invalid values
- Null and negative sales amounts recalculated from quantity times price
  using ABS function
- Broken product start and end dates reconstructed using LEAD window
  function to eliminate overlapping date ranges
- Mismatched customer IDs between CRM and ERP resolved by stripping
  invalid prefixes using SUBSTRING
- Null country and gender values replaced with Not Available default label

## Data Model — Gold Layer Star Schema
The Gold layer implements a star schema with the following objects.

dim_customers — Dimension table integrating customer data from both CRM
and ERP sources with demographics and geography.

dim_products — Dimension table with current product information joined
with category data from ERP.

fact_sales — Fact table containing sales transactions connected to both
dimensions via surrogate keys.

All Gold objects are SQL views ensuring always-fresh data with no
separate load process required.

## ETL Pipeline
- Stored procedures built for Bronze and Silver layer loads
- TRY-CATCH error handling captures error message, number, and state
- Per-table load duration logged using GETDATE and DATEDIFF
- Truncate and insert pattern used for full load refresh
- Row count validation checks after each load

## Repository Structure
datasets — source CSV files for CRM and ERP systems
scripts — SQL scripts organized by layer
  scripts/bronze — DDL and stored procedure for Bronze load
  scripts/silver — DDL and stored procedure for Silver load
  scripts/gold — DDL views for Gold layer
tests — data quality check scripts for Silver and Gold layers
docs — architecture diagrams and data flow documentation

## Key Results
- 29 million in total revenue consolidated into one source
- 18,000 customers across 6 countries
- 295 products across 4 categories
- Full data lineage from source CSV to Gold reporting layer

## Tools Used
- SQL Server Express
- SQL Server Management Studio
- Draw.io for architecture and data flow diagrams
- GitHub for version control

## How to Run
1. Execute scripts/init_database.sql to create the database and schemas
2. Execute scripts/bronze/ddl_bronze.sql to create Bronze tables
3. Execute scripts/bronze/proc_load_bronze.sql to create Bronze procedure
4. Run EXEC bronze.load_bronze to load Bronze layer
5. Execute scripts/silver/ddl_silver.sql to create Silver tables
6. Execute scripts/silver/proc_load_silver.sql to create Silver procedure
7. Run EXEC silver.load_silver to load Silver layer
8. Execute scripts/gold/ddl_gold.sql to create Gold views
9. Run quality checks from tests folder to validate each layer

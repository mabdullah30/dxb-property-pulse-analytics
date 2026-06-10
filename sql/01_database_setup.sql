/* =============================================================================
DXB PROPERTY PULSE: 01_database_setup.sql
Description: Database creation, raw staging, and core fact table initialization.
=============================================================================
*/

-- Create the main database
CREATE DATABASE dubai_realestate;

-- Create an unlogged staging table to hold the raw CSV data for faster loading
CREATE UNLOGGED TABLE staging_raw (
    transaction_id TEXT, procedure_id TEXT, trans_group_id TEXT, trans_group_ar TEXT,
    trans_group_en TEXT, procedure_name_ar TEXT, procedure_name_en TEXT, instance_date TEXT,
    property_type_id TEXT, property_type_ar TEXT, property_type_en TEXT, property_sub_type_id TEXT,
    property_sub_type_ar TEXT, property_sub_type_en TEXT, property_usage_ar TEXT, property_usage_en TEXT,
    reg_type_id TEXT, reg_type_ar TEXT, reg_type_en TEXT, area_id TEXT, area_name_ar TEXT,
    area_name_en TEXT, building_name_ar TEXT, building_name_en TEXT, project_number TEXT,
    project_name_ar TEXT, project_name_en TEXT, master_project_en TEXT, master_project_ar TEXT,
    nearest_landmark_ar TEXT, nearest_landmark_en TEXT, nearest_metro_ar TEXT, nearest_metro_en TEXT,
    nearest_mall_ar TEXT, nearest_mall_en TEXT, rooms_ar TEXT, rooms_en TEXT, has_parking TEXT,
    procedure_area TEXT, actual_worth TEXT, meter_sale_price TEXT, rent_value TEXT,
    meter_rent_price TEXT, no_of_parties_role_1 TEXT, no_of_parties_role_2 TEXT, no_of_parties_role_3 TEXT
);

-- Note: Import the CSV file into staging_raw table 

-- Create the structured fact table with appropriate data types
CREATE TABLE fact_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    transaction_date DATE,
    transaction_group VARCHAR(50),
    procedure_type VARCHAR(100),
    property_type VARCHAR(50),
    property_subtype VARCHAR(80),
    property_usage VARCHAR(50),
    market_type VARCHAR(50),
    area_name VARCHAR(100),
    building_name VARCHAR(200),
    project_name VARCHAR(200),
    master_project VARCHAR(200),
    nearest_landmark VARCHAR(200),
    nearest_metro VARCHAR(100),
    nearest_mall VARCHAR(100),
    bedrooms VARCHAR(20),
    has_parking VARCHAR(5),
    size_sqm DECIMAL(12,2),
    value_aed DECIMAL(15,2),
    price_per_sqm DECIMAL(12,2),
    annual_rent_aed DECIMAL(12,2),
    rent_per_sqm DECIMAL(12,2)
);

-- Insert data from staging to fact table, stripping string 'nulls' and formatting dates
INSERT INTO fact_transactions (
    transaction_id, transaction_date, transaction_group, procedure_type,
    property_type, property_subtype, property_usage, market_type, area_name,
    building_name, project_name, master_project, nearest_landmark, nearest_metro,
    nearest_mall, bedrooms, has_parking, size_sqm, value_aed, price_per_sqm,
    annual_rent_aed, rent_per_sqm
)
SELECT
    transaction_id,
    TO_DATE(NULLIF(instance_date, ''), 'DD-MM-YYYY'),
    trans_group_en,
    procedure_name_en,
    property_type_en,
    property_sub_type_en,
    property_usage_en,
    reg_type_en,
    area_name_en,
    building_name_en,
    project_name_en,
    master_project_en,
    nearest_landmark_en,
    nearest_metro_en,
    nearest_mall_en,
    rooms_en,
    has_parking,
    NULLIF(NULLIF(LOWER(procedure_area), 'null'), '')::DECIMAL(12,2),
    NULLIF(NULLIF(LOWER(actual_worth), 'null'), '')::DECIMAL(15,2),
    NULLIF(NULLIF(LOWER(meter_sale_price), 'null'), '')::DECIMAL(12,2),
    NULLIF(NULLIF(LOWER(rent_value), 'null'), '')::DECIMAL(12,2),
    NULLIF(NULLIF(LOWER(meter_rent_price), 'null'), '')::DECIMAL(12,2)
FROM staging_raw;
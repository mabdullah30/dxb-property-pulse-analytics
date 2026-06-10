/* =============================================================================
DXB PROPERTY PULSE: 02_data_transformation.sql
Description: Feature engineering, temporal extraction, and segment bucketing.
=============================================================================
*/

-- Add derived columns for analysis
ALTER TABLE fact_transactions
    ADD COLUMN transaction_year INTEGER,
    ADD COLUMN transaction_month INTEGER,
    ADD COLUMN transaction_quarter INTEGER,
    ADD COLUMN size_sqft DECIMAL(12,2),
    ADD COLUMN price_per_sqft DECIMAL(12,2),
    ADD COLUMN value_usd DECIMAL(15,2),
    ADD COLUMN price_segment VARCHAR(30);

-- Populate derived columns with extracted dates, unit conversions, and segmentation
UPDATE fact_transactions SET
    transaction_year = EXTRACT(year FROM transaction_date),
    transaction_month = EXTRACT(month FROM transaction_date),
    transaction_quarter = EXTRACT(quarter FROM transaction_date),
    size_sqft = ROUND(size_sqm * 10.764, 2),
    price_per_sqft = ROUND(price_per_sqm / 10.764, 2),
    value_usd = ROUND(value_aed / 3.67, 2),
    price_segment = CASE
        WHEN value_aed >= 10000000 THEN 'Ultra Luxury (10M+)'
        WHEN value_aed >= 3000000  THEN 'Luxury (3M-10M)'
        WHEN value_aed >= 1000000  THEN 'Mid Market (1M-3M)'
        WHEN value_aed >= 500000   THEN 'Affordable (500K-1M)'
        ELSE 'Entry Level (<500K)' 
    END;
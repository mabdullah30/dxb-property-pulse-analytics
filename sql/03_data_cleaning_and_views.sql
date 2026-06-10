/* =============================================================================
DXB PROPERTY PULSE: 03_data_cleaning_and_views.sql
Description: Smart imputation for missing values and creation of the final view.
=============================================================================
*/

-- Fill empty property subtypes with the parent property type
UPDATE fact_transactions
SET property_subtype = property_type
WHERE property_subtype = '' OR property_subtype IS NULL;

-- Smart Imputation: Fill blank dimensions intelligently based on property logic 
UPDATE fact_transactions
SET
    building_name = CASE
        WHEN property_type = 'Land' THEN 'Not Applicable (Land)'
        ELSE COALESCE(NULLIF(building_name, ''), 'Unspecified Building')
    END,
    project_name = COALESCE(NULLIF(project_name, ''), 'Independent/No Project'),
    bedrooms = CASE
        WHEN property_type = 'Land' THEN 'Plot (N/A)'
        ELSE COALESCE(NULLIF(bedrooms, ''), 'Unspecified/Studio/Commercial')
    END,
    nearest_landmark = COALESCE(NULLIF(nearest_landmark, ''), 'No Major Landmark'),
    nearest_metro = COALESCE(NULLIF(nearest_metro, ''), 'No Metro Nearby'),
    nearest_mall = COALESCE(NULLIF(nearest_mall, ''), 'No Mall Nearby')
WHERE
    NULLIF(building_name, '') IS NULL
    OR NULLIF(project_name, '') IS NULL
    OR NULLIF(bedrooms, '') IS NULL
    OR NULLIF(nearest_landmark, '') IS NULL
    OR NULLIF(nearest_metro, '') IS NULL
    OR NULLIF(nearest_mall, '') IS NULL
    OR property_type = 'Land';

-- Clean Master Project columns to align with independent projects
UPDATE fact_transactions
SET master_project = COALESCE(NULLIF(master_project, ''), 'Independent/No Master Project')
WHERE NULLIF(master_project, '') IS NULL
AND project_name = 'Independent/No Project';

-- Cascade project names into remaining blank Master Project records
UPDATE fact_transactions
SET master_project = project_name
WHERE NULLIF(master_project, '') IS NULL;

-- Create the finalized view for Tableau connecting, isolating valid sales
CREATE VIEW clean_sales AS
SELECT *
FROM fact_transactions
WHERE transaction_group = 'Sales'
    AND value_aed > 50000
    AND value_aed < 500000000
    AND size_sqm > 10
    AND price_per_sqm > 0
    AND area_name IS NOT NULL;
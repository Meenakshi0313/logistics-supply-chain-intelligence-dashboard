/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the Logistic Operations. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- 1. Fact Table: v_FactTripLoads 
-- =============================================================================
IF OBJECT_ID('v_FactTripLoads', 'V') IS NOT NULL DROP VIEW v_FactTripLoads;
GO

CREATE VIEW v_FactTripLoads AS
SELECT  
    t.trip_id, t.dispatch_date, t.driver_id, t.truck_id, t.trailer_id,
    l.load_id, l.customer_id, 
    l.route_id, l.load_type,
    de.facility_id, 
    l.weight_lbs, l.pieces, l.accessorial_charges,
    t.trip_status, t.actual_distance_miles, t.actual_duration_hours, 
    t.fuel_gallons_used, t.average_mpg, t.idle_time_hours,
    c.primary_freight_type, 
    ISNULL(l.revenue, 0) AS base_revenue,
    ISNULL(l.fuel_surcharge, 0) AS fuel_surcharge,
    (ISNULL(l.revenue, 0) + ISNULL(l.fuel_surcharge, 0)) AS total_revenue,
    ISNULL(f.total_fuel_cost, 0) AS fuel_cost,
    ((ISNULL(l.revenue, 0) + ISNULL(l.fuel_surcharge, 0)) - ISNULL(f.total_fuel_cost, 0)) AS net_profit,
    CASE 
        WHEN (ISNULL(l.revenue, 0) + ISNULL(l.fuel_surcharge, 0)) = 0 THEN 0 
        ELSE ((ISNULL(l.revenue, 0) + ISNULL(l.fuel_surcharge, 0)) - ISNULL(f.total_fuel_cost, 0)) / (ISNULL(l.revenue, 0) + ISNULL(l.fuel_surcharge, 0))
    END AS profit_margin_pct,
    -- CORRECTION: Ensures safety flag is 0 or 1 even if multiple incidents exist
    ISNULL(saf.is_safety_incident, 0) AS is_safety_incident
FROM silver.trips t
LEFT JOIN silver.loads l ON t.load_id = l.load_id
-- CORRECTION: Added DISTINCT to prevent row duplication if a load has multiple delivery events
LEFT JOIN (SELECT DISTINCT load_id, facility_id FROM silver.delivery_events) de ON l.load_id = de.load_id 
LEFT JOIN silver.customers c ON l.customer_id = c.customer_id 
LEFT JOIN (
    SELECT trip_id, SUM(total_cost) AS total_fuel_cost 
    FROM silver.fuel_purchases GROUP BY trip_id
) f ON t.trip_id = f.trip_id
LEFT JOIN (
    SELECT trip_id, MAX(is_safety_incident) as is_safety_incident
    FROM v_FactIncidentMaintenance
    GROUP BY trip_id
) saf ON t.trip_id = saf.trip_id
WHERE t.driver_id <> 'Unknown_Driver';
GO

-- =============================================================================
-- 2. Fact Table: v_FactSupplyChainEvents (Now joining Route via Load)
-- =============================================================================
IF OBJECT_ID('v_FactSupplyChainEvents', 'V') IS NOT NULL DROP VIEW v_FactSupplyChainEvents;
GO
CREATE VIEW v_FactSupplyChainEvents AS
SELECT 
    de.event_id, de.load_id, de.trip_id, de.facility_id, de.event_type,
    t.driver_id, t.truck_id,t.trailer_id,
    CAST(t.dispatch_date AS DATE) AS event_date,
    de.detention_minutes,
    CAST(de.detention_minutes AS DECIMAL(10,2)) / 60.0 AS dwell_hours,
    de.on_time_flag,
    de.location_city + ', ' + de.location_state AS event_location,
    r.origin_city + ' to ' + r.destination_city AS route_lane,
    r.typical_distance_miles, r.base_rate_per_mile
FROM silver.delivery_events de
LEFT JOIN silver.trips t ON de.trip_id = t.trip_id
LEFT JOIN silver.loads l ON de.load_id = l.load_id -- Use Load to find the Route
LEFT JOIN silver.routes r ON l.route_id = r.route_id; -- Join Route via the Load's RouteID
GO

-- =============================================================================
-- 3. Fact Table: v_FactIncidentMaintenance 
-- =============================================================================
IF OBJECT_ID('v_FactIncidentMaintenance', 'V') IS NOT NULL DROP VIEW v_FactIncidentMaintenance;
GO

CREATE VIEW v_FactIncidentMaintenance AS
SELECT 
    COALESCE(s.truck_id, m.truck_id) AS truck_id,
    COALESCE(s.driver_id, 'Maintenance-Only') AS driver_id,
    COALESCE(s.incident_date, m.maintenance_date) AS event_date,
    s.trip_id,
    tr.make, 
    tr.model_year,
    COALESCE(s.incident_id, 'N/A') AS incident_id,
    COALESCE(s.incident_type, 'Routine') AS incident_type,
    COALESCE(s.claim_amount, 0) AS claim_amount,
    COALESCE(s.description, 'No incident recorded') AS incident_description,
    COALESCE(m.maintenance_id, 'N/A') AS maintenance_id,
    COALESCE(m.maintenance_type, 'N/A') AS maintenance_type,
    COALESCE(m.total_cost, 0) AS repair_total_cost,
    COALESCE(m.downtime_hours, 0) AS downtime_hours,
    COALESCE(m.service_description, 'No service recorded') AS service_description,
    CASE 
        WHEN s.incident_id IS NOT NULL THEN 'Safety Incident' 
        ELSE 'Routine Maintenance' 
    END AS event_category,
    CASE 
        WHEN s.incident_id IS NOT NULL THEN 1 
        ELSE 0 
    END AS is_safety_incident,
    (COALESCE(s.claim_amount, 0) + COALESCE(m.total_cost, 0)) AS total_event_cost

FROM silver.safety_incidents s
FULL JOIN silver.maintenance_records m 
    ON s.truck_id = m.truck_id 
    AND s.incident_date = m.maintenance_date
LEFT JOIN silver.trucks tr 
    ON COALESCE(s.truck_id, m.truck_id) = tr.truck_id;
GO

-- =============================================================================
-- 4. Fact Table: v_FactMonthlyMetrics 
-- =============================================================================
IF OBJECT_ID('v_FactMonthlyMetrics', 'V') IS NOT NULL DROP VIEW v_FactMonthlyMetrics;
GO
CREATE VIEW v_FactMonthlyMetrics AS
SELECT 
    tu.truck_id, tu.month_start_date, tu.trips_completed, tu.total_miles,
    tu.total_revenue, tu.average_mpg, tu.maintenance_events,
    tu.maintenance_cost, tu.downtime_hours,
    tr.make AS truck_make,
    CASE 
        WHEN tu.utilization_rate > 1 THEN 1.0 
        WHEN tu.utilization_rate < 0 THEN 0.0 
        ELSE tu.utilization_rate 
    END AS utilization_rate_clean,
    dmm.driver_id,
    dmm.on_time_delivery_rate, dmm.average_idle_hours
FROM silver.truck_utilization_metrics tu
LEFT JOIN silver.trucks tr ON tu.truck_id = tr.truck_id
-- CORRECTION: Joined on both date and truck_id/driver_id if available to prevent Cartesian products
LEFT JOIN silver.driver_monthly_metrics dmm ON tu.month_start_date = dmm.month_start_date; 
GO

-- =============================================================================
-- 5. Dimension: v_DimDate
-- =============================================================================
IF OBJECT_ID('v_DimDate', 'V') IS NOT NULL DROP VIEW v_DimDate;
GO
CREATE VIEW v_DimDate AS
SELECT DISTINCT
    month_start_date AS full_date,
    YEAR(month_start_date) AS year,
    DATENAME(MONTH, month_start_date) AS month_name,
    LEFT(DATENAME(MONTH, month_start_date), 3) AS month_short,
    MONTH(month_start_date) AS month_number,
    LEFT(DATENAME(MONTH, month_start_date), 3) + ' ' + CAST(YEAR(month_start_date) AS VARCHAR) AS month_year_label
FROM silver.truck_utilization_metrics;
GO

-- =============================================================================
-- 6. Dimension: v_DimCustomers
-- =============================================================================

IF OBJECT_ID('v_DimCustomers', 'V') IS NOT NULL DROP VIEW v_DimCustomers;
GO

CREATE VIEW v_DimCustomers AS 
 SELECT customer_id,
    customer_name,
    customer_type,
    credit_term_days,
    primary_freight_type,
    account_status,
    contract_start_date,
    annual_revenue_potential 
   FROM silver.customers;
GO

-- =============================================================================
-- 7. Dimension: v_DimTrucks
-- =============================================================================

IF OBJECT_ID('v_DimTrucks', 'V') IS NOT NULL
DROP VIEW v_DimTrucks;
GO

CREATE VIEW v_DimTrucks AS 
    SELECT 
        truck_id,
        unit_number,
        make,
        COALESCE(CAST(model_year AS VARCHAR), 'Unknown') AS model_year,
        fuel_type
    FROM silver.trucks;
GO



-- =============================================================================
-- 8. Dimension: v_DimFacilities 
-- =============================================================================
IF OBJECT_ID('v_DimFacilities', 'V') IS NOT NULL DROP VIEW v_DimFacilities;
GO
CREATE VIEW v_DimFacilities AS
SELECT 
    facility_id,
    facility_name,
    facility_type,
    city,
    state,
    dock_doors,
    operating_hours,
    -- Geographic Tagging for Maps
    city + ', ' + state AS facility_location
FROM silver.facilities;
GO

-- =============================================================================
-- 9. Dimension: v_DimTrailers 
-- =============================================================================
IF OBJECT_ID('v_DimTrailers', 'V') IS NOT NULL DROP VIEW v_DimTrailers;
GO
CREATE VIEW v_DimTrailers AS
SELECT 
    trailer_id,
    trailer_number,
    trailer_type,
    length_feet,
    model_year,
    status AS trailer_status,
    current_location
FROM silver.trailers;
GO

-- =============================================================================
-- 10. Dimension: v_DimRoutes 
-- =============================================================================
IF OBJECT_ID('v_DimRoutes', 'V') IS NOT NULL DROP VIEW v_DimRoutes;
GO
CREATE VIEW v_DimRoutes AS
SELECT 
    route_id,
    origin_city,
    origin_state,
    destination_city,
    destination_state,
    -- Pre-calculating the Lane for your "Top High-Margin Routes" chart
    origin_city + ' to ' + destination_city AS route_lane,
    typical_distance_miles,
    base_rate_per_mile,
    typical_transit_days
FROM silver.routes;
GO


-- =============================================================================
-- 11. Dimension: v_DimDrivers 
-- =============================================================================
IF OBJECT_ID('v_DimDrivers', 'V') IS NOT NULL DROP VIEW v_DimDrivers;
GO
CREATE VIEW v_DimDrivers AS
SELECT 
    driver_id,
    TRIM(first_name) + ' ' + TRIM(last_name) AS driver_full_name,
    hire_date,
    employment_status,
    years_experience,
    CASE 
        WHEN years_experience <= 1 THEN 'Rookie (0-1yr)'
        WHEN years_experience <= 5 THEN 'Mid-Level (2-5yrs)'
        WHEN years_experience <= 10 THEN 'Senior (6-10yrs)'
        ELSE 'Veteran (10yrs+)' 
    END AS experience_tier
FROM silver.drivers; 
GO


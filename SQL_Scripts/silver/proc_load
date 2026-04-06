/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';


		-- Loading customers
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.customers';
		TRUNCATE TABLE silver.customers;
		PRINT '>> Inserting Data Into: silver.customers';
		INSERT INTO silver.customers (
			customer_id              ,
			customer_name            ,
			customer_type           ,
			credit_term_days ,             
			primary_freight_type,
			account_status ,
			contract_start_date , 
			annual_revenue_potential
		    )

			SELECT 
			TRIM(customer_id),
			TRIM(customer_name),
			UPPER(LEFT(TRIM(customer_type), 1)) + LOWER(SUBSTRING(TRIM(customer_type), 2, LEN(customer_type))) AS event_type,
			ISNULL(credit_term_days, 30), -- Default to 30 if missing
			UPPER(LEFT(TRIM(primary_freight_type), 1)) + LOWER(SUBSTRING(TRIM(primary_freight_type), 2, LEN(primary_freight_type))) AS event_type,
			UPPER(LEFT(TRIM(account_status), 1)) + LOWER(SUBSTRING(TRIM(account_status), 2, LEN(account_status))) AS event_type,
			TRY_CAST(contract_start_date AS DATE) ,
			CAST(annual_revenue_potential AS DECIMAL(18,2))
		FROM bronze.customers;
			
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading delivery_events
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.delivery_events';
		TRUNCATE TABLE silver.delivery_events;
		PRINT '>> Inserting Data Into: silver.delivery_events';
		INSERT INTO silver.delivery_events (
			event_id ,
			load_id ,
			trip_id,
			event_type ,
			facility_id,
			scheduled_datetime, 
			actual_datetime , 
			detention_minutes,
			on_time_flag,            
			location_city,
			location_state
		)
		SELECT 
			TRIM(event_id),
			TRIM(load_id),
			TRIM(trip_id),
			UPPER(LEFT(TRIM(event_type), 1)) + LOWER(SUBSTRING(TRIM(event_type), 2, LEN(event_type))) AS event_type,
			TRIM(facility_id),
			TRY_CONVERT( TIME, schedule_datetime) AS scheduled_datetime,
            TRY_CONVERT(TIME, actual_datetime) AS actual_datetime,
            ISNULL(CAST(detention_minutes AS INT), 0) AS detention_minutes,
			CASE 
				WHEN UPPER(TRIM(on_time_flag)) = 'TRUE' THEN 1 
				WHEN UPPER(TRIM(on_time_flag)) = 'FALSE' THEN 0 
				ELSE NULL 
			END AS on_time_flag,
			TRIM(location_city),
			UPPER(TRIM(location_state))
		FROM bronze.delivery_events;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading driver_monthly_metrics
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.driver_monthly_metrics';
		TRUNCATE TABLE silver.driver_monthly_metrics;
		PRINT '>> Inserting Data Into: silver.driver_monthly_metrics';
		INSERT INTO silver.driver_monthly_metrics (
			driver_id ,
			month_start_date ,
			month_name,
			trips_completed,
			total_miles,
			total_revenue,
			average_mpg,
			total_fuel_gallons,
			on_time_delivery_rate,
			average_idle_hours  
		)
		SELECT 
				TRIM(driver_id) AS driver_id,
                CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, TRY_CAST([month] AS DATE)), 0) AS DATE) AS month_start_date,
				DATENAME(MONTH, TRY_CAST([month] AS DATE)) AS month_name,
				CAST(trips_completed AS INT) AS trips_completed,
				CAST(total_miles AS DECIMAL(10,2)) AS total_miles,
				CAST(total_revenue AS DECIMAL(18,2)) AS total_revenue,
				CAST(average_mpg AS DECIMAL(5,2)) AS average_mpg,
				CAST(total_fuel_gallons AS DECIMAL(10,2)) AS total_fuel_gallons,
				CAST(on_time_delivery_rate AS DECIMAL(5,2)) AS on_time_delivery_rate,
				CAST(average_idle_hours AS DECIMAL(5,2)) AS average_idle_hours
		FROM (
				SELECT *, ROW_NUMBER() OVER (
					PARTITION BY driver_id, DATEADD(MONTH, DATEDIFF(MONTH, 0, TRY_CAST([month] AS DATE)), 0) 
					ORDER BY (SELECT NULL)
				) as rn
		FROM bronze.driver_monthly_metrics
			) t
	    WHERE rn = 1 AND driver_id IS NOT NULL;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading drivers
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.drivers';
		TRUNCATE TABLE silver.drivers;
		PRINT '>> Inserting Data Into: silver.drivers';
		INSERT INTO silver.drivers(
			 driver_id ,
				first_name,
				last_name,
				hire_date,
				termination_date,
				license_number ,
				license_state,
				date_of_birth,
				home_terminal ,
				employment_status,
				cdl_class ,
				years_experience 
					)
		SELECT 
			TRIM(driver_id),
			TRIM(first_name),
			TRIM(last_name),
			TRY_CAST(hire_date AS DATE),
			TRY_CAST(termination_date AS DATE),
			TRIM(license_number),
			UPPER(TRIM(license_state)),
			TRY_CAST(date_of_birth AS DATE),
			TRIM(home_terminal),
			TRIM(employment_status),
			UPPER(TRIM(cdl_class)),
			CAST(years_experience AS TINYINT)
		FROM (
			SELECT *, ROW_NUMBER() OVER (
				PARTITION BY driver_id 
				ORDER BY hire_date DESC 
			) as rn
			FROM bronze.drivers
		) t
		WHERE rn = 1 AND driver_id IS NOT NULL;
	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -- Loading facilities
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.facilities';
		TRUNCATE TABLE silver.facilities;
		PRINT '>> Inserting Data Into: silver.facilities';
		INSERT INTO silver.facilities (
			facility_id ,
			facility_name,
			facility_type ,
			city ,
			state ,
			latitude,
			longitude,
			dock_doors ,
			operating_hours
		)
		SELECT 
			TRIM(facility_id),
			TRIM(facility_name),
			UPPER(LEFT(TRIM(facility_type), 1)) + LOWER(SUBSTRING(TRIM(facility_type), 2, LEN(facility_type))) AS facility_type,
			TRIM(city) AS city,
			UPPER(TRIM(state)) AS state,
			latitude,
			longitude,
			ISNULL(dock_doors, 0),
			TRIM(operating_hours)
		FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY facility_id ORDER BY (SELECT NULL)) as rn
			FROM bronze.facilities
		) t
		WHERE rn = 1 AND facility_id IS NOT NULL;
	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
		
		-- Loading fuel_purchases
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.fuel_purchases';
		TRUNCATE TABLE silver.fuel_purchases;
		PRINT '>> Inserting Data Into: silver.fuel_purchases';
		INSERT INTO silver.fuel_purchases (
			fuel_purchase_id ,
			trip_id ,
			truck_id,
			driver_id ,
			purchase_date , 
			location_city,
			location_state,
			gallons ,
			price_per_gallon, 
			total_cost ,
			fuel_card_number
		)
		SELECT 
			TRIM(fuel_purchase_id),
			TRIM(trip_id),
			ISNULL(NULLIF(TRIM(truck_id), ''), 'Unknown_Truck') AS truck_id,
			ISNULL(NULLIF(TRIM(driver_id), ''), 'Unknown_Driver') AS driver_id,
            TRY_CAST(purchase_date AS DATETIME),
			TRIM(location_city),
			UPPER(TRIM(location_state)),
			CAST(gallons AS DECIMAL(10, 2)),
			CAST(price_per_gallon AS DECIMAL(10, 4)),
			CAST(total_cost AS DECIMAL(18, 2)),
			TRIM(fuel_card_number)
		FROM bronze.fuel_purchases
		WHERE fuel_purchase_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading loads
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.loads';
		TRUNCATE TABLE silver.loads;
		PRINT '>> Inserting Data Into: silver.loads';
		INSERT INTO silver.loads (
			load_id ,
			customer_id ,
			route_id ,
			load_date,           
			load_type ,
			weight_lbs , 
			pieces,
			revenue ,
			fuel_surcharge,
			accessorial_charges,
			load_status ,
			booking_type
		)
		SELECT 
			TRIM(load_id),
			TRIM(customer_id),
			TRIM(route_id),
			TRY_CAST(load_date AS DATE),
			TRIM(load_type),
			CAST(weight_lbs AS DECIMAL(10, 2)),
			CAST(pieces AS INT),
			CAST(revenue AS DECIMAL(18, 2)),
			CAST(fuel_surcharge AS DECIMAL(18, 2)),
			CAST(accessorial_charges AS DECIMAL(18, 2)),
			TRIM(load_status),
			TRIM(booking_type)
		FROM (
			SELECT *, ROW_NUMBER() OVER (
				PARTITION BY load_id 
				ORDER BY (SELECT NULL)
			) as rn
			FROM bronze.loads
		) t
		WHERE rn = 1 AND load_id IS NOT NULL;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading maintenance_records
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.maintenance_records';
		TRUNCATE TABLE silver.maintenance_records;
		PRINT '>> Inserting Data Into: silver.maintenance_records';
		INSERT INTO silver.maintenance_records (
			maintenance_id ,
			truck_id ,
			maintenance_date,
			maintenance_type,
			odometer_reading,               
			labor_hours,
			labor_cost ,
			parts_cost,
			total_cost ,
			facility_location ,
			downtime_hours ,
			service_description 
		)
		SELECT 
			TRIM(maintenance_id),
			TRIM(truck_id),
			TRY_CAST(maintenance_date AS DATE),
			TRIM(maintenance_type),
			CAST(odometer_reading AS INT),
			CAST(labor_hours AS DECIMAL(10, 2)),
			CAST(labor_cost AS DECIMAL(18, 2)),
			CAST(parts_cost AS DECIMAL(18, 2)),
			CAST(total_cost AS DECIMAL(18, 2)),
			TRIM(facility_location),
			CAST(downtime_hours AS DECIMAL(10, 2)),
			TRIM(service_description)
		FROM (
			SELECT *, ROW_NUMBER() OVER (
				PARTITION BY maintenance_id 
				ORDER BY (SELECT NULL)
			) as rn
			FROM bronze.maintenance_records
		) t
		WHERE rn = 1 AND maintenance_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading routes
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.routes';
		TRUNCATE TABLE silver.routes;
		PRINT '>> Inserting Data Into: silver.routes';
		INSERT INTO silver.routes (
			route_id ,
			origin_city ,
			origin_state ,
			destination_city,
			destination_state ,
			typical_distance_miles,
			base_rate_per_mile ,
			fuel_surcharge_rate , 
			typical_transit_days
		)
		SELECT 
			TRIM(route_id),
			TRIM(origin_city),
			UPPER(TRIM(origin_state)) AS origin_state,
			TRIM(destination_city),
			UPPER(TRIM(destination_state)) AS destination_state,
			CAST(typical_distance_miles AS DECIMAL(10, 2)),
			CAST(base_rate_per_mile AS DECIMAL(10, 2)),
			CAST(fuel_surcharge_rate AS DECIMAL(10, 4)),
			CAST(typical_transit_days AS INT)
		FROM (
			SELECT *, ROW_NUMBER() OVER (
				PARTITION BY route_id 
				ORDER BY (SELECT NULL)
			) as rn
			FROM bronze.routes
		) t
		WHERE rn = 1 AND route_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading safety_incidents
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.safety_incidents';
		TRUNCATE TABLE silver.safety_incidents;
		PRINT '>> Inserting Data Into: silver.safety_incidents';
		INSERT INTO silver.safety_incidents (
			incident_id  ,
			trip_id   ,
			truck_id  ,
			driver_id ,
			incident_date,
			incident_type ,
			location_city ,
			location_state ,
			at_fault_flag, 
			injury_flag,
			vehicle_damage_cost ,
			cargo_damage_cost,
			claim_amount,
			preventable_flag,
			description          
		)
		SELECT 
			TRIM(incident_id),
			TRIM(trip_id),
			ISNULL(NULLIF(TRIM(truck_id), ''), 'Unknown_Truck') AS truck_id,
			ISNULL(NULLIF(TRIM(driver_id), ''), 'Unknown_Driver') AS driver_id,
			TRY_CAST(incident_date AS DATE),
			TRIM(incident_type),
			TRIM(location_city),
			UPPER(TRIM(location_state)),
			CASE WHEN TRIM(at_fault_flag) = 'Y' THEN 1 ELSE 0 END,
			CASE WHEN TRIM(injury_flag) = 'Y' THEN 1 ELSE 0 END,
			CAST(vehicle_damage_cost AS DECIMAL(18, 2)),
			CAST(cargo_damage_cost AS DECIMAL(18, 2)),
			CAST(claim_amount AS DECIMAL(18, 2)),
			CASE WHEN TRIM(preventable_flag) = 'Y' THEN 1 ELSE 0 END,
			TRIM(description)
		FROM (
			SELECT *, ROW_NUMBER() OVER (
				PARTITION BY incident_id 
				ORDER BY (SELECT NULL)
			) as rn
			FROM bronze.safety_incidents
		) t
		WHERE rn = 1 AND incident_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading trailers
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.trailers';
		TRUNCATE TABLE silver.trailers;
		PRINT '>> Inserting Data Into: silver.trailers';
		INSERT INTO silver.trailers (
			trailer_id ,
			trailer_number ,
			trailer_type,
			length_feet,
			model_year,
			vin ,
			acquisition_date ,
			status ,
			current_location 
		)
			SELECT 
			TRIM(trailer_id),
			TRIM(trailer_number),
			TRIM(trailer_type), 
			CAST(length_feet AS INT),
			CAST(model_year AS INT),
			UPPER(TRIM(vin)) AS vin,
			-- Convert string to DATE
			TRY_CAST(acquisition_date AS DATE),
			TRIM(status) AS status,
			TRIM(current_location)
		FROM (		
			SELECT *, ROW_NUMBER() OVER (
				PARTITION BY trailer_id 
				ORDER BY (SELECT NULL)
			) as rn
			FROM bronze.trailers
		) t
		WHERE rn = 1 AND trailer_id IS NOT NULL;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading trips
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.trips';
		TRUNCATE TABLE silver.trips;
		PRINT '>> Inserting Data Into: silver.trips';
		INSERT INTO silver.trips (
			trip_id ,
			load_id,
			driver_id ,
			truck_id  ,
			trailer_id ,
			dispatch_date,
			actual_distance_miles,
			actual_duration_hours ,
			fuel_gallons_used,
			average_mpg,
			idle_time_hours ,
			trip_status 
		)
		SELECT 
			TRIM(trip_id),
			TRIM(load_id), 
			ISNULL(NULLIF(TRIM(driver_id), ''), 'Unknown_Driver') AS driver_id,
			ISNULL(NULLIF(TRIM(truck_id), ''), 'Unknown_Truck') AS truck_id,
			ISNULL(NULLIF(TRIM(trailer_id), ''), 'Unknown_Trailer') AS trailer_id,
			TRY_CAST(dispatch_date AS DATE),
			CAST(actual_distance_miles AS DECIMAL(10, 2)),
			CAST(actual_duration_hours AS DECIMAL(10, 2)),
			CAST(fuel_gallons_used AS DECIMAL(10, 2)),
			CAST(average_mpg AS DECIMAL(5, 2)),
			CAST(idle_time_hours AS DECIMAL(10, 2)),
			TRIM(trip_status)
		FROM (
			SELECT *, ROW_NUMBER() OVER (
				PARTITION BY trip_id 
				ORDER BY (SELECT NULL)
			) as rn
			FROM bronze.trips
		) t
		WHERE rn = 1 AND trip_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading truck_utilization_metrics
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.truck_utilization_metrics';
		TRUNCATE TABLE silver.truck_utilization_metrics;
		PRINT '>> Inserting Data Into: silver.truck_utilization_metrics';
		INSERT INTO silver.truck_utilization_metrics (
			truck_id ,
			month_start_date ,
			month_name,
			trips_completed ,
			total_miles,
			total_revenue,
			average_mpg,
			maintenance_events,
			maintenance_cost,
			downtime_hours ,
			utilization_rate 
		)
		SELECT 
    TRIM(truck_id),
    CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, TRY_CAST([month] AS DATE)), 0) AS DATE) AS month_start_date,
    DATENAME(MONTH, TRY_CAST([month] AS DATE)) AS month_name,
    CAST(trips_completed AS INT),
    CAST(total_miles AS DECIMAL(18, 2)),
    CAST(total_revenue AS DECIMAL(18, 2)),
    CAST(average_mpg AS DECIMAL(5, 2)),
    CAST(maintenance_events AS INT),
    CAST(maintenance_cost AS DECIMAL(18, 2)),
    CAST(downtime_hours AS DECIMAL(10, 2)),
    CAST(utilization_rate AS DECIMAL(10, 4))
FROM (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY truck_id, DATEADD(MONTH, DATEDIFF(MONTH, 0, TRY_CAST([month] AS DATE)), 0) 
        ORDER BY (SELECT NULL)
    ) as rn
    FROM bronze.truck_utilization_metrics
) t
WHERE rn = 1 AND truck_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading trucks
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.trucks';
		TRUNCATE TABLE silver.trucks;
		PRINT '>> Inserting Data Into: silver.trucks';
		INSERT INTO silver.trucks (
			truck_id ,
			unit_number ,
			make ,
			model_year ,
			vin,
			acquisition_date,
			acquisition_mileage,
			fuel_type ,
			tank_capacity_gallons, 
			status ,
			home_terminal
		)
	   SELECT 
			TRIM(truck_id),
			TRIM(unit_number),
			(TRIM(make)),              
			CAST(model_year AS INT),
			UPPER(TRIM(vin)),
			TRY_CAST(acquisition_date AS DATE), 
			CAST(acquisition_mileage AS INT),
			TRIM(fuel_type),         
			CAST(tank_capacity_gallons AS INT), 
			TRIM(status),            
			TRIM(home_terminal)
		FROM (
			-- Deduplication: Ensure each truck appears only once
			SELECT *, ROW_NUMBER() OVER (
				PARTITION BY truck_id 
				ORDER BY (SELECT NULL)
			) as rn
			FROM bronze.trucks
		) t
		WHERE rn = 1 AND truck_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';



		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
		PRINT '==========================================';
	END CATCH
END

EXEC Silver.load_silver;

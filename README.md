## Fleet Performance & Supply Chain Intelligence Dashboard 🚛📊


### 📋 Project Overview

This project delivers a 5-page interactive Power BI Intelligence Suite designed for global logistics and fleet management. By integrating fragmented data across financials, assets, and labor, the dashboard provides a "Command Center" view of the supply chain. It empowers stakeholders to identify high-cost corridors, monitor vehicle health, and optimize driver performance through real-time data storytelling.

---

### 🔗 Quick Access

* 📊 [**View Executive Performance Report (PDF)**](Report_and_Dashboard/Fleet_Performance_Supply_Chain_Intelligence_Report.pdf)
  
* 🛠️ [**Download Power BI Dashboard (.pbix)**](Report_and_Dashboard/Logistics_Intelligence_Command_Center_v1.pbix)
  
* 💾 [**View SQL Gold-Layer Transformation Scripts**](SQL_Scripts/Gold/Gold_Layer_Views.sql)

---

### 🏗️ Architecture & Data Engineering

The project follows a Medallion Architecture (Bronze → Silver → Gold) to ensure data integrity and high-speed query performance:

- **Bronze** (Raw): Ingestion of raw logistics and fleet telemetry CSV files into SQL Server.

- **Silver** (Cleansed): Data transformation layer where null downtime values were handled, date formats standardized, and truck/driver categories normalized.

- **Gold** (Business Layer): Created 11 optimized SQL Views to serve as a high-performance "Gold Layer" source for Power BI, significantly reducing report-level processing time and DAX complexity.

---

### ⭐ Data Modeling (Star Schema)

The heart of this project is a high-performance Star Schema designed for scalability and analytical depth:

- **Fact Tables**: v_FactTripLoads, v_FactIncidentMaintenance, v_FactSupplyChainEvents, and v_FactMonthlyMetrics.

- **Dimension Tables**: v_DimTrucks, v_DimDrivers, v_DimFacilities, v_DimRoutes, v_DimTrailers, v_DimCustomers, and a custom v_DimDate.

- **Key Logic**: Implemented 1-to-Many relationships across 11 optimized views to ensure 100% filter integrity across all 5 dashboard pages.

  <details>
  <summary> Data Model </summary>
  <br>
  <img src="Assets/Logistics_Star_Schema_Data_Model.png" width="900" alt="Logistics_Star_Schema_Data_Model">
  </details>

 --- 

### 🖼️ Visualizations & Insights

💡 Tip: Click on any heading below to view the interactive dashboard screenshots and deep-dive insights.

--- 

<details>
  <summary> 🏠 Home Page (Navigation Hub) </summary>
  <br>
  <img src="Assets/01_Home_Page.png" width="900" alt="01_Home_Page">
</details>

- **Centralized Navigation**: Custom UI/UX with button-driven navigation for a "Web App" feel.

- **High-Level Branding**: Professional dark-mode design with clear project categorization.
  
---

 <details>
  <summary> 📊 Executive Financial Overview </summary>
  <br>
  <img src="Assets/02_Executive_Financial_Overview.png" width="900" alt="02_Executive_Financial_Overview">
</details>

- **Profitability Analysis**: Real-time monitoring of Net Profit ($193.46K) and Profit Margins (72.41%).

- **Revenue vs. Profit Correlation**: Identifies which freight types (Automotive vs. Food) drive the highest margins.

- **Route Profitability**: Visualizes the most lucrative "Lanes" in the network (e.g., Charlotte to Portland).
  
---

<details>
  <summary> 🚚 Operational Efficiency & Assets </summary>
  <br>
  <img src="Assets/03_Operational_Efficiency_and_Assets.png" width="900" alt="03_Operational_Efficiency_and_Assets">
</details>

- **Asset Health**: Tracks Fleet Uptime (90.28%) vs. Downtime Hours to predict maintenance cycles.

- **Brand Reliability**: Compares downtime trends across brands like Mack, Volvo, and Freightliner.

- **Timeline Insights**: Analyzes downtime by model year to identify aging assets (2015-2017) requiring replacement.

--- 

<details>
  <summary>🛡️ Driver Performance & Safety </summary>
  <br>
  <img src="Assets/04_Driver_Performance_and_Safety.png" width="900" alt="04_Driver_Performance_and_Safety">
 </details>

   
- **On-Time Delivery (OTD)**: Benchmarks driver efficiency to ensure customer satisfaction.

- **Dwell Time Analysis**: Identifies bottlenecks at facilities where drivers are stuck in idle time.

- **Revenue Ranking**: Highlights top-performing drivers based on Revenue per Active Hour.

---

<details>
  <summary> 🏗️ Logistic & Facility  Analysis</summary>
  <br>
  <img src="Assets/05_Logistic_and_Facility_Analysis.png" width="900" alt="05_Logistic_and_Facility_Analysis">
  </details>

- **Route Profitability Index (RPI)**: Uses a red/green heatmap to isolate losing routes (e.g., New York to Philadelphia).

- **Incident Impact**: Quantifies the financial cost of customer complaints vs. insurance claims.

- **Facility Throughput**: Ranks warehouses by volume to optimize resource allocation.

---

### 🧰 Tools & Skills Used

- **Power BI**: Advanced visualization, UI/UX design, and report publishing.

- **DAX (Data Analysis Expressions)**:

  Time Intelligence: YoY Growth, Prior Year (PY) calculations.
      
  Dynamic Labels: Handling nulls/blanks for professional "0.0%" reporting.
      
  Custom Metrics: Route Profitability Index (RPI) and Fleet Utilization %.
      
  Power Query: Data cleaning, ETL processes, and merging disparate datasets.
      
  Data Modeling: Star Schema design, managing Many-to-One relationships.

---

### 👤 Author: Meenakshi Singh | Aspiring Data Analyst

Specializing in SQL, Data Modeling, and Business Intelligence.



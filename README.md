# 🚛 Fleet Performance & Supply Chain Intelligence Suite

## Executive Overview
This **End-to-End Business Intelligence Suite** transforms raw transactional logistics data into actionable executive insights. Developed for a multi-regional freight operation, the dashboard provides a high-fidelity "Control Center" experience to monitor financial health, asset utilization, and safety compliance.

---

### 🔗 Quick Access

* 📊 [**View Executive Performance Report (PDF)**](Report_and_Dashboard/Fleet_Performance_Supply_Chain_Intelligence_Report.pdf)
  
* 🛠️ [**Download Power BI Dashboard (.pbix)**](Report_and_Dashboard/Logistics_Intelligence_Command_Center_v1.pbix)
  
* 💾 [**View SQL Gold-Layer Transformation Scripts**](SQL_Scripts/02_Gold_Reporting_Views.sql)

---

## 🛠️ Technical Architecture

#### **Backend Architecture & Data Transformation**
* **Medallion Pipeline:** Orchestrated a Bronze-to-Silver ETL process using Stored Procedures to clean, deduplicate (via `ROW_NUMBER`), and standardize raw telemetry data.
* **SQL Gold Layer:** Engineered a series of T-SQL views to denormalize a complex Snowflake schema into a high-performance Star Schema, optimizing refresh efficiency.
* **Data Integrity:** Implemented `ISNULL` and `COALESCE` logic within the SQL layer to ensure 100% metric accuracy across financial and safety reporting.

#### **Analytical Modeling & Business Logic**
* **KPI Intelligence:** Built a custom library of calculated measures to track multi-dimensional metrics, including **Net Profit Margin** and **Asset Utilization Rates**.
* **Categorical Engineering:** Developed custom logic for **Driver Experience Tiers** (Rookie to Veteran) and **Safety Incident Flags** to provide deeper HR and risk insights.
* **Exception Reporting:** Utilized advanced filtering and diverging visualization logic to identify **High-Yield vs. High-Loss Lanes** and facilities with high detention risk.

---

## 📊 Dashboard Gallery
*Click on any image to view it in high resolution.*

### **01. Landing & Navigation Hub**
[<img src="Assets/01_Home_Page.jpg" width="1000" alt="Home Page">](Assets/01_Home_Page.png)
> **Insight:** Features an intuitive navigation system with custom "Selected" states to guide users through four distinct operational domains.

### **02. Executive Financial Overview**
[<img src="Assets/02_Executive_Financial_Overview.png" width="1000" alt="Financial Overview">]Assets/(Assets/02_Executive_Financial_Overview.png)
> **Insight:** Strategic view of margin protection. Includes a **Customer Profitability Scatter Plot** and "Accessorial Impact" tracking to monitor hidden costs.

### **03. Operational Efficiency & Assets**
[<img src="Assets/03_Operational_Efficiency_and_Assets.png" width="1000" alt="Asset Analysis">](Assets/03_Operational_Efficiency_and_Assets.png)
> **Insight:** Technical fleet management focusing on **MPG vs. Utilization correlation** and manufacturer-specific maintenance trends.

### **04. Driver Performance & Safety**
[<img src="Assets/04_Driver_Performance_and_Safety.png" width="1000" alt="Safety Analysis">](Assets/04_Driver_Performance_and_Safety.png)
> **Insight:** Now featuring enhanced **Experience Tier** (Rookie to Veteran) breakdowns. Includes a **Year-over-Year Safety Incident Distribution** chart.

### **05. Logistic & Facility Analysis**
[<img src="Assets/05_Logistic_and_Facility_Analysis.png" width="1000" alt="Facility Analysis">](Assets/05_Logistic_and_Facility_Analysis.png)
> **Insight:** Tactical view of hub throughput. Utilizes a **Diverging Bar Chart** to identify "High-Yield vs. High-Loss Lanes" and identifies facilities with high detention risk.

---

## 🏗️ Data Model (Star Schema)
[<img src="Assets/Logistics_Star_Schema_Data_Model.png" width="1000" alt="Data Model">](Assets/Logistics_Star_Schema_Data_Model.png)
*Architecture showing the refined relationship between Gold Layer Fact tables and Dimensions.*

---

## 🚀 Deployment & SQL Scripts
1. **Database Setup:** Run the scripts in the `/SQL_Scripts` folder to build the Bronze, Silver, and Gold layers.
2. **ETL Execution:** Run `EXEC silver.load_silver` to process and standardize raw data.
3. **Power BI:** Open the `.pbix` file and refresh to see the modeled data in action.

---

**Author:** Meenakshi Singh  
**Role:** Aspiring Data Analyst | SQL & Power BI Specialist  





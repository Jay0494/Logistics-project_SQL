# 📦 Logistics Performance & Delay Analysis (SQL)

---

## 🧭 Introduction

This project analyses delivery performance across a UK logistics network using **MySQL**.
The goal is to uncover inefficiencies in delivery operations by examining delay patterns, regional performance, and delivery time behaviour.

Using structured SQL analysis, the project transforms raw logistics data into actionable insights that support **operational optimisation and decision-making**.

The workflow covers:

* Data validation
* KPI development
* Segmentation analysis
* Regional performance diagnostics

---

## ❓ Business Question

**What are the key drivers of delivery delays across regions, and how can late deliveries be reduced to improve operational efficiency?**

---

## 📊 Insights

### 🔹 1. Overall Performance

* **Total Deliveries:** 500
* **Late Delivery Rate:** 23%
* **On-Time Rate:** 70.6%
* **Cancel Rate:** 6.4%
* **Average Delay:** ~29 minutes

👉 Operational performance is moderate, but **nearly 1 in 4 deliveries are late**, indicating a significant efficiency gap.

---

### 🔹 2. Short Deliveries Have Higher Delay Rates

* Deliveries within **0–60 minutes show the highest late rates (~30%)**
* Longer deliveries (>90 mins) are more stable

👉 This suggests delays are caused by **dispatch inefficiencies**, not travel distance.

---

### 🔹 3. Regional Performance Gaps

* **South East:** Highest delay rate (~29%) → critical issue
* **London:** High volume + high delays → operational bottleneck
* **Midlands:** Best performance → benchmark region

👉 Performance inconsistency shows **lack of standardised operations across regions**.

---

### 🔹 4. Delay Contribution is Highly Concentrated

* **South East, Scotland, and London contribute ~60%+ of total delays**

👉 Delays are **not evenly distributed**, meaning targeted interventions will be more effective than global fixes.

---

### 🔹 5. High Variability in Delays

* Standard deviation of delays is high across regions

👉 Indicates **inconsistent delivery execution**, not just average performance issues.

---

## 🧠 Techniques & Queries

### 🔹 1. Data Exploration

Basic i<img width="758" height="827" alt="USING THE SELECT QUERY " src="https://github.com/user-attachments/assets/769780a2-5d38-4438-8806-be4b2f1cc942" />
nspection of dataset structure:

```sql
SELECT * FROM logistics;
```

---

### 🔹 2. Data Quality Check (Duplicates)
<img width="610" height="264" alt="CHECK FOR DUPLICATES " src="https://github.com/user-attachments/assets/f2061bb9-8a2e-4afc-932f-ffef58ab6455" />

```sql
SELECT Order_ID, COUNT(*) AS No_of_duplicates
FROM logistics
GROUP BY Order_ID
HAVING COUNT(*) > 1;
```

✔ Ensured data integrity before analysis

---

### 🔹 3. Filtering Valid Deliveries
<img width="569" height="300" alt="total deliveries " src="https://github.com/user-attachments/assets/3298815f-72b8-4155-880b-787dfda7a824" />

```sql
SELECT COUNT(*) AS Total_deliveries
FROM logistics
WHERE Delivery_Status <> "Cancelled";
```

---

### 🔹 4. KPI Calculation (Core Metrics)
<img width="691" height="628" alt="KPI SUMMARY" src="https://github.com/user-attachments/assets/ca238b3a-34e8-41f3-8322-64f1034ee7ec" />

```sql
SELECT 
    COUNT(*) AS total_deliveries,

    ROUND(SUM(CASE WHEN Delivery_Status = "Cancelled" THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancel_rate,

    ROUND(SUM(CASE WHEN Delivery_Status = "Delayed" THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_rate,

    ROUND(SUM(CASE WHEN Delivery_Status = "On Time" THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_rate,

    ROUND(AVG(Delay_Minutes), 2) AS average_delay_minutes

FROM logistics;
```

✔ Used **CASE WHEN + aggregation** to derive business KPIs

---

### 🔹 5. Delivery Time Segmentation
<img width="910" height="895" alt="Delivery Time vs Delay Relationship" src="https://github.com/user-attachments/assets/4c240e00-427f-4a9d-921a-905aa22cc02e" />


```sql
SELECT
    CASE
        WHEN Delivery_Time_Minutes <= 30 THEN '0-30 mins'
        WHEN Delivery_Time_Minutes <= 60 THEN '31-60 mins'
        WHEN Delivery_Time_Minutes <= 90 THEN '61-90 mins'
        WHEN Delivery_Time_Minutes <= 120 THEN '91-120 mins'
        ELSE '120+ mins'
    END AS delivery_time_duration,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(CASE WHEN Delivery_Status = 'Delayed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2) AS late_delivery_rate,

    ROUND(AVG(Delay_Minutes), 2) AS avg_delay_minutes
FROM logistics
GROUP BY delivery_time_duration
ORDER BY delivery_time_duration;
```

✔ Applied **CASE segmentation** for behavioural analysis

---

### 🔹 6. Region-Level Performance Analysis
<img width="751" height="653" alt="REGION CONTRIBUTING TO DELAYS " src="https://github.com/user-attachments/assets/65dde9b3-e7d4-4652-b43b-33cf1495d3ee" />

```sql
SELECT
    Region,
    COUNT(*) AS total_deliveries,

    ROUND(SUM(CASE WHEN Delivery_Status = "Delayed" THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_rate,

    ROUND(SUM(CASE WHEN Delivery_Status = "On Time" THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_delivery_rate,

    ROUND(AVG(Delay_Minutes), 2) AS avg_delay_minutes,

    ROUND(STDDEV(Delay_Minutes), 2) AS delay_stddev

FROM logistics
GROUP BY Region
ORDER BY total_deliveries DESC;
```

✔ Used **aggregations + STDDEV** for performance variability analysis

---

### 🔹 7. Contribution to Total Delays (Window Function)
<img width="751" height="653" alt="REGION CONTRIBUTING TO DELAYS " src="https://github.com/user-attachments/assets/f2632dc4-fcab-4683-8024-ad0ff9ae92f7" />

```sql
SELECT
    Region,

    SUM(CASE WHEN Delay_Minutes > 0 THEN Delay_Minutes ELSE 0 END) AS total_delay_minutes,

    ROUND(
        100.0 * SUM(CASE WHEN Delay_Minutes > 0 THEN Delay_Minutes ELSE 0 END)
        / SUM(SUM(CASE WHEN Delay_Minutes > 0 THEN Delay_Minutes ELSE 0 END)) OVER (),
    2) AS contribution_to_total_delay_pct

FROM logistics
GROUP BY Region
ORDER BY total_delay_minutes DESC;
```

✔ Applied **window functions (OVER())** to calculate contribution percentages

---

## 📁 Project Files

* SQL Script: 
* Query outputs & screenshots

---

## 💼 Portfolio Impact Statement

> Conducted end-to-end SQL analysis on logistics delivery data to identify delay drivers, revealing that over 60% of delays originate from a small number of regions and that short-duration deliveries are disproportionately affected, indicating dispatch inefficiencies. Delivered actionable insights to improve regional operations and reduce late deliveries.

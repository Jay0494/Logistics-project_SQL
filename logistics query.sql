-- USING THE SELECT function to have a general look at the data 
SELECT * FROM logistics;
-- check for duplicates 
SELECT Order_ID, COUNT(*) AS No_of_duplicates
FROM logistics 
GROUP BY Order_ID
HAVING COUNT(*) > 1;   -- NO DUPLICATES 


-- EXPLORATORY ANALYSIS 

-- No of deliveries(delayed plus ontime) 
SELECT COUNT(*) AS Total_deliveries
FROM logistics
WHERE Delivery_Status <> "Cancelled";


-- KPI SUMMARY 
SELECT 
    COUNT(*) AS total_deliveries,
    ROUND(
        SUM(CASE WHEN Delivery_Status = "Cancelled" THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 
    2) AS Cancel_rate,

    ROUND(
        SUM(CASE WHEN Delivery_Status = "Delayed" THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 
    2) AS late_delivery_rate,

    ROUND(
        SUM(CASE WHEN Delivery_Status = "On Time" THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 
    2) AS on_time_rate,

    ROUND(
        AVG(Delay_Minutes), 
    2) AS average_delay_minutes
FROM logistics;
        
        
-- DELAY BAND DISTRIBUTION 
SELECT
    Delivery_Status,
    COUNT(*) AS deliveries,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM vw_delivery_performance
GROUP BY delay_band
ORDER BY
    CASE delay_band
        WHEN 'On Time' THEN 1
        WHEN '0-30 mins late' THEN 2
        WHEN '31-60 mins late' THEN 3
        ELSE 4
    END;




    
 
CREATE TABLE tickets_data(
Ticket_ID INT,
Customer_ID INT,
Agent_Name VARCHAR(150),
Repair_Issue VARCHAR(250),
Repair_Date DATE,
Part_Replaced VARCHAR (250),
Model_Name VARCHAR(350),
Laptop_Serial_Number VARCHAR(300)
);

SELECT * FROM tickets_data

CREATE TABLE customers_data(
Customer_ID INT,
Customer_Name VARCHAR (300),
Email VARCHAR (250),
Phone_Number INT,
Address VARCHAR (500),
Customer_Sentiment VARCHAR (10)
);

SELECT * FROM customers_data

CREATE TABLE agents_data(
Agent_ID INT,
Agent_Name VARCHAR (250),
Email VARCHAR (250),
Phone_Number VARCHAR (50),
Address VARCHAR (500)
);

SELECT * FROM agents_data

DELETE FROM tickets_data
WHERE ctid NOT IN(
SELECT MIN(ctid)
FROM tickets_data
GROUP BY Ticket_ID
);

DELETE FROM customers_data
WHERE ctid NOT IN(
SELECT MIN(ctid)
FROM customers_data
GROUP BY Customer_ID
);

DELETE FROM agents_data
WHERE ctid NOT IN(
SELECT MIN(ctid)
FROM agents_data
GROUP BY Agent_ID
);

SELECT COUNT(*) FROM tickets_data
WHERE repair_issue IS NULL

UPDATE tickets_data
SET Agent_Name = 'Unassigned'
WHERE Agent_Name IS NULL

UPDATE tickets_data
SET repair_issue = (
SELECT repair_issue
FROM tickets_data AS t2
WHERE tickets_data.model_name = t2.model_name
AND t2.repair_issue IS NOT NULL
LIMIT 1
)
WHERE repair_issue IS NULL;

SELECT * FROM tickets_data

SELECT COUNT(*) FROM customers_data
WHERE customer_name IS NULL

UPDATE tickets_data
SET part_replaced = (
SELECT part_replaced
FROM tickets_data AS p2
WHERE tickets_data.model_name = p2.model_name 
AND tickets_data.repair_issue =p2.repair_issue
AND p2.part_replaced IS NOT NULL
LIMIT 1
)
WHERE part_replaced IS NULL;

SELECT COUNT(*) FROM customers_data
SELECT * FROM customers_data
WHERE address IS NULL

UPDATE customers_data
SET email = 'emailnotavailable@dell.com'
WHERE email IS NULL

SELECT COUNT(*) FROM agents_data
SELECT * FROM agents_data
WHERE address IS NULL

UPDATE agents_data
SET agent_name = 'NA'
WHERE agent_name IS NULL

UPDATE tickets_data
SET Repair_Date = TO_DATE(Repair_Date::TEXT, 'YYYY-MM-DD')
WHERE Repair_Date IS NOT NULL;


SELECT EXTRACT(YEAR FROM Repair_Date) AS Year,
       EXTRACT(MONTH FROM Repair_Date) AS Month,
       EXTRACT(DAY FROM Repair_Date) AS Day
FROM tickets_data;

SELECT DATE_TRUNC('month', Repair_Date) AS Month,
       COUNT(*) AS Ticket_Count
FROM tickets_data
WHERE Repair_Date IS NOT NULL
GROUP BY DATE_TRUNC('month', Repair_Date)
ORDER BY Month;

SELECT generate_series('2025-01-01', '2025-12-31', '1 day'::interval) AS Calendar_Date;

SELECT * FROM tickets_data

--How many repairs were completed by each agent, broken down by month?

SELECT agent_name,
COUNT(ticket_id) AS repaired_completed,
DATE_TRUNC ('Month', repair_date) AS Periods
FROM tickets_data
WHERE repair_date IS NOT NULL
GROUP BY agent_name, Periods;

--What is the success rate of repairs completed by each agent, excluding repeat repair issues from customers who have reported the same issue more than once?
SELECT agent_name,
(COUNT(ticket_id) - COUNT(DISTINCT CASE WHEN customer_id IN(
SELECT customer_id FROM tickets_data
GROUP BY customer_id, Repair_issue
HAVING COUNT(*) > 1
) THEN ticket_id END)) * 100.0 / COUNT(ticket_id) AS success_rate
FROM tickets_data
WHERE repair_date IS NOT NULL
GROUP BY agent_name
ORDER BY success_rate DESC;

SELECT ticket_id, customer_id from tickets_data
WHERE ticket_id IS NULL
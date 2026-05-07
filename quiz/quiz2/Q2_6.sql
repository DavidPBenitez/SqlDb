USE sakila;
GO

DROP TABLE IF EXISTS  #tmp_customer;

SELECT * 
INTO #tmp_customer 
FROM dbo.customer;

--Lets simulate the misspellings
UPDATE #tmp_customer
SET first_name = 'Hermaine'
WHERE customer_id BETWEEN 1 AND 50;

UPDATE #tmp_customer
SET first_name = 'Herrmone'
WHERE customer_id BETWEEN 51 AND 100;

UPDATE #tmp_customer
SET first_name = 'Hermaini'
WHERE customer_id BETWEEN 101 AND 150;

--Now, lets check UNION
SELECT first_name from dbo.customer
UNION ALL
SELECT first_name from #tmp_customer
ORDER BY first_name

--Now, lets check INTERSECT
SELECT first_name from dbo.customer
INTERSECT
SELECT first_name from #tmp_customer

--Now, lets check EXCEPT
SELECT first_name from dbo.customer
EXCEPT
SELECT first_name from #tmp_customer

DROP TABLE IF EXISTS  #tmp_customer;
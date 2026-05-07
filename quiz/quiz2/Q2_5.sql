USE sakila;
GO

DROP TABLE IF EXISTS  #tmp_customer;
DROP TABLE IF EXISTS  #almost_customer;

SELECT * 
INTO #almost_customer 
FROM dbo.customer;

--Lets simulate the misspellings
UPDATE #almost_customer
SET first_name = 'Hermaine'
WHERE customer_id BETWEEN 1 AND 50;

UPDATE #almost_customer
SET first_name = 'Herrmone'
WHERE customer_id BETWEEN 51 AND 100;

UPDATE #almost_customer
SET first_name = 'Hermaini'
WHERE customer_id BETWEEN 101 AND 150;


--Let's start by copying the data to a temporary table, so we can work on it without affecting the original data
SELECT * 
INTO #tmp_customer 
FROM #almost_customer 

--Now, lets find all misspellings
SELECT first_name, COUNT(*) FROM #tmp_customer
WHERE first_name LIKE 'Her%'
GROUP BY first_name;

--Now, lets correct all misspellings
UPDATE #tmp_customer
SET first_name = 'Hermoine'
WHERE first_name IN ('Hermaine', 'Herrmone', 'Hermaini');


--Finally, lets ensure all is corrected
SELECT first_name, COUNT(*) FROM #tmp_customer
WHERE first_name LIKE 'Her%'
GROUP BY first_name;



--Now we are ready to update #almost_customer with the correct names from #tmp_customer
--check corrections
SELECT tmp.first_name, c.first_name FROM #tmp_customer tmp
INNER JOIN #almost_customer c ON tmp.customer_id = c.customer_id
WHERE tmp.first_name = 'Hermoine'


--Now we are ready to update the actual customer table with the correct names from #tmp_customer
UPDATE c
    SET c.first_name = tmp.first_name
FROM #tmp_customer tmp
INNER JOIN #almost_customer c ON tmp.customer_id = c.customer_id
WHERE tmp.first_name = 'Hermoine'


--Verify corrections
SELECT first_name, COUNT(*) FROM #almost_customer
WHERE first_name LIKE 'Her%'
GROUP BY first_name;



DROP TABLE IF EXISTS  #tmp_customer;
DROP TABLE IF EXISTS  #almost_customer;
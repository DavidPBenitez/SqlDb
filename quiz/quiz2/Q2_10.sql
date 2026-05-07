USE sakila;

DROP TABLE IF EXISTS #tmp_payment
GO

--A
SELECT * INTO #tmp_payment FROM dbo.payment;
DELETE from #tmp_payment WHERE customer_id BETWEEN 222 AND 322;

--B
SELECT COUNT(*) FROM dbo.customer c
INNER JOIN #tmp_payment p ON c.customer_id = p.customer_id;

--C
SELECT COUNT(*) FROM dbo.customer c
LEFT OUTER JOIN #tmp_payment p ON c.customer_id = p.customer_id;

--D
SELECT c.customer_id, SUM(p.amount) FROM dbo.customer c
INNER JOIN #tmp_payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

--E
SELECT c.customer_id, SUM(p.amount) FROM dbo.customer c
LEFT OUTER JOIN #tmp_payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

DROP TABLE IF EXISTS #tmp_payment
GO
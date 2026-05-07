USE sakila;
GO

--DROP TABLE IF EXISTS  #tmp_customer;

SELECT * 
INTO #tmp_customer 
FROM dbo.customer;

SELECT * FROM dbo.customer;

--DROP TABLE IF EXISTS  #tmp_customer;
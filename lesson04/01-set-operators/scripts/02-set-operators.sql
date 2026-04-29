USE sakila;
GO

--Use UNION to create one result set, UNION ALL ensures duplicate rows are kept
SELECT 'Customers', COUNT(DISTINCT first_name) AS nr_distinct_names FROM dbo.customer
UNION ALL
SELECT 'Actors', COUNT(DISTINCT first_name) AS nr_distinct_names FROM dbo.actor;

--Use UNION to create one result set, UNION ALL ensures duplicate rows are kept
SELECT 'Customers', COUNT(DISTINCT first_name) AS nr_distinct_names FROM dbo.customer
UNION 
SELECT 'Actors', COUNT(DISTINCT first_name) AS nr_distinct_names FROM dbo.actor;


--Lets look at all the names in Customer which is also in actor table
SELECT COUNT(DISTINCT first_name) FROM dbo.customer 
WHERE first_name IN(SELECT first_name FROM dbo.actor);

--This is another way to do the same thing, much more effective
SELECT COUNT (f.first_name) 
FROM (
    SELECT first_name FROM dbo.customer 
    INTERSECT
    SELECT first_name FROM dbo.actor) AS f;

--let's see the actual names
SELECT first_name FROM dbo.customer 
INTERSECT
SELECT first_name FROM dbo.actor;

--Lets look at all the names in Customer which NOT in actor table
SELECT COUNT(DISTINCT first_name) FROM dbo.customer 
WHERE first_name NOT IN(SELECT first_name FROM dbo.actor)

--This is another way to do the same thing, much more effective
SELECT COUNT(f.first_name)
FROM (
    SELECT first_name FROM dbo.customer 
    EXCEPT
    SELECT first_name FROM dbo.actor) AS f;

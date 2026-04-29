USE sakila;
GO

-- ============================================================
-- Exercise 1 – UNION ALL
-- ============================================================

-- Full distinct first-name counts for both tables
SELECT 'Staff'     AS Source, COUNT(DISTINCT first_name) AS DistinctFirstNames FROM dbo.staff
UNION ALL
SELECT 'Customers',           COUNT(DISTINCT first_name)                        FROM dbo.customer;

-- Filtered to names beginning with 'J', ordered by count descending
SELECT 'Staff'     AS Source, COUNT(DISTINCT first_name) AS DistinctFirstNames FROM dbo.staff     WHERE first_name LIKE 'J%'
UNION ALL
SELECT 'Customers',           COUNT(DISTINCT first_name)                        FROM dbo.customer WHERE first_name LIKE 'J%'
ORDER BY DistinctFirstNames DESC;
GO

-- ============================================================
-- Exercise 1b – UNION ALL (three tables)
-- ============================================================

-- Distinct last names from customer, actor, and staff combined
-- UNION (without ALL) removes duplicates across all three sets
SELECT last_name FROM dbo.customer
UNION
SELECT last_name FROM dbo.actor
UNION
SELECT last_name FROM dbo.staff
ORDER BY last_name;
GO

-- ============================================================
-- Exercise 2 – INTERSECT
-- ============================================================

-- 2a: List of last names shared by customers and staff
SELECT last_name FROM dbo.customer
INTERSECT
SELECT last_name FROM dbo.staff
ORDER BY last_name;

-- 2b: Count of shared last names
SELECT COUNT(last_name) AS SharedLastNameCount
FROM (
    SELECT last_name FROM dbo.customer
    INTERSECT
    SELECT last_name FROM dbo.staff
) AS shared;
GO

-- ============================================================
-- Exercise 3 – EXCEPT
-- ============================================================

-- 3a: List of film_ids that exist in film but NOT in inventory
SELECT film_id FROM dbo.film
EXCEPT
SELECT film_id FROM dbo.inventory
ORDER BY film_id;

-- 3b: Count using EXCEPT
SELECT COUNT(film_id) AS FilmsNotInInventory
FROM (
    SELECT film_id FROM dbo.film
    EXCEPT
    SELECT film_id FROM dbo.inventory
) AS missing;

-- 3c: Same count using NOT IN (alternative approach — result should match 3b)
SELECT COUNT(film_id) AS FilmsNotInInventory
FROM dbo.film
WHERE film_id NOT IN (SELECT film_id FROM dbo.inventory);
GO

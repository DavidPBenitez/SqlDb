-- ============================================================
-- CTE-Based Pagination using the Sakila database
-- ============================================================
-- The film table has 1000 rows, making it a good candidate
-- for demonstrating pagination.
--
-- Pattern:
--   1. A CTE assigns a ROW_NUMBER() to every row in the
--      desired sort order.
--   2. The outer query filters by the row-number window that
--      corresponds to the requested page.
--
-- Page formula:
--   First row : (@PageNumber - 1) * @PageSize + 1
--   Last  row : @PageNumber * @PageSize
-- ============================================================

USE sakila;
GO

-- ── Starter: ROW_NUMBER() in a plain SELECT ───────────────────
-- Before using ROW_NUMBER() inside a CTE, see what it produces on its own.
-- It simply adds a sequential number to each row in the specified sort order.
-- Note: The ORDER BY inside the OVER() clause determines the sort order for pagination.
-- The final ORDER BY at the end of the query ensures the output is in the same order as the row numbers.
SELECT
    ROW_NUMBER() OVER (ORDER BY title ASC) AS rn,
    film_id,
    title,
    rating
FROM film
ORDER BY rn;
GO

-- Change these two variables to navigate between pages.
DECLARE @PageNumber INT = 1;   -- Which page to retrieve (1-based)
DECLARE @PageSize   INT = 10;  -- Number of rows per page

-- ── Example 1: Paginate films ordered by title ───────────────
WITH FilmsPaged AS (
    SELECT
        film_id,
        title,
        release_year,
        rating,
        rental_rate,
        length,
        ROW_NUMBER() OVER (ORDER BY title ASC) AS rn  -- window fn: number every row in title order
    FROM film
)
SELECT
    rn          AS row_num,
    film_id,
    title,
    release_year,
    rating,
    rental_rate,
    length
FROM FilmsPaged
WHERE rn BETWEEN (@PageNumber - 1) * @PageSize + 1
              AND  @PageNumber      * @PageSize
ORDER BY rn;
GO

-- ── Example 2: Paginate films with a total-row-count column ──
-- Useful for building "Page X of Y" UI elements.
DECLARE @PageNumber INT = 2;
DECLARE @PageSize   INT = 10;

WITH FilmsPaged AS (
    SELECT
        film_id,
        title,
        rating,
        rental_rate,
        ROW_NUMBER() OVER (ORDER BY title ASC) AS rn,  -- window fn: number every row in title order
        COUNT(*)     OVER ()                   AS total_rows
    FROM film
)
SELECT
    rn                                                  AS row_num,
    total_rows,
    CEILING(CAST(total_rows AS FLOAT) / @PageSize)      AS total_pages,
    film_id,
    title,
    rating,
    rental_rate
FROM FilmsPaged
WHERE rn BETWEEN (@PageNumber - 1) * @PageSize + 1
              AND  @PageNumber      * @PageSize
ORDER BY rn;
GO

-- ── Example 3: Paginate customers ordered by last_name ───────
DECLARE @PageNumber INT = 3;
DECLARE @PageSize   INT = 10;

WITH CustomersPaged AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        email,
        active,
        ROW_NUMBER() OVER (ORDER BY last_name ASC, first_name ASC) AS rn  -- window fn: number every row in last_name/first_name order; first_name breaks ties for a deterministic sequence
    FROM customer
)
SELECT
    rn AS row_num,
    customer_id,
    first_name,
    last_name,
    email,
    active
FROM CustomersPaged
WHERE rn BETWEEN (@PageNumber - 1) * @PageSize + 1
              AND  @PageNumber      * @PageSize
ORDER BY rn;
GO

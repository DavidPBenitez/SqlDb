USE sakila;
GO

--beginning CTE part
;WITH actors AS
    (SELECT actor_id, first_name, last_name FROM actor 
     WHERE last_name LIKE 'S%')

-- Use a comma to separate multiple CTE definitions.
,
actors_movies AS
    (SELECT a.actor_id, a.first_name, a.last_name, f.film_id, f.title
     FROM actors a 
     INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
     INNER JOIN film f ON f.film_id = fa.film_id
     WHERE f.rating = 'PG')

-- Use a comma to separate multiple CTE definitions.
, 
actors_movies_revenue AS (
    SELECT am.first_name, am.last_name, p.amount 
        FROM actors_movies am 
            INNER JOIN inventory i ON i.film_id = am.film_id
            INNER JOIN rental r ON i.inventory_id = r.inventory_id
            INNER JOIN payment p ON r.rental_id = p.rental_id)
-- end of With clause

-- start of the SELECT using the CTE defined 
SELECT amr.first_name, amr.last_name, SUM (amr.amount) tot_revenue
FROM actors_movies_revenue amr
GROUP BY amr.first_name, amr.last_name
ORDER BY 3 DESC;


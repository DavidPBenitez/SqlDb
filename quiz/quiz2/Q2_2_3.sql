USE sakila;
GO

-- rentals returned less than a week after rental
SELECT COUNT(rental_id) /*, rental_date, return_date */ FROM dbo.rental WHERE return_date < DATEADD(week, 1, rental_date);

-- rentals returned more or equal to a week after rental
SELECT COUNT(rental_id) /*, rental_date, return_date*/ FROM dbo.rental WHERE return_date >= DATEADD(week, 1, rental_date);

-- rentals returned more or equal to a week after rental OR not returned
SELECT COUNT(rental_id) /*, rental_date, return_date*/ FROM dbo.rental WHERE return_date >= DATEADD(week, 1, rental_date) OR return_date IS NULL;
USE Friends;
GO

--assigned in SELECT, and used in WHERE
DECLARE @nrPets int;
DECLARE @ownerLastName NVARCHAR(200) = 'Took';

--multiple rows are returned so @aPet will be assigned last row.
SELECT @nrPets = COUNT(*)
FROM dbo.Pet AS p 
    INNER JOIN dbo.Friend AS f ON p.OwnerId = f.FriendId
WHERE f.LastName = @ownerLastName;

SELECT @nrPets;

--Let's switch to sakilla
USE sakila;
GO

--used in HAVING
DECLARE @totAmount money = 150.00;

SELECT [customer_id], COUNT(*), SUM([amount])
FROM [sakila].[dbo].[payment]
GROUP BY customer_id
HAVING SUM([amount]) >= @totAmount
ORDER BY 2 DESC;


USE Friends;
GO

--Create an unique multicolumn index, this ensures addresses are nut duplicated
CREATE UNIQUE INDEX UniqueIdx_Address_Street ON dbo.Address (StreetAddress, ZipCode, City, Country);

--This will fail, as the unique index does not allow duplicate addresses
INSERT INTO Address
    (StreetAddress, ZipCode, City, Country)
VALUES 
    ('Svedjevägen 2',      18399, 'Malmö',      'Sweden')



CREATE INDEX Address_Country ON dbo.Address (Country, City);

--the index will optimize below query, as the index is ordered by Country first, then City
SELECT * FROM dbo.Address
WHERE Country = 'Sweden' OR City = 'Malmö';



CREATE INDEX Address_City ON dbo.Address (City, Country);

--the index will optimize below query, as the index is ordered by City first, then Country
SELECT * FROM dbo.Address
WHERE City = 'Malmö' OR Country = 'Sweden';


--Show indexes in a table
EXEC sp_helpindex 'dbo.Address';

-- Show indexes with full details
SELECT * FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.Address');

--Delete an index
DROP INDEX UniqueIdx_Address_Street ON dbo.Address;
DROP INDEX Address_Country ON dbo.Address;
DROP INDEX Address_City ON dbo.Address;


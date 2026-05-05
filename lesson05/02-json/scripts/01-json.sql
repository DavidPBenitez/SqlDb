USE friends;
GO


-- FOR JSON AUTO: SQL Server infers the JSON structure from table aliases.
-- All columns land flat at the root level when aliases are explicit.
-- Nesting is only automatic when column names are ambiguous across joined tables.
SELECT f.FriendId , f.FirstName , f.LastName, 
    a.Country AS Country, CONCAT_WS(' ', p.Name, 'the happy', p.AnimalKind) AS Pet
FROM dbo.friend f
INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
INNER JOIN dbo.Pet p ON f.FriendId = p.OwnerId
FOR JSON AUTO

-- FOR JSON PATH with no dot notation: you control the structure via aliases,
-- but without dots every column stays flat -- same shape as AUTO here.
SELECT f.FriendId , f.FirstName , f.LastName, 
    a.Country AS Country, CONCAT_WS(' ', p.Name, 'the happy', p.AnimalKind) AS Pet
FROM dbo.friend f
INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
INNER JOIN dbo.Pet p ON f.FriendId = p.OwnerId
FOR JSON PATH


-- FOR JSON PATH: column aliases with dot notation create nested JSON objects
-- e.g. "Address.Country" nests Country inside an "Address" object
SELECT f.FriendId AS "Id", CONCAT_WS(' ', f.FirstName, f.LastName) AS "Name",
    a.Country AS "Address.Country", a.City AS "Address.City",
    CONCAT_WS(' ', p.Name, 'the happy', p.AnimalKind) AS "Pet.Name"
FROM dbo.friend f
INNER JOIN dbo.Address a
ON f.AddressId = a.AddressId
INNER JOIN dbo.Pet p
ON f.FriendId = p.OwnerId
FOR JSON PATH, ROOT('MyFriend')
-- Note: unlike FOR XML PATH('ElementName'), FOR JSON PATH takes no argument.
-- To wrap the output in a named root object, use the ROOT option:
--   FOR JSON PATH, ROOT('MyFriend')


--you can store it in an json file using azure data studio. 
--I modified so it can be opened in Excel
--   1. Click on the result so it opens up in a new Azure tab
--   2. save the tab as a json file, friends1.json. Make sure you do save as.. and select JSON format


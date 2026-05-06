USE friends;
GO

--get a row count before populating
SELECT 'Nr of Pets' AS [Item], COUNT(*) AS [Count] FROM dbo.Pet
UNION
SELECT 'Nr of Friends', COUNT(*) FROM dbo.Friend
UNION
SELECT 'Nr of Addresses', COUNT(*) FROM dbo.Address;

--Extract Address data as JSON
SELECT * FROM dbo.Address
FOR JSON PATH
--save the result as json file, populate-address.json. Make sure you do save as.. and select JSON format

--Extract Friend data as JSON
SELECT * FROM dbo.Friend
FOR JSON PATH
--save the result as json file, populate-friend.json. Make sure you do save as.. and select JSON format

--Extract Pet data as JSON
SELECT * FROM dbo.Pet
FOR JSON PATH
--save the result as json file, populate-pet.json. Make sure you do save as.. and select JSON format


--Preparations: copy the json files into the Docker container
--   1. Open a terminal in the directory of your json files on the computer
--   2. Create a directory in the Docker container:
--         docker exec -u root sql2022container mkdir /usr/jsonfiles
--   3. Copy the json files from your computer into the Docker container:
--         docker cp populate-address.json sql2022container:/usr/jsonfiles/
--         docker cp populate-friend.json sql2022container:/usr/jsonfiles/
--         docker cp populate-pet.json sql2022container:/usr/jsonfiles/


--delete existing data
DELETE FROM dbo.Pet;
DELETE FROM dbo.Friend;
DELETE FROM dbo.Address;
DELETE FROM dbo.FriendQuote;
DELETE FROM dbo.Quote;


INSERT INTO dbo.Address ([AddressId], [StreetAddress], [ZipCode], [City], [Country])
SELECT [AddressId], [StreetAddress], [ZipCode], [City], [Country] 
FROM
-- Docker container
OPENROWSET(BULK N'/usr/jsonfiles/populate-address.json', SINGLE_CLOB) AS json
CROSS APPLY OPENJSON(BulkColumn)
WITH(
	[AddressId] [uniqueidentifier],
	[StreetAddress] [nvarchar](200),
	[ZipCode] [int],
	[City] [nvarchar](200),
	[Country] [nvarchar](200)
    )


INSERT INTO dbo.Friend ([FriendId], [FirstName], [LastName], [Email], [Birthday], [AddressId])
SELECT [FriendId], [FirstName], [LastName], [Email], [Birthday], [AddressId]
FROM
-- Docker container
OPENROWSET(BULK N'/usr/jsonfiles/populate-friend.json', SINGLE_CLOB) AS json
CROSS APPLY OPENJSON(BulkColumn)
WITH(
	[FriendId] [uniqueidentifier],
	[FirstName] [nvarchar](200),
	[LastName] [nvarchar](200),
	[Email] [nvarchar](200),
	[Birthday] [date],
	[AddressId] [uniqueidentifier]
    )

INSERT INTO dbo.Pet ([PetId], [AnimalKind], [AnimalMood], [Name], [OwnerId])
SELECT [PetId], [AnimalKind], [AnimalMood], [Name], [OwnerId]
FROM
-- Docker container
OPENROWSET(BULK N'/usr/jsonfiles/populate-pet.json', SINGLE_CLOB) AS json
CROSS APPLY OPENJSON(BulkColumn)
WITH(
	[PetId] [uniqueidentifier],
	[AnimalKind] [nvarchar](200),
	[AnimalMood] [nvarchar](200),
	[Name] [nvarchar](200),
	[OwnerId] [uniqueidentifier]
    )


--get a row count before populating
SELECT 'Nr of Pets' AS [Item], COUNT(*) AS [Count] FROM dbo.Pet
UNION
SELECT 'Nr of Friends', COUNT(*) FROM dbo.Friend
UNION
SELECT 'Nr of Addresses', COUNT(*) FROM dbo.Address;
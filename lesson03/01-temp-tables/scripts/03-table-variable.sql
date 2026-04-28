USE Friends;
GO

--Create temp table
DECLARE @PetList TABLE (
    petName NVARCHAR(50),
    ownerName NVARCHAR(400),
    ownerEmail NVARCHAR(200));


--fill the table using Select from Pet linked with friend
--use COALESCE instead of ISNULL, same when only one parameter to test for null
INSERT INTO @PetList(petName, ownerName, ownerEmail)
SELECT p.Name, CONCAT_WS(' ', f.FirstName, f.LastName), COALESCE(f.Email, 'No email available')
FROM dbo.Pet AS p 
    INNER JOIN dbo.Friend AS f ON p.OwnerId = f.FriendId;

--see what we got
SELECT * FROM @PetList;

--No need to delete as the variable gets out of scope

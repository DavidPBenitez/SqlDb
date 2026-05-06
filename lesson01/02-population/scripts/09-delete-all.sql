USE friends;
GO

--delete existing data to avoid primary key conflicts
DELETE FROM dbo.Pet;
DELETE FROM dbo.Friend;
DELETE FROM dbo.Address;
DELETE FROM dbo.FriendQuote;
DELETE FROM dbo.Quote;

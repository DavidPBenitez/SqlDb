USE friends;
GO


--Get full detail of a friend in XML
-- Using / in column aliases creates nested XML elements in FOR XML PATH:
--   "Address/Country" nests <Country> inside <Address>
--   "Pet/Name" nests the value inside <Pet>
SELECT f.FriendId "FriendId", f.FirstName "FirstName", f.LastName "LastName", 
    a.Country "Country", a.City "City",
    CONCAT_WS(' ', p.Name, 'the happy', p.AnimalKind) "Name"
FROM dbo.friend f
INNER JOIN dbo.Address a
ON f.AddressId = a.AddressId
INNER JOIN dbo.Pet p
ON f.FriendId = p.OwnerId
FOR XML PATH('Friend')


--Get full detail of a friend in XML
-- Using / in column aliases creates nested XML elements in FOR XML PATH:
--   "Address/Country" nests <Country> inside <Address>
--   "Pet/Name" nests the value inside <Pet>
SELECT f.FriendId "@FriendId", f.FirstName "FirstName", f.LastName "LastName", 
    a.Country "Address/Country", a.City "Address/City",
    CONCAT_WS(' ', p.Name, 'the happy', p.AnimalKind) "Pet/Name"
FROM dbo.friend f
INNER JOIN dbo.Address a
ON f.AddressId = a.AddressId
INNER JOIN dbo.Pet p
ON f.FriendId = p.OwnerId
FOR XML PATH('Friend')

--you can store it in an xml file using azure data studio. 
--I modified so it can be opened in Excel
--   1. Click on the result so it opens up in a new Azure tab
--   2. open xml-frame.xml and wrap the xml result in step 1 in the root tag 
--   2. save the tab as an xml file, friends2.xml. Make sure you do save as.. and select XML format


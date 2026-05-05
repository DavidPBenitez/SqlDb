USE friends;
GO

--Preparations
--insert a small and a large binary file into the table
--use openrowset to load a  xmlfile into a variable and then insert it into the table
--you need to have moved the xml-data file into the sql server docker container:
--   1. open a terminal in the directory of your xml files on the computer
--   2. create a directory in the docker container to store the xml files: 
--         docker exec -u root sql2022container mkdir /usr/xmlfiles
--   3. copy the xml file from your computer into the docker container: 
--         docker cp xml-data-example.xml sql2022container:/usr/xmlfiles/


--using SELECT INTO contruct and a temp table let's me avoid declaring a table separatly
SELECT
   -- @FriendId reads the FriendId XML attribute on the <Friend> element
   MY_XML.Friend.value('@FriendId', 'uniqueidentifier') AS FriendId,
   -- the rest of the columns read the value of the respective XML element inside <Friend>
   MY_XML.Friend.query('FirstName').value('.', 'NVARCHAR(200)') AS FirstName,
   MY_XML.Friend.query('LastName').value('.', 'NVARCHAR(200)') AS LastName,
   MY_XML.Friend.query('Country').value('.', 'NVARCHAR(200)') AS Country,
   MY_XML.Friend.query('Pet').value('.', 'NVARCHAR(200)') AS Pet
-- INTO materializes the result into a temp table, avoiding the need to declare the schema up front
INTO #fromXML
-- Subquery: CAST converts the raw blob returned by OPENROWSET into SQL Server's native xml type
FROM (SELECT CAST(MY_XML AS xml)
-- Docker container: reads the xml file as a single binary blob (SINGLE_BLOB) into MY_XML
 FROM OPENROWSET(BULK N'/usr/xmlfiles/xml-data-example.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)

-- SQL Server Express
--   FROM OPENROWSET(BULK N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\friends2.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)

-- CROSS APPLY nodes('Friend') shreds the XML: returns one row per <Friend> element in the document
CROSS APPLY MY_XML.nodes('Friend') AS MY_XML (Friend);

--depending on your xml you may need to remove som whitespace characters and new line characters
UPDATE #fromXML
SET FirstName = REPLACE (REPLACE(FirstName, NCHAR(9), ''), NCHAR(10), ''),
    LastName = REPLACE (REPLACE(LastName, NCHAR(9), ''), NCHAR(10), ''),
    Country = REPLACE (REPLACE(Country, NCHAR(9), ''), NCHAR(10), ''),
    Pet = REPLACE (REPLACE(Pet, NCHAR(9), ''), NCHAR(10), '')
    -- FriendId is an integer attribute, no whitespace cleanup needed

SELECT * FROM #fromXML;

DROP TABLE #fromXML;


--cleanup: remove the xml files from the docker container
--   1. open a terminal in the directory of your xml files on the computer
--   2. remove the xml files from the docker container:
--         docker exec -u root sql2022container rm -rf /usr/xmlfiles

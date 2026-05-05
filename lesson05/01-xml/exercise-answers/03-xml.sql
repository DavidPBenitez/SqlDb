USE music;
GO

-- ============================================================
-- Exercise 3 – Load data from an XML file
-- ============================================================

-- Preparations: copy the xml file into the Docker container
--   1. Open a terminal in the directory of your xml files on the computer
--   2. Create a directory in the Docker container:
--         docker exec -u root sql2022container mkdir /usr/xmlfiles
--   3. Copy the xml file from your computer into the Docker container:
--         docker cp xml-music-example.xml sql2022container:/usr/xmlfiles/

-- Load the XML file into a temp table using SELECT INTO
SELECT
    -- @AlbumId reads the AlbumId attribute on the <Album> element
    MY_XML.Album.value('@AlbumId', 'UNIQUEIDENTIFIER') AS AlbumId,
    -- .query('Name').value('.', ...) selects the <Name> child element and extracts its text
    MY_XML.Album.query('Name').value('.', 'NVARCHAR(200)') AS Name,
    MY_XML.Album.query('ReleaseYear').value('.', 'NVARCHAR(10)') AS ReleaseYear,
    MY_XML.Album.query('Genre').value('.', 'NVARCHAR(200)') AS Genre
-- SELECT INTO creates the temp table automatically from the result shape
INTO #fromXML
-- Subquery: CAST converts the raw blob from OPENROWSET into SQL Server's native xml type
FROM (SELECT CAST(MY_XML AS xml)
    -- OPENROWSET reads the xml file as a single binary blob (SINGLE_BLOB)
    FROM OPENROWSET(BULK N'/usr/xmlfiles/xml-music-example.xml', SINGLE_BLOB) AS T(MY_XML)) AS T(MY_XML)
-- CROSS APPLY nodes('Album') shreds the XML: one row per <Album> element
CROSS APPLY MY_XML.nodes('Album') AS MY_XML (Album);

-- Strip tab (NCHAR(9)) and newline (NCHAR(10)) characters left by the XML formatting
UPDATE #fromXML
SET Name        = REPLACE(REPLACE(Name,        NCHAR(9), ''), NCHAR(10), ''),
    ReleaseYear = REPLACE(REPLACE(ReleaseYear, NCHAR(9), ''), NCHAR(10), ''),
    Genre       = REPLACE(REPLACE(Genre,       NCHAR(9), ''), NCHAR(10), '');
    -- AlbumId is a UNIQUEIDENTIFIER attribute, no whitespace cleanup needed

SELECT * FROM #fromXML;

DROP TABLE #fromXML;

-- Cleanup: remove the xml files from the Docker container
--   1. Open a terminal
--   2. Remove the xml files:
--         docker exec -u root sql2022container rm -rf /usr/xmlfiles

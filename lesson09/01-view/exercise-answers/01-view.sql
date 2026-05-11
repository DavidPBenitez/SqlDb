USE music;
GO

-- ============================================================
-- Exercise 1: Create simple views
-- ============================================================

DROP VIEW IF EXISTS dbo.vw_album;
DROP VIEW IF EXISTS dbo.vw_artist;
GO

CREATE VIEW dbo.vw_album AS
    SELECT  a.AlbumId,
            a.Name          AS AlbumName,
            a.ReleaseYear,
            a.CopiesSold,
            a.MusicGroupId,
            mg.Name         AS GroupName,
            mg.Genre
    FROM dbo.Album        AS a
    INNER JOIN dbo.MusicGroup AS mg ON a.MusicGroupId = mg.MusicGroupId;
GO

CREATE VIEW dbo.vw_artist AS
    SELECT  ar.ArtistId,
            ar.FirstName,
            ar.LastName,
            mg.MusicGroupId,
            mg.Name         AS GroupName,
            mg.Genre
    FROM dbo.Artist           AS ar
    INNER JOIN dbo.ArtistMusicGroup AS amg ON ar.ArtistId     = amg.ArtistId
    INNER JOIN dbo.MusicGroup       AS mg  ON amg.MusicGroupId = mg.MusicGroupId;
GO

SELECT * FROM dbo.vw_album;
SELECT * FROM dbo.vw_artist;

-- ============================================================
-- Exercise 2: Create a view based on other views
-- ============================================================

DROP VIEW IF EXISTS dbo.vw_artist_discography;
GO

CREATE VIEW dbo.vw_artist_discography AS
    SELECT  va.ArtistId,
            va.FirstName,
            va.LastName,
            val.AlbumName,
            val.ReleaseYear,
            val.CopiesSold,
            va.GroupName,
            va.Genre
    FROM dbo.vw_artist AS va
    INNER JOIN dbo.vw_album AS val ON va.MusicGroupId = val.MusicGroupId;
GO

SELECT * FROM dbo.vw_artist_discography;

-- ============================================================
-- Exercise 3: Query views with aggregation and joins
-- ============================================================

-- Query 1: Total copies sold per artist
SELECT FirstName, LastName, SUM(CopiesSold) AS TotalCopiesSold
FROM dbo.vw_artist_discography
GROUP BY FirstName, LastName
ORDER BY TotalCopiesSold DESC;

-- Query 2: Number of albums and total copies sold per genre
SELECT Genre,
       COUNT(*)         AS NrAlbums,
       SUM(CopiesSold)  AS TotalCopiesSold
FROM dbo.vw_album
GROUP BY Genre
ORDER BY TotalCopiesSold DESC;

-- ============================================================
-- Exercise 4: Update through a view (single base table — works)
-- ============================================================

DROP TABLE IF EXISTS dbo.tmp_album;
DROP VIEW  IF EXISTS dbo.vwtmp_album;
GO

SELECT * INTO dbo.tmp_album FROM dbo.Album;
GO

CREATE VIEW dbo.vwtmp_album AS
    SELECT  AlbumId,
            Name        AS AlbumName,
            ReleaseYear,
            CopiesSold,
            MusicGroupId
    FROM dbo.tmp_album;
GO

-- Verify view
SELECT * FROM dbo.vwtmp_album;

-- UPDATE through the view — targets a single base table (tmp_album)
UPDATE dbo.vwtmp_album
SET AlbumName = 'Back in Black (Remastered)'
WHERE AlbumName = 'Back in Black';

-- Verify update in the view and in the underlying table
SELECT * FROM dbo.vwtmp_album   WHERE AlbumName LIKE 'Back in Black%';
SELECT * FROM dbo.tmp_album     WHERE Name       LIKE 'Back in Black%';

-- ============================================================
-- Exercise 5: Update through a view (multi-table pitfall)
-- ============================================================

DROP TABLE IF EXISTS dbo.tmp_music_group;
DROP VIEW  IF EXISTS dbo.vwtmp_album_group;
GO

SELECT * INTO dbo.tmp_music_group FROM dbo.MusicGroup;
GO

CREATE VIEW dbo.vwtmp_album_group AS
    SELECT  a.AlbumId,
            a.Name        AS AlbumName,
            a.ReleaseYear,
            a.CopiesSold,
            a.MusicGroupId,
            mg.Name       AS GroupName,
            mg.Genre
    FROM dbo.tmp_album        AS a
    INNER JOIN dbo.tmp_music_group AS mg ON a.MusicGroupId = mg.MusicGroupId;
GO

-- Verify view
SELECT * FROM dbo.vwtmp_album_group;

-- UPDATE Genre for Ride the Lightning through the multi-table view
UPDATE dbo.vwtmp_album_group
SET Genre = 'Rock'
WHERE AlbumName = 'Ride the Lightning';

-- Show the side-effect: ALL Metallica albums are now 'Rock'
-- because the update changed the row in tmp_music_group, not just this album
SELECT Genre, COUNT(*) AS NrGroups
FROM dbo.tmp_music_group
WHERE Genre IN ('Metal', 'Rock')
GROUP BY Genre;

SELECT Genre, COUNT(*) AS NrAlbums
FROM dbo.vwtmp_album_group
WHERE Genre IN ('Metal', 'Rock')
GROUP BY Genre;

-- ============================================================
-- Exercise 6: Delete through a multi-table view (error)
-- ============================================================

-- This DELETE will fail:
-- SQL Server cannot determine which base table's row to delete
-- when a view spans multiple tables.
DELETE FROM dbo.vwtmp_album_group
WHERE AlbumName = 'Back in Black (Remastered)';

-- ============================================================
-- Exercise 7: Insert through a multi-table view (error)
-- ============================================================

-- This INSERT will also fail for two reasons:
-- 1. The view spans multiple base tables — SQL Server cannot split
--    one INSERT into simultaneous inserts across tmp_album and tmp_music_group.
-- 2. Both base tables have columns not exposed by the view
--    (e.g. MusicGroupId in tmp_album, EstablishedYear and PK in tmp_music_group)
--    for which SQL Server cannot generate values.
INSERT INTO dbo.vwtmp_album_group (AlbumName, ReleaseYear, CopiesSold, GroupName, Genre)
VALUES ('Powerslave', 1984, 3000000, 'Iron Maiden', 'Metal');

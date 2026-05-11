USE music;
GO

-- ============================================================
-- Exercise 1: No transaction — no way back
-- ============================================================

DROP TABLE IF EXISTS dbo.tmp_album;
SELECT * INTO dbo.tmp_album FROM dbo.Album;

-- Verify data before the accident
SELECT TOP 5 Name, CopiesSold FROM dbo.tmp_album;

-- Accidental UPDATE — forgot the WHERE clause
UPDATE dbo.tmp_album
SET CopiesSold = 0;

-- All CopiesSold values are now 0 — data is permanently lost
SELECT TOP 5 Name, CopiesSold FROM dbo.tmp_album;

-- ============================================================
-- Exercise 2: BEGIN TRAN / ROLLBACK TRAN
-- ============================================================

DROP TABLE IF EXISTS dbo.tmp_album;
SELECT * INTO dbo.tmp_album FROM dbo.Album;

-- Verify data before the accident
SELECT TOP 5 Name, CopiesSold FROM dbo.tmp_album;

BEGIN TRAN

-- Same accidental UPDATE — all rows, no WHERE
UPDATE dbo.tmp_album
SET CopiesSold = 0;

-- All CopiesSold values are 0 inside the transaction
SELECT TOP 5 Name, CopiesSold FROM dbo.tmp_album;

-- Realise the mistake — roll everything back
ROLLBACK TRAN;

-- Original values restored
SELECT TOP 5 Name, CopiesSold FROM dbo.tmp_album;
GO

-- ============================================================
-- Exercise 3: SAVE TRANSACTION and partial rollback
-- ============================================================

DROP TABLE IF EXISTS dbo.tmp_album;
DROP TABLE IF EXISTS dbo.tmp_music_group;
DROP VIEW  IF EXISTS dbo.vwtmp_album_group;

SELECT * INTO dbo.tmp_album       FROM dbo.Album;
SELECT * INTO dbo.tmp_music_group FROM dbo.MusicGroup;
GO

CREATE VIEW dbo.vwtmp_album_group AS
    SELECT  a.AlbumId,
            a.Name          AS AlbumName,
            a.ReleaseYear,
            a.CopiesSold,
            a.MusicGroupId,
            mg.Name         AS GroupName,
            mg.Genre
    FROM dbo.tmp_album        AS a
    INNER JOIN dbo.tmp_music_group AS mg ON a.MusicGroupId = mg.MusicGroupId;
GO

-- Verify the view
SELECT * FROM dbo.vwtmp_album_group;

BEGIN TRAN

-- Update 1: rename 'The Black Album' directly on tmp_album (single-table — safe)
UPDATE dbo.tmp_album
SET Name = 'Metallica (The Black Album)'
WHERE Name = 'The Black Album';

SELECT Name, CopiesSold FROM dbo.tmp_album WHERE Name LIKE '%Black Album%';

-- Mark savepoint after the rename
SAVE TRANSACTION AlbumRenamed;

-- Update 2: change Genre through the multi-table view
-- This updates tmp_music_group, affecting ALL Metallica albums
UPDATE dbo.vwtmp_album_group
SET Genre = 'Rock'
WHERE AlbumName = 'Ride the Lightning';

-- All Metallica albums now show Genre = 'Rock' — unintended side-effect
SELECT AlbumName, Genre FROM dbo.vwtmp_album_group WHERE GroupName = 'Metallica';
SELECT Name, Genre FROM dbo.tmp_music_group WHERE Name = 'Metallica';

-- Mark savepoint after the genre change
SAVE TRANSACTION GenreUpdated;

-- Roll back only to AlbumRenamed — this undoes the Genre change but keeps the rename
ROLLBACK TRANSACTION AlbumRenamed;

-- Rename is still in place
SELECT Name FROM dbo.tmp_album WHERE Name LIKE '%Black Album%';
-- Genre is back to 'Metal'
SELECT Name, Genre FROM dbo.tmp_music_group WHERE Name = 'Metallica';
SELECT AlbumName, Genre FROM dbo.vwtmp_album_group WHERE GroupName = 'Metallica';

-- Commit — only the rename persists
COMMIT TRAN;

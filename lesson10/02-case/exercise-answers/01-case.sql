USE music;
GO

-- ============================================================
-- Exercise 1: Simple and Searched CASE
-- ============================================================

-- Query 1: Simple CASE — map Genre to a Scene label
SELECT mg.Name AS GroupName,
       mg.Genre,
       CASE mg.Genre
           WHEN 'Rock'  THEN 'Guitar-driven rock'
           WHEN 'Metal' THEN 'Heavy metal'
           WHEN 'Blues' THEN 'Soulful blues'
           WHEN 'Jazz'  THEN 'Improvisational jazz'
           ELSE 'Unknown scene'
       END AS Scene
FROM dbo.MusicGroup AS mg
ORDER BY mg.Genre;

-- Query 2: Searched CASE — classify albums by CopiesSold tier
SELECT a.Name        AS AlbumName,
       a.ReleaseYear,
       a.CopiesSold,
       CASE
           WHEN a.CopiesSold >= 20000000 THEN 'Diamond'
           WHEN a.CopiesSold >= 10000000 THEN 'Platinum'
           WHEN a.CopiesSold >=  5000000 THEN 'Gold'
           WHEN a.CopiesSold >=  1000000 THEN 'Silver'
           ELSE 'Bronze'
       END AS CommercialTier
FROM dbo.Album AS a
ORDER BY a.CopiesSold DESC;

-- ============================================================
-- Exercise 2: CASE to transform rows into columns (pivot)
-- ============================================================

-- Step 1: Regular aggregation — albums per decade
SELECT (ReleaseYear / 10) * 10 AS Decade,
       COUNT(*)                 AS NrAlbums
FROM dbo.Album
GROUP BY (ReleaseYear / 10) * 10
ORDER BY Decade;

-- Step 2: Pivot using SUM(CASE …) — one column per decade
SELECT
    SUM(CASE WHEN ReleaseYear >= 1950 AND ReleaseYear < 1960 THEN 1 ELSE 0 END) AS Albums_1950s,
    SUM(CASE WHEN ReleaseYear >= 1960 AND ReleaseYear < 1970 THEN 1 ELSE 0 END) AS Albums_1960s,
    SUM(CASE WHEN ReleaseYear >= 1970 AND ReleaseYear < 1980 THEN 1 ELSE 0 END) AS Albums_1970s,
    SUM(CASE WHEN ReleaseYear >= 1980 AND ReleaseYear < 1990 THEN 1 ELSE 0 END) AS Albums_1980s,
    SUM(CASE WHEN ReleaseYear >= 1990 AND ReleaseYear < 2000 THEN 1 ELSE 0 END) AS Albums_1990s
FROM dbo.Album;

-- ============================================================
-- Exercise 3: CASE with a subquery (existence / count check)
-- ============================================================

SELECT mg.Name           AS GroupName,
       mg.EstablishedYear,
       CASE (SELECT COUNT(*) FROM dbo.Album a WHERE a.MusicGroupId = mg.MusicGroupId)
           WHEN 0 THEN 'No albums'
           WHEN 1 THEN 'Single album'
           WHEN 2 THEN 'Small catalog'
           WHEN 3 THEN 'Mid-size catalog'
           ELSE       'Rich catalog'
       END AS CatalogSize
FROM dbo.MusicGroup AS mg
ORDER BY mg.EstablishedYear;

-- ============================================================
-- Exercise 4: CASE in an UPDATE with EXISTS
-- ============================================================

DROP TABLE IF EXISTS dbo.tmp_album;
SELECT * INTO dbo.tmp_album FROM dbo.Album;

-- Verify: non-flagship albums (another album from same group sold more)
SELECT Name, CopiesSold
FROM dbo.tmp_album AS ta
WHERE EXISTS (
    SELECT 1 FROM dbo.tmp_album AS other
    WHERE other.MusicGroupId = ta.MusicGroupId
      AND other.CopiesSold   > ta.CopiesSold);

BEGIN TRAN

-- UPDATE: boost non-flagship albums by 500 000 copies
UPDATE dbo.tmp_album
SET CopiesSold =
    CASE
        WHEN EXISTS (
            SELECT 1 FROM dbo.tmp_album AS other
            WHERE other.MusicGroupId = dbo.tmp_album.MusicGroupId
              AND other.CopiesSold   > dbo.tmp_album.CopiesSold)
        THEN CopiesSold + 500000
        ELSE CopiesSold
    END;

-- Verify: compare tmp_album to original Album
SELECT ta.Name AS AlbumName,
       orig.CopiesSold AS OriginalCopiesSold,
       ta.CopiesSold   AS UpdatedCopiesSold,
       ta.CopiesSold - orig.CopiesSold AS Difference
FROM dbo.tmp_album AS ta
INNER JOIN dbo.Album AS orig ON ta.AlbumId = orig.AlbumId
ORDER BY Difference DESC;

ROLLBACK TRAN;

-- Confirm values are restored
SELECT ta.Name, ta.CopiesSold, orig.CopiesSold AS OriginalCopiesSold
FROM dbo.tmp_album AS ta
INNER JOIN dbo.Album AS orig ON ta.AlbumId = orig.AlbumId
ORDER BY ta.CopiesSold DESC;

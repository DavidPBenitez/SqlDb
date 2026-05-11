USE music;
GO

-- Exercise 1: Single CTE
-- CTE filters Album rows that belong to a Rock music group

;WITH rock_albums AS
    (SELECT a.AlbumId, a.Name, a.ReleaseYear, a.CopiesSold, a.MusicGroupId
     FROM dbo.Album AS a
     INNER JOIN dbo.MusicGroup AS mg ON a.MusicGroupId = mg.MusicGroupId
     WHERE mg.Genre = 'Rock')

SELECT mg.Name       AS GroupName,
       ra.Name       AS AlbumName,
       ra.ReleaseYear,
       ra.CopiesSold
FROM rock_albums AS ra
INNER JOIN dbo.MusicGroup AS mg ON ra.MusicGroupId = mg.MusicGroupId
ORDER BY ra.CopiesSold DESC;

-- ============================================================

-- Exercise 2: Multiple chained CTEs
-- Step 1 – build and verify b_artists on its own, then extend

;WITH j_artists AS
    (SELECT ArtistId, FirstName, LastName
     FROM dbo.Artist
     WHERE LastName LIKE 'J%')

,
j_artists_rock_groups AS
    (SELECT ja.ArtistId, ja.FirstName, ja.LastName,
            mg.MusicGroupId, mg.Name AS GroupName
     FROM j_artists AS ja
     INNER JOIN dbo.ArtistMusicGroup AS amg ON ja.ArtistId    = amg.ArtistId
     INNER JOIN dbo.MusicGroup       AS mg  ON amg.MusicGroupId = mg.MusicGroupId
     WHERE mg.Genre = 'Rock')

,
j_artists_rock_albums AS
    (SELECT jarg.ArtistId, jarg.FirstName, jarg.LastName,
            jarg.GroupName, al.CopiesSold
     FROM j_artists_rock_groups AS jarg
     INNER JOIN dbo.Album AS al ON al.MusicGroupId = jarg.MusicGroupId)

SELECT FirstName,
       LastName,
       SUM(CopiesSold) AS TotalCopiesSold
FROM j_artists_rock_albums
GROUP BY FirstName, LastName
ORDER BY TotalCopiesSold DESC;

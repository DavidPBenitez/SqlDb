USE music;
GO

-- ============================================================
-- Exercise 1: IF...ELSE
-- ============================================================

DECLARE @AlbumCount INT;

-- Block 1: variable + compound condition
SELECT @AlbumCount = COUNT(*) FROM dbo.Album;

IF @AlbumCount >= 10 AND DATENAME(WEEKDAY, GETDATE()) = 'Sunday'
BEGIN
    PRINT 'Album count is 10 or more.';
    PRINT 'Today is Sunday.';
END
ELSE BEGIN
    PRINT 'Either the album count is less than 10, or today is not Sunday.';
    PRINT 'Actually today is a ' + DATENAME(WEEKDAY, GETDATE());
END;

-- Block 2: IF with a subquery
IF EXISTS (SELECT 1 FROM dbo.Album WHERE CopiesSold > 40000000)
BEGIN
    PRINT 'At least one album has sold more than 40 million copies.';
END
ELSE BEGIN
    PRINT 'No album has sold more than 40 million copies.';
END;

-- Block 3: IF with a CTE
;WITH multi_genre_artists AS
    (SELECT ArtistId
     FROM dbo.ArtistMusicGroup
     GROUP BY ArtistId
     HAVING COUNT(*) > 1)
SELECT @AlbumCount = COUNT(*) FROM multi_genre_artists;

IF @AlbumCount > 0
BEGIN
    PRINT 'You have ' + CAST(@AlbumCount AS NVARCHAR) + ' artist(s) who belong to more than one group.';
END
ELSE BEGIN
    PRINT 'All artists belong to exactly one group.';
END;

-- ============================================================
-- Exercise 2: Simple WHILE loop with BREAK and CONTINUE
-- ============================================================

DECLARE @Counter INT = 1;

-- Loop 1: simple counter 1 to 5
PRINT '';
PRINT 'Loop 1 — simple counter:';
WHILE @Counter <= 5 BEGIN
    PRINT @Counter;
    SET @Counter += 1;
END;

-- Loop 2: BREAK when counter reaches 7
PRINT '';
PRINT 'Loop 2 — BREAK at 7:';
SET @Counter = 1;
WHILE @Counter <= 100 BEGIN
    PRINT @Counter;
    IF @Counter = 7 BEGIN
        PRINT 'Reached 7 — exiting loop';
        BREAK;
    END;
    SET @Counter += 1;
END;

-- Loop 3: CONTINUE at 4
PRINT '';
PRINT 'Loop 3 — CONTINUE at 4:';
SET @Counter = 1;
WHILE @Counter <= 8 BEGIN
    PRINT @Counter;
    SET @Counter += 1;
    IF @Counter = 4 BEGIN
        PRINT 'Skipping to next iteration';
        CONTINUE;
    END;
END;

-- ============================================================
-- Exercise 3: WHILE loop — row-by-row processing
-- ============================================================

DROP TABLE IF EXISTS #tmp_group_processing;
GO

CREATE TABLE #tmp_group_processing (
    row_id         INT IDENTITY(1,1) NOT NULL,
    music_group_id UNIQUEIDENTIFIER,
    group_name     NVARCHAR(100),
    genre          NVARCHAR(50),
    Processed      BIT NOT NULL
);
GO

INSERT INTO #tmp_group_processing (music_group_id, group_name, genre, Processed)
SELECT MusicGroupId, Name, Genre, 0 FROM dbo.MusicGroup;

DECLARE @row_id     INT = 1;
DECLARE @group_name NVARCHAR(100);
DECLARE @genre      NVARCHAR(50);
DECLARE @album_count INT;

WHILE EXISTS (SELECT * FROM #tmp_group_processing WHERE Processed = 0) BEGIN

    SELECT @group_name = group_name,
           @genre      = genre
    FROM #tmp_group_processing
    WHERE row_id = @row_id;

    SELECT @album_count = COUNT(*)
    FROM dbo.Album
    WHERE MusicGroupId = (
        SELECT music_group_id FROM #tmp_group_processing WHERE row_id = @row_id);

    PRINT 'Processing: ' + @group_name + ' [' + @genre + '] — '
          + CAST(@album_count AS NVARCHAR) + ' album(s)';

    UPDATE #tmp_group_processing SET Processed = 1 WHERE row_id = @row_id;

    SET @row_id += 1;
END;

PRINT 'All groups processed.';

-- ============================================================
-- Exercise 4: Cursor
-- ============================================================

DECLARE @artist_name NVARCHAR(200);
DECLARE @group_name2 NVARCHAR(100);

DECLARE artist_cursor CURSOR FAST_FORWARD
FOR
    SELECT CONCAT_WS(' ', ar.FirstName, ar.LastName),
           mg.Name
    FROM dbo.Artist           AS ar
    INNER JOIN dbo.ArtistMusicGroup AS amg ON ar.ArtistId     = amg.ArtistId
    INNER JOIN dbo.MusicGroup       AS mg  ON amg.MusicGroupId = mg.MusicGroupId
    ORDER BY ar.LastName;

OPEN artist_cursor;

FETCH NEXT FROM artist_cursor INTO @artist_name, @group_name2;

WHILE @@FETCH_STATUS = 0 BEGIN

    PRINT 'Artist: ' + @artist_name + ' — Group: ' + @group_name2;

    FETCH NEXT FROM artist_cursor INTO @artist_name, @group_name2;
END;

CLOSE artist_cursor;
DEALLOCATE artist_cursor;

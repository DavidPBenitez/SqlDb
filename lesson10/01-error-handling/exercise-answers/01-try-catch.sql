USE music;
GO

-- ============================================================
-- Exercise 1: Basic TRY...CATCH and error functions
-- ============================================================

-- Block 1: divide-by-zero
BEGIN TRY
    PRINT 100 / 0;
END TRY
BEGIN CATCH
    PRINT ERROR_NUMBER();
    PRINT ERROR_MESSAGE();
    PRINT ERROR_LINE();
    PRINT ERROR_SEVERITY();
END CATCH;

PRINT 'Execution continues after the CATCH block';

-- Block 2: drop a table that does not exist
BEGIN TRY
    DROP TABLE dbo.NonExistingTable;
END TRY
BEGIN CATCH
    PRINT ERROR_NUMBER();
    PRINT ERROR_MESSAGE();
    PRINT ERROR_LINE();
    PRINT ERROR_SEVERITY();
END CATCH;

PRINT 'Execution continues after the CATCH block';

-- ============================================================
-- Exercise 2: TRY...CATCH with a transaction and ROLLBACK
-- ============================================================

DROP TABLE IF EXISTS dbo.tmp_album;
SELECT * INTO dbo.tmp_album FROM dbo.Album;

-- Verify the row before the attempted update
SELECT Name, MusicGroupId FROM dbo.tmp_album WHERE Name = 'Back in Black';

BEGIN TRY
    BEGIN TRAN

        -- This UPDATE violates the FK constraint on MusicGroupId
        UPDATE dbo.tmp_album
        SET MusicGroupId = '00000000-0000-0000-0000-000000000000'
        WHERE Name = 'Back in Black';

    COMMIT;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
    PRINT 'Rolling back transaction';
    IF @@TRANCOUNT > 0 BEGIN
        ROLLBACK;
    END;
END CATCH;

-- Confirm the row is unchanged — original MusicGroupId still intact
SELECT Name, MusicGroupId FROM dbo.tmp_album WHERE Name = 'Back in Black';

-- ============================================================
-- Exercise 3: Error logging table and THROW
-- ============================================================

DROP TABLE IF EXISTS dbo.ErrorLog;
CREATE TABLE dbo.ErrorLog (
    err_nr   INT,
    err_msg  NVARCHAR(400),
    err_line INT,
    err_sev  INT
);
GO

BEGIN TRY
    -- FK violation: MusicGroupId does not exist in dbo.MusicGroup
    INSERT INTO dbo.Album (AlbumId, Name, ReleaseYear, CopiesSold, MusicGroupId)
    VALUES (NEWID(), 'Ghost Album', 2024, 0, '00000000-0000-0000-0000-000000000000');
END TRY
BEGIN CATCH
    -- Log the error details
    INSERT INTO dbo.ErrorLog (err_nr, err_msg, err_line, err_sev)
    VALUES (ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_LINE(), ERROR_SEVERITY());

    -- Re-raise a user-friendly custom error
    ;THROW 999999, 'Error inserting into dbo.Album — invalid MusicGroupId', 1;
END CATCH;
GO

-- Confirm the error was logged
SELECT * FROM dbo.ErrorLog;

-- Confirm no 'Ghost Album' row was inserted
SELECT * FROM dbo.Album WHERE Name = 'Ghost Album';

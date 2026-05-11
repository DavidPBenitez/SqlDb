# Lesson 10 – Exercises: TRY…CATCH Error Handling

Use the `music` database for all exercises.

The exercises use the following tables:

**MusicGroup**

| Column | Type | Description |
|---|---|---|
| `MusicGroupId` | `uniqueidentifier` | Primary key |
| `Name` | `varchar` | Group name |
| `EstablishedYear` | `int` | Year the group was formed |
| `Genre` | `varchar` | `'Rock'`, `'Blues'`, `'Jazz'`, `'Metal'` |

**Album**

| Column | Type | Description |
|---|---|---|
| `AlbumId` | `uniqueidentifier` | Primary key |
| `Name` | `varchar` | Album title |
| `ReleaseYear` | `int` | Year the album was released |
| `CopiesSold` | `bigint` | Total copies sold |
| `MusicGroupId` | `uniqueidentifier` | Foreign key to `MusicGroup` |

**Artist**

| Column | Type | Description |
|---|---|---|
| `ArtistId` | `uniqueidentifier` | Primary key |
| `FirstName` | `varchar` | Artist's first name |
| `LastName` | `varchar` | Artist's last name |
| `BirthDay` | `datetime` | Date of birth — **nullable** |

**ArtistMusicGroup** *(join table)*

| Column | Type | Description |
|---|---|---|
| `ArtistId` | `uniqueidentifier` | Foreign key to `Artist` |
| `MusicGroupId` | `uniqueidentifier` | Foreign key to `MusicGroup` |

---

## Exercise 1 – Basic TRY…CATCH and Error Functions

**Task:** Use `TRY…CATCH` to gracefully handle two different runtime errors and inspect the error information functions.

**Block 1 — arithmetic error:**

Inside a `BEGIN TRY … END TRY` / `BEGIN CATCH … END CATCH`, execute a statement that causes a **divide-by-zero** error:

```sql
PRINT 100 / 0;
```

In the `CATCH` block, print all four error information functions:
- `ERROR_NUMBER()`
- `ERROR_MESSAGE()`
- `ERROR_LINE()`
- `ERROR_SEVERITY()`

After the block, print `'Execution continues after the CATCH block'` to show that execution is not interrupted.

**Block 2 — object not found:**

In a second, independent `TRY…CATCH`, attempt to drop a table that does not exist:

```sql
DROP TABLE dbo.NonExistingTable;
```

Again print all four error functions in the `CATCH` block, followed by `'Execution continues after the CATCH block'` outside.

**Hint:** Each `BEGIN TRY … END TRY BEGIN CATCH … END CATCH` is an independent block. An error inside `TRY` jumps immediately to `CATCH` — statements after the error inside `TRY` are skipped. Execution resumes normally after `END CATCH`.

**Expected outcome:** Both blocks print the error details to the Messages window and then continue to the statement after `END CATCH`. No unhandled error is raised.

**Answer:** [01-try-catch.sql](../exercise-answers/01-try-catch.sql)

---

## Exercise 2 – TRY…CATCH with a Transaction and ROLLBACK

**Task:** Combine `TRY…CATCH` with `BEGIN TRAN` / `COMMIT` / `ROLLBACK` to protect a data-modification statement.

Follow these steps:

1. Create a working copy of the `Album` table:
   ```sql
   SELECT * INTO dbo.tmp_album FROM dbo.Album;
   ```
2. Inside a `BEGIN TRY … END TRY`, open a transaction with `BEGIN TRAN`, then attempt an **invalid UPDATE** that tries to set `MusicGroupId` to a value that does not exist as a primary key in `dbo.MusicGroup` (this violates the foreign key constraint):
   ```sql
   UPDATE dbo.tmp_album
   SET MusicGroupId = '00000000-0000-0000-0000-000000000000'
   WHERE Name = 'Back in Black';
   ```
   If no error occurs, issue `COMMIT`.
3. In the `BEGIN CATCH … END CATCH` block:
   - Print `ERROR_MESSAGE()`.
   - Print `'Rolling back transaction'`.
   - Check `@@TRANCOUNT > 0` before issuing `ROLLBACK` to avoid a "no transaction" error.
4. After the `TRY…CATCH`, query `dbo.tmp_album` for the `'Back in Black'` row to confirm the original `MusicGroupId` is intact.

**Hint:** `@@TRANCOUNT` is greater than zero whenever an open transaction exists. Always check it before calling `ROLLBACK` inside a `CATCH` block — the transaction may have already been terminated by a severe error. `tmp_album` is a copy so no actual `Album` data is harmed.

**Expected outcome:** The `UPDATE` fails, the `CATCH` block fires and rolls back the transaction. The `'Back in Black'` row retains its original `MusicGroupId`.

**Answer:** [01-try-catch.sql](../exercise-answers/01-try-catch.sql)

---

## Exercise 3 – Error Logging Table and THROW

**Task:** Build a reusable error-handling pattern: log the error details to a dedicated table, then re-raise a custom, user-friendly error with `THROW`.

Follow these steps:

1. Create an error log table:
   ```sql
   DROP TABLE IF EXISTS dbo.ErrorLog;
   CREATE TABLE dbo.ErrorLog (
       err_nr   INT,
       err_msg  NVARCHAR(400),
       err_line INT,
       err_sev  INT
   );
   ```
2. Inside a `BEGIN TRY … END TRY`, attempt to insert a row into `dbo.Album` with a `MusicGroupId` that does not exist in `dbo.MusicGroup` — this will violate the foreign key constraint:
   ```sql
   INSERT INTO dbo.Album (AlbumId, Name, ReleaseYear, CopiesSold, MusicGroupId)
   VALUES (NEWID(), 'Ghost Album', 2024, 0, '00000000-0000-0000-0000-000000000000');
   ```
3. In the `BEGIN CATCH … END CATCH` block:
   - Insert a row into `dbo.ErrorLog` using `ERROR_NUMBER()`, `ERROR_MESSAGE()`, `ERROR_LINE()`, and `ERROR_SEVERITY()`.
   - Re-raise a custom error with `THROW`:
     ```sql
     ;THROW 999999, 'Error inserting into dbo.Album — invalid MusicGroupId', 1;
     ```
4. After the block, query `dbo.ErrorLog` to confirm the error was captured. Also confirm that no row was inserted into `dbo.Album` by querying for `Name = 'Ghost Album'`.

**Hint:** `THROW` with three arguments raises a **new** error. Using `;THROW` (no arguments) inside a `CATCH` re-raises the **original** error. The semicolon before `THROW` is a safety delimiter — good practice to include it. The error number for user-defined `THROW` must be **≥ 50000** … or use 999999 as shown.

**Expected outcome:** `dbo.ErrorLog` contains one row with the FK violation details. `dbo.Album` has no `'Ghost Album'` row. The custom `THROW` raises a descriptive error visible in the Messages window.

**Answer:** [01-try-catch.sql](../exercise-answers/01-try-catch.sql)

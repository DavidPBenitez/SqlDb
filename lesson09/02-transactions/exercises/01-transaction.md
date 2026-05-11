# Lesson 09 – Exercises: Transactions

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

---

## Exercise 1 – The Problem: No Transaction, No Way Back

**Task:** Demonstrate the danger of running a destructive `UPDATE` **without** a transaction.

Follow these steps:

1. Create a working copy of the `Album` table:
   ```sql
   SELECT * INTO dbo.tmp_album FROM dbo.Album;
   ```
2. Verify the copy by selecting the top 5 rows from `dbo.tmp_album` — note the album names.
3. Now simulate an accidental `UPDATE` that **forgets the `WHERE` clause** — set `CopiesSold = 0` for every row in `dbo.tmp_album`.
4. Query the top 5 rows again and observe the damage.

There is **no way to undo** this change — the data is gone.

**Hint:** This exercise has no "fix" — its purpose is to demonstrate *why* transactions matter. The next exercise shows the remedy.

**Expected outcome:** All rows in `dbo.tmp_album` now show `CopiesSold = 0`. The original values are permanently lost.

**Answer:** [01-transaction.sql](../exercise-answers/01-transaction.sql)

---

## Exercise 2 – BEGIN TRAN / ROLLBACK TRAN

**Task:** Repeat the same dangerous `UPDATE` from Exercise 1, but this time **wrap it in a transaction** so it can be rolled back safely.

Follow these steps:

1. Drop and re-create the working copy of `Album`:
   ```sql
   DROP TABLE IF EXISTS dbo.tmp_album;
   SELECT * INTO dbo.tmp_album FROM dbo.Album;
   ```
2. Verify by selecting the top 5 rows — note the `CopiesSold` values.
3. Open a transaction with `BEGIN TRAN`.
4. Run the same accidental `UPDATE` — set `CopiesSold = 0` for **all** rows (no `WHERE` clause).
5. Select the top 5 rows inside the transaction — confirm all values are `0`.
6. Realise the mistake and issue `ROLLBACK TRAN`.
7. Select the top 5 rows again — confirm the original `CopiesSold` values have been restored.

**Hint:** Until `COMMIT` or `ROLLBACK` is issued, the transaction holds a lock and the change is visible only within the same session. `ROLLBACK TRAN` undoes **everything** since `BEGIN TRAN`.

**Expected outcome:** After the rollback, `dbo.tmp_album` contains the original `CopiesSold` values exactly as they were before the `UPDATE`.

**Answer:** [01-transaction.sql](../exercise-answers/01-transaction.sql)

---

## Exercise 3 – SAVE TRANSACTION and Partial Rollback

**Task:** Use **savepoints** to perform two sequential updates within a single transaction, roll back only the second one, and commit the first.

Follow these steps:

1. Clean up and create fresh working copies:
   ```sql
   DROP TABLE IF EXISTS dbo.tmp_album;
   DROP TABLE IF EXISTS dbo.tmp_music_group;
   DROP VIEW  IF EXISTS dbo.vwtmp_album_group;
   SELECT * INTO dbo.tmp_album       FROM dbo.Album;
   SELECT * INTO dbo.tmp_music_group FROM dbo.MusicGroup;
   ```
2. Create a view `dbo.vwtmp_album_group` joining `dbo.tmp_album` to `dbo.tmp_music_group` on `MusicGroupId`, exposing `AlbumId`, `Name` (aliased `AlbumName`), `ReleaseYear`, `CopiesSold`, `MusicGroupId`, `Name` (aliased `GroupName`), and `Genre`.
3. Verify the view with a `SELECT *`.
4. Open a transaction with `BEGIN TRAN`.
5. **Update 1 — targeted change:** Update the album named `'The Black Album'` and set its `Name` to `'Metallica (The Black Album)'` directly on `dbo.tmp_album` (single-table update — safe). Verify the change. Set a savepoint named `AlbumRenamed`.
6. **Update 2 — dangerous change:** Through `dbo.vwtmp_album_group`, update `Genre` to `'Rock'` where `AlbumName = 'Ride the Lightning'`. Verify — notice that **all Metallica albums** now show `Genre = 'Rock'` (the side-effect of updating through a multi-table view). Set a savepoint named `GenreUpdated`.
7. Roll back **only to `AlbumRenamed`** using `ROLLBACK TRANSACTION AlbumRenamed`.
8. Verify that:
   - The album rename from step 5 is **still in place** (savepoint rollback only undoes changes *after* the savepoint).
   - The genre change from step 6 has been **reversed** — Metallica is `'Metal'` again.
9. Commit the transaction with `COMMIT TRAN`.

**Hint:** `SAVE TRANSACTION <name>` marks a point you can return to. `ROLLBACK TRANSACTION <name>` undoes everything **after** that savepoint but keeps everything **before** it. The transaction remains open after a savepoint rollback — you must still `COMMIT` or `ROLLBACK` fully.

**Expected outcome:** After the commit, `tmp_album` shows the renamed Black Album. `tmp_music_group` still shows Metallica as `'Metal'`. Only the rename persists.

**Answer:** [01-transaction.sql](../exercise-answers/01-transaction.sql)

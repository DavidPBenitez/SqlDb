# Lesson 09 – Exercises: Views

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

## Exercise 1 – Create Simple Views

**Task:** Create **two views** that flatten multi-table joins so they can be queried as simple tables.

**View 1 — `dbo.vw_album`**

Create a view named `dbo.vw_album` that joins `dbo.Album` to `dbo.MusicGroup` and exposes the following columns:

| Alias | Source |
|---|---|
| `AlbumId` | `Album.AlbumId` |
| `AlbumName` | `Album.Name` |
| `ReleaseYear` | `Album.ReleaseYear` |
| `CopiesSold` | `Album.CopiesSold` |
| `MusicGroupId` | `Album.MusicGroupId` |
| `GroupName` | `MusicGroup.Name` |
| `Genre` | `MusicGroup.Genre` |

After creating it, write a `SELECT * FROM dbo.vw_album` to verify all rows are returned.

**View 2 — `dbo.vw_artist`**

Create a view named `dbo.vw_artist` that joins `dbo.Artist` → `dbo.ArtistMusicGroup` → `dbo.MusicGroup` and exposes:

| Alias | Source |
|---|---|
| `ArtistId` | `Artist.ArtistId` |
| `FirstName` | `Artist.FirstName` |
| `LastName` | `Artist.LastName` |
| `MusicGroupId` | `MusicGroup.MusicGroupId` |
| `GroupName` | `MusicGroup.Name` |
| `Genre` | `MusicGroup.Genre` |

After creating it, write a `SELECT * FROM dbo.vw_artist` to verify all rows are returned.

**Hint:** Use `DROP VIEW IF EXISTS` before each `CREATE VIEW`. Alias each column in the `SELECT` inside the view body. Remember that a `VIEW` definition cannot contain an `ORDER BY`.

**Expected outcome:** `vw_album` returns one row per album (15 rows). `vw_artist` returns one row per artist–group membership (16 rows).

**Answer:** [01-view.sql](../exercise-answers/01-view.sql)

---

## Exercise 2 – Create a View Based on Other Views

**Task:** Create a view named `dbo.vw_artist_discography` that **joins the two views** created in Exercise 1.

Join `dbo.vw_artist` to `dbo.vw_album` on `MusicGroupId` and expose:

- `ArtistId`, `FirstName`, `LastName` (from `vw_artist`)
- `AlbumName`, `ReleaseYear`, `CopiesSold` (from `vw_album`)
- `GroupName`, `Genre` (from either view — they are the same)

After creating it, write a `SELECT * FROM dbo.vw_artist_discography` to verify the result.

**Hint:** Views can be used exactly like tables. Use `DROP VIEW IF EXISTS` first. `vw_artist_discography` must be dropped and re-created whenever the views it depends on are changed.

**Expected outcome:** One row per artist–album combination — every album in the catalog appears once per artist in the corresponding group.

**Answer:** [01-view.sql](../exercise-answers/01-view.sql)

---

## Exercise 3 – Query Views with Aggregation and Joins

**Task:** Write **two queries** that use the views from Exercises 1 and 2 to answer analytical questions — treating views just like tables.

**Query 1:** Using `dbo.vw_artist_discography`, calculate the **total copies sold per artist**. Return `FirstName`, `LastName`, and `TotalCopiesSold` (SUM of `CopiesSold`), grouped by artist and ordered by `TotalCopiesSold` descending.

**Query 2:** Using `dbo.vw_album` joined to `dbo.MusicGroup`, calculate the **number of albums and total copies sold per genre**. Return `Genre`, `NrAlbums` (COUNT), and `TotalCopiesSold` (SUM), ordered by `TotalCopiesSold` descending.

**Hint:** For Query 1, group by both `FirstName` and `LastName`. For Query 2, `vw_album` already has the `Genre` column — no further join is necessary.

**Expected outcome:**
- Query 1: one row per artist, ranked by total copies sold across all albums from their group(s).
- Query 2: one row per genre (Rock, Blues, Jazz, Metal) with album count and total copies sold.

**Answer:** [01-view.sql](../exercise-answers/01-view.sql)

---

## Exercise 4 – Update Data Through a View (Single Base Table)

**Task:** Demonstrate that you can safely **update data through a view** when the view targets a **single base table**.

Follow these steps:

1. Create a working copy of the `Album` table:
   ```sql
   SELECT * INTO dbo.tmp_album FROM dbo.Album;
   ```
2. Create a view `dbo.vwtmp_album` that selects `AlbumId`, `Name` (aliased `AlbumName`), `ReleaseYear`, `CopiesSold`, and `MusicGroupId` from `dbo.tmp_album` only — **no joins**.
3. Verify the view returns the expected rows with `SELECT * FROM dbo.vwtmp_album`.
4. Update the album named `'Back in Black'` through the view: change `AlbumName` to `'Back in Black (Remastered)'`.
5. Confirm the change by querying the view and then querying `dbo.tmp_album` directly.

**Hint:** An UPDATE through a view that spans only **one** base table works exactly like an UPDATE on the table itself — the view column alias maps back to the underlying column. Wrap the column alias in square brackets if it contains spaces.

**Expected outcome:** The row is updated successfully. Both the view and `dbo.tmp_album` show the new album name.

**Answer:** [01-view.sql](../exercise-answers/01-view.sql)

---

## Exercise 5 – Update Data Through a View (Multi-Table Pitfall)

**Task:** Explore the **side effects** of updating through a view that joins multiple base tables.

Continuing from Exercise 4, follow these steps:

1. Create a working copy of the `MusicGroup` table:
   ```sql
   SELECT * INTO dbo.tmp_music_group FROM dbo.MusicGroup;
   ```
2. Create a view `dbo.vwtmp_album_group` that joins `dbo.tmp_album` to `dbo.tmp_music_group` on `MusicGroupId`, exposing:
   - From `tmp_album`: `AlbumId`, `Name` (aliased `AlbumName`), `ReleaseYear`, `CopiesSold`, `MusicGroupId`
   - From `tmp_music_group`: `Name` (aliased `GroupName`), `Genre`
3. Verify the view with `SELECT * FROM dbo.vwtmp_album_group`.
4. Update the `Genre` for the album `'Ride the Lightning'` to `'Rock'` through the view.
5. Now query `dbo.tmp_music_group` to count how many groups still have `Genre = 'Metal'` vs `Genre = 'Rock'`.
6. Then count albums per genre using the view to understand the full impact.

**Hint:** When you update a column through a multi-table view, SQL Server updates the row in the **base table that owns that column** — in this case `tmp_music_group`. Since multiple albums share the same `MusicGroupId`, all Metallica albums now appear as `'Rock'`.

**Expected outcome:** The UPDATE succeeds but affects the entire `Metallica` row in `tmp_music_group`, so **all** Metallica albums (`Ride the Lightning`, `Master of Puppets`, `The Black Album`) now show `Genre = 'Rock'`.

**Answer:** [01-view.sql](../exercise-answers/01-view.sql)

---

## Exercise 6 – Delete Data Through a View (Multi-Table Error)

**Task:** Demonstrate that **deleting through a multi-table view** raises an error in SQL Server.

Using the `dbo.vwtmp_album_group` view created in Exercise 5, attempt to delete the row where `AlbumName = 'Back in Black (Remastered)'`.

Observe the error SQL Server returns. Then explain in a comment **why** the error occurs.

**Hint:** SQL Server cannot determine which base table's row to delete when a view joins multiple tables. A `DELETE` through a view is only allowed when the view references a **single base table**.

**Expected outcome:** SQL Server raises an error: *"View or function 'dbo.vwtmp_album_group' is not updatable because the modification affects multiple base tables."*

**Answer:** [01-view.sql](../exercise-answers/01-view.sql)

---

## Exercise 7 – Insert Data Through a View (Multi-Table Error)

**Task:** Demonstrate that **inserting through a multi-table view** also raises an error.

Using the `dbo.vwtmp_album_group` view, attempt to insert a new row:

| AlbumName | ReleaseYear | CopiesSold | GroupName | Genre |
|---|---|---|---|---|
| `'Powerslave'` | `1984` | `3000000` | `'Iron Maiden'` | `'Metal'` |

Observe the error SQL Server returns. Then add a comment explaining the **two reasons** this fails.

**Hint:** SQL Server cannot insert into multiple tables simultaneously through a view. Additionally, the underlying tables have columns that are not exposed by the view (e.g. `MusicGroupId` in `tmp_album`, `EstablishedYear` and primary key in `tmp_music_group`) — SQL Server cannot generate values for those.

**Expected outcome:** SQL Server raises an error. The insert cannot proceed because the view spans multiple base tables.

**Answer:** [01-view.sql](../exercise-answers/01-view.sql)

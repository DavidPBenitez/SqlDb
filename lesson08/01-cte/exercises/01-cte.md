# Lesson 08 – Exercises: Common Table Expressions (CTEs)

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

## Exercise 1 – Single CTE

**Task:** Use a **single CTE** to simplify a multi-table query.

Define a CTE named `rock_albums` that selects `AlbumId`, `Name`, `ReleaseYear`, and `CopiesSold` from `dbo.Album` where the album belongs to a **Rock** music group.

Then write a `SELECT` that joins `rock_albums` with `dbo.MusicGroup` to return:

- The music group's `Name` (aliased as `GroupName`)
- The album's `Name` (aliased as `AlbumName`)
- `ReleaseYear`
- `CopiesSold`

Order the results by `CopiesSold` descending.

**Hint:** The CTE itself needs to join `Album` to `MusicGroup` so it can filter on `Genre = 'Rock'`. Write and test the inner `SELECT` on its own before wrapping it in a `WITH` clause. The outer query then joins `rock_albums` back to `dbo.MusicGroup` on `MusicGroupId`.

**Expected outcome:** All albums from Rock groups, showing the group name alongside the album details, ordered from best-selling to least-selling.

**Answer:** [01-cte.sql](../exercise-answers/01-cte.sql)

---

## Exercise 2 – Multiple Chained CTEs

**Task:** Use **three chained CTEs** to progressively build up a result, then aggregate in the final `SELECT`.

The goal is to find the **total copies sold attributed to each artist** who has a last name starting with `'J'` and who is a member of a **Rock** group.

Define the CTEs in this order:

1. **`j_artists`** — Select `ArtistId`, `FirstName`, and `LastName` from `dbo.Artist` where `LastName LIKE 'J%'`.

2. **`j_artists_rock_groups`** — Join `j_artists` to `dbo.ArtistMusicGroup` and then to `dbo.MusicGroup` to get the `MusicGroupId` and group `Name` (aliased as `GroupName`) for every Rock group each artist belongs to. Keep `ArtistId`, `FirstName`, and `LastName` in the result. Filter on `Genre = 'Rock'`.

3. **`j_artists_rock_albums`** — Join `j_artists_rock_groups` to `dbo.Album` on `MusicGroupId` to bring in `CopiesSold` for every album released by those groups.

Finally, write a `SELECT` that queries `j_artists_rock_albums` and returns:

- `FirstName`
- `LastName`
- The total copies sold (aliased as `TotalCopiesSold`)

Group by `FirstName` and `LastName`, ordered by `TotalCopiesSold` descending.

**Hint:** Build and verify each CTE one at a time — this is the key technique shown in the script. Start with `b_artists` alone, then add `b_artists_rock_groups` and test, then add `b_artists_rock_albums`. Use commas to separate CTE definitions inside the same `WITH` block.

**Expected outcome:** One row per qualifying artist showing their name and the total copies sold across all albums from their Rock groups, ordered from highest to lowest.

**Answer:** [01-cte.sql](../exercise-answers/01-cte.sql)

---

## Exercise 3 – CTE Pagination (Sakila database)

Use the `sakila` database for this exercise.

**Task:** Use a CTE to implement **page-based pagination** over the `film` table.

Define a CTE named `films_paged` that selects `film_id`, `title`, `rating`, `rental_rate`, and `length` from `film`, and adds a `ROW_NUMBER()` window function column aliased as `rn`. Number the rows ordered by `title ASC`.

Then write a `SELECT` that returns only the rows belonging to **page 3**, using a page size of **10 rows per page**.

Return the following columns:

- `rn` (aliased as `row_num`)
- `film_id`
- `title`
- `rating`
- `rental_rate`
- `length`

Order the results by `rn`.

**Hint:** Declare two variables `@PageNumber` and `@PageSize` before the CTE. The `BETWEEN` filter for page *N* is:

```
rn BETWEEN (@PageNumber - 1) * @PageSize + 1
       AND  @PageNumber      * @PageSize
```

**Expected outcome:** Rows 21–30 from the `film` table when sorted alphabetically by title (10 rows).

**Bonus:** Extend the CTE to also include `COUNT(*) OVER ()` as `total_rows`, and add a computed `total_pages` column in the outer `SELECT` using `CEILING(CAST(total_rows AS FLOAT) / @PageSize)`.

**Answer:** [01-cte.sql](../exercise-answers/01-cte.sql)

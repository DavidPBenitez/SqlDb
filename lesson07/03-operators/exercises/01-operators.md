# Lesson 07 – Exercises: ALL, ANY, EXISTS Operators

Use the `music` database for all exercises.

The exercises use the `MusicGroup`, `Album`, and `Artist` tables:

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

---

## Exercise 1 – ALL Operator

**Task:** Write **two queries** using the `ALL` operator against the `music` database.

**Query 1:** List all albums whose `CopiesSold` is **greater than all** albums released before the year 2000.  
Use `>ALL` with a subquery that selects `CopiesSold` from `dbo.Album` where `ReleaseYear < 2000`.  
Return `Name`, `ReleaseYear`, and `CopiesSold`, ordered by `CopiesSold` descending.

**Query 2:** List all albums whose `CopiesSold` is **less than all** albums released after the year 2010.  
Use `<ALL` with a subquery that selects `CopiesSold` from `dbo.Album` where `ReleaseYear > 2010`.  
Return `Name`, `ReleaseYear`, and `CopiesSold`, ordered by `CopiesSold` ascending.

**Hint:** `>ALL(subquery)` means the value must be greater than **every** value returned by the subquery — equivalent to being greater than the **maximum** value. `<ALL(subquery)` means it must be less than the **minimum** value returned.

**Expected outcome:**
- Query 1: albums that outsold every single pre-2000 album.
- Query 2: albums that sold fewer copies than every post-2010 album.

**Answer:** [01-operators.sql](../exercise-answers/01-operators.sql)

---

## Exercise 2 – ANY Operator

**Task:** Write **two queries** using the `ANY` operator against the `music` database.

First, write a helper query (not submitted) to find the **total copies sold per genre** — you will use this as the basis for both subqueries.

**Query 1:** List all music groups whose **total copies sold** (sum of all their albums) is **greater than any** genre total from the `'Jazz'` or `'Blues'` genres.  
Use `>ANY` in a `HAVING` clause.  
Return `MusicGroupId`, group `Name`, and `TotalCopiesSold`, ordered by `TotalCopiesSold` descending.

**Query 2:** List all music groups whose **total copies sold** is **less than any** genre total from the `'Jazz'` or `'Blues'` genres.  
Use `<ANY` in a `HAVING` clause.  
Return `MusicGroupId`, group `Name`, and `TotalCopiesSold`, ordered by `TotalCopiesSold` ascending.

**Hint:** `>ANY(subquery)` means greater than **at least one** value in the subquery — equivalent to being greater than the **minimum**. `<ANY(subquery)` means less than the **maximum**. The subquery for both queries joins `Album` → `MusicGroup`, filters on `Genre IN ('Jazz', 'Blues')`, and uses `GROUP BY Genre`.

**Expected outcome:**
- Query 1: groups that outsold at least one of the Jazz or Blues genre totals.
- Query 2: groups whose total is below at least one of the Jazz or Blues genre totals.

**Answer:** [01-operators.sql](../exercise-answers/01-operators.sql)

---

## Exercise 3 – EXISTS Operator

**Task:** Write **two queries** using `EXISTS` and `NOT EXISTS` against the `music` database.

**Query 1:** List all music groups that **have at least one album** with more than 1,000,000 copies sold.  
Use `EXISTS` with a correlated subquery on `dbo.Album` that references the outer `MusicGroupId`.  
Return `Name` and `Genre`.

**Query 2:** List all music groups that have **no album** with more than 1,000,000 copies sold.  
Use `NOT EXISTS` with the same correlated subquery.  
Return `Name` and `Genre`.

**Hint:** In a correlated subquery, the inner query references a column from the outer query (e.g. `WHERE a.MusicGroupId = mg.MusicGroupId`). Use `SELECT 1` inside the `EXISTS` subquery — the actual columns selected don't matter, only whether any row is returned.

**Expected outcome:**
- Query 1: music groups with at least one blockbuster album.
- Query 2: music groups whose every album sold 1,000,000 copies or fewer — the complement of Query 1.

**Answer:** [01-operators.sql](../exercise-answers/01-operators.sql)

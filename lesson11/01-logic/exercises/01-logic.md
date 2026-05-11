# Lesson 11 – Exercises: IF…ELSE, WHILE, and Cursors

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

## Exercise 1 – IF…ELSE

**Task:** Write **three independent IF…ELSE blocks** that use variables, subqueries, and a CTE to branch logic.

**Block 1 — variable + compound condition:**

Declare an `INT` variable `@AlbumCount` and assign it the total number of albums in `dbo.Album`. Then write an `IF` that checks **both** conditions at once:
- `@AlbumCount >= 10`
- `DATENAME(WEEKDAY, GETDATE()) = 'Sunday'`

In the `BEGIN … END` block, print both: `'Album count is 10 or more.'` and `'Today is Sunday.'`.  
In the `ELSE BEGIN … END`, print `'Either the album count is less than 10, or today is not Sunday.'` and also print today's actual weekday name using `DATENAME(WEEKDAY, GETDATE())`.

**Block 2 — IF with a subquery:**

Write an `IF EXISTS` that checks whether any album in `dbo.Album` has `CopiesSold > 40000000`.  
In the `BEGIN` block print `'At least one album has sold more than 40 million copies.'`.  
In the `ELSE BEGIN` block print `'No album has sold more than 40 million copies.'`.

**Block 3 — IF with a CTE:**

Define a CTE named `multi_genre_artists` that finds artists who are members of **more than one** music group (use `ArtistMusicGroup`, group by `ArtistId`, `HAVING COUNT(*) > 1`).  
Assign the count of rows from that CTE to `@AlbumCount` (reuse the variable).  
Write an `IF` that prints `'You have ' + CAST(@AlbumCount AS NVARCHAR) + ' artist(s) who belong to more than one group.'` when the count is greater than zero, or `'All artists belong to exactly one group.'` otherwise.

**Hint:** Reuse `@AlbumCount` across all three blocks — just `SET` it to a new value each time. Always wrap multi-statement branches in `BEGIN … END`. Note the `CAST` needed to concatenate an integer into a string.

**Expected outcome:** All three blocks print their messages to the Messages window. Block 2 should print the "greater than 40 million" message given the current dataset. Block 3 result depends on the actual memberships in `ArtistMusicGroup`.

**Answer:** [01-logic.sql](../exercise-answers/01-logic.sql)

---

## Exercise 2 – Simple WHILE Loop with BREAK and CONTINUE

**Task:** Write **three WHILE loops** that demonstrate the basic loop pattern, early exit with `BREAK`, and skipping iterations with `CONTINUE`.

**Loop 1 — simple counter:**

Declare `@Counter INT = 1`. Loop `WHILE @Counter <= 5`, printing `@Counter` on each iteration, incrementing by 1 each time.

**Loop 2 — BREAK:**

Reset `@Counter = 1`. Loop `WHILE @Counter <= 100`. Print `@Counter` each iteration. When `@Counter` reaches `7`, print `'Reached 7 — exiting loop'` and `BREAK` out of the loop. Increment `@Counter` on every pass.

**Loop 3 — CONTINUE:**

Reset `@Counter = 1`. Loop `WHILE @Counter <= 8`. Print `@Counter`, then increment `@Counter`. After the increment, if `@Counter = 4`, print `'Skipping to next iteration'` and `CONTINUE`.

**Hint:** Place the increment **before** the `CONTINUE` check in Loop 3, or the loop will run forever. `BREAK` exits the innermost loop immediately. `CONTINUE` jumps back to the `WHILE` condition check, skipping any remaining statements in the current iteration.

**Expected outcome:**
- Loop 1 prints 1 through 5.
- Loop 2 prints 1 through 7 then the exit message.
- Loop 3 prints 1 through 8; when the counter reaches 4 the skip message is also printed.

**Answer:** [01-logic.sql](../exercise-answers/01-logic.sql)

---

## Exercise 3 – WHILE Loop for Row-by-Row Processing

**Task:** Use a **WHILE loop with a processed-flag pattern** to iterate through all music groups row by row and print a summary for each one.

Follow these steps:

1. Create a temporary table `#tmp_group_processing`:

   | Column | Type | Notes |
   |---|---|---|
   | `row_id` | `INT IDENTITY(1,1)` | Surrogate key for iteration |
   | `music_group_id` | `uniqueidentifier` | |
   | `group_name` | `NVARCHAR(100)` | |
   | `genre` | `NVARCHAR(50)` | |
   | `Processed` | `BIT NOT NULL` | Default `0` |

2. Populate it with `SELECT … INTO` style `INSERT`:
   ```sql
   INSERT INTO #tmp_group_processing (music_group_id, group_name, genre, Processed)
   SELECT MusicGroupId, Name, Genre, 0 FROM dbo.MusicGroup;
   ```

3. Declare `@row_id INT = 1` and variables for `@group_name NVARCHAR(100)`, `@genre NVARCHAR(50)`, and `@album_count INT`.

4. Write a `WHILE EXISTS (SELECT * FROM #tmp_group_processing WHERE Processed = 0)` loop that on each iteration:
   - Reads `@group_name` and `@genre` from the row matching `row_id = @row_id`.
   - Counts how many albums that group has (correlated query against `dbo.Album`) into `@album_count`.
   - Prints: `'Processing: <group_name> [<genre>] — <album_count> album(s)'`.
   - Sets `Processed = 1` for the current `row_id`.
   - Increments `@row_id`.

5. After the loop prints `'All groups processed.'`

**Hint:** The `WHILE EXISTS (… WHERE Processed = 0)` pattern keeps the loop running until every row is marked done — it is safer than a counter-only check. Use `CONCAT_WS` or string concatenation to build the print message. Use `CAST(@album_count AS NVARCHAR)` when concatenating the integer.

**Expected outcome:** One printed line per music group showing the name, genre, and album count. After the loop, `'All groups processed.'` is printed.

**Answer:** [01-logic.sql](../exercise-answers/01-logic.sql)

---

## Exercise 4 – Cursor

**Task:** Use a **`CURSOR FAST_FORWARD`** to iterate through every artist and print a formatted line for each one.

Follow these steps:

1. Declare two variables: `@artist_name NVARCHAR(200)` and `@group_name NVARCHAR(100)`.

2. Declare a cursor named `artist_cursor` as `CURSOR FAST_FORWARD FOR` a `SELECT` that returns the full artist name (`CONCAT_WS(' ', FirstName, LastName)`) and the name of their music group, by joining `dbo.Artist` → `dbo.ArtistMusicGroup` → `dbo.MusicGroup`. Order by `LastName`.

3. `OPEN` the cursor and do the first `FETCH NEXT … INTO @artist_name, @group_name`.

4. Write a `WHILE @@FETCH_STATUS = 0` loop that:
   - Prints `'Artist: <artist_name> — Group: <group_name>'`.
   - Fetches the next row.

5. `CLOSE` and `DEALLOCATE` the cursor.

**Hint:** Always `CLOSE` before `DEALLOCATE`. `@@FETCH_STATUS = 0` means the last fetch succeeded; any other value means there are no more rows. `FAST_FORWARD` cursors are read-only and forward-only — the most efficient cursor type for this pattern.

**Expected outcome:** One printed line per artist–group membership, ordered alphabetically by last name.

**Answer:** [01-logic.sql](../exercise-answers/01-logic.sql)

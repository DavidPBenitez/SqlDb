# Lesson 10 – Exercises: CASE Expressions

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

---

## Exercise 1 – Simple and Searched CASE

**Task:** Write **two queries** using CASE expressions to produce descriptive labels in the result set.

**Query 1 — simple CASE:**

Select `Name` (aliased `GroupName`) and `Genre` from `dbo.MusicGroup`. Add a third column aliased `Scene` that maps each genre to a description using a **simple CASE** on `Genre`:

| Genre | Scene |
|---|---|
| `'Rock'` | `'Guitar-driven rock'` |
| `'Metal'` | `'Heavy metal'` |
| `'Blues'` | `'Soulful blues'` |
| `'Jazz'` | `'Improvisational jazz'` |
| *(anything else)* | `'Unknown scene'` |

Order by `Genre`.

**Query 2 — searched CASE:**

Select `Name` (aliased `AlbumName`), `ReleaseYear`, and `CopiesSold` from `dbo.Album`. Add a column aliased `CommercialTier` using a **searched CASE** that classifies each album by `CopiesSold`:

| Condition | CommercialTier |
|---|---|
| `CopiesSold >= 20 000 000` | `'Diamond'` |
| `CopiesSold >= 10 000 000` | `'Platinum'` |
| `CopiesSold >= 5 000 000` | `'Gold'` |
| `CopiesSold >= 1 000 000` | `'Silver'` |
| *(anything else)* | `'Bronze'` |

Order by `CopiesSold` descending.

**Hint:** A *simple* CASE compares one expression to a list of values (`CASE col WHEN val THEN … END`). A *searched* CASE evaluates independent boolean conditions (`CASE WHEN condition THEN … END`). Use `>=` comparisons in descending order so the highest tier is tested first.

**Expected outcome:**
- Query 1: 9 rows, one per music group, with a plain-English scene label.
- Query 2: 15 rows ordered from best-selling to least-selling, each with a tier label.

**Answer:** [01-case.sql](../exercise-answers/01-case.sql)

---

## Exercise 2 – CASE to Transform Rows into Columns (Pivot)

**Task:** First write a regular aggregation query, then use **SUM with a searched CASE** to pivot the results from rows into columns.

**Step 1 — regular aggregation:**

Write a query that counts the number of albums released per **decade** using `GROUP BY`. Derive the decade from `ReleaseYear` using integer division:

```sql
(ReleaseYear / 10) * 10   -- e.g. 1971 → 1970
```

Return `Decade` and `NrAlbums`, ordered by `Decade` ascending.

**Step 2 — pivot using CASE:**

Write a single-row query (no `GROUP BY`) that returns five separate columns, one per decade, each counting how many albums were released in that decade. Use `SUM(CASE WHEN … THEN 1 ELSE 0 END)` for each column:

| Column alias | Condition |
|---|---|
| `Albums_1950s` | `ReleaseYear >= 1950 AND ReleaseYear < 1960` |
| `Albums_1960s` | `ReleaseYear >= 1960 AND ReleaseYear < 1970` |
| `Albums_1970s` | `ReleaseYear >= 1970 AND ReleaseYear < 1980` |
| `Albums_1980s` | `ReleaseYear >= 1980 AND ReleaseYear < 1990` |
| `Albums_1990s` | `ReleaseYear >= 1990 AND ReleaseYear < 2000` |

**Hint:** The regular aggregation in Step 1 helps you verify the counts before writing the pivot. The total of all pivot columns must equal the total rows in `dbo.Album`.

**Expected outcome:**
- Step 1: multiple rows, one per decade.
- Step 2: a single row with five columns whose values match the counts from Step 1.

**Answer:** [01-case.sql](../exercise-answers/01-case.sql)

---

## Exercise 3 – CASE with a Subquery (Existence Check)

**Task:** Use a **simple CASE** where the tested expression is a **scalar subquery** that counts albums, to classify each music group by the size of its catalog.

Select `Name` (aliased `GroupName`) and `EstablishedYear` from `dbo.MusicGroup`. Add a column aliased `CatalogSize` produced by a simple CASE whose expression is:

```sql
(SELECT COUNT(*) FROM dbo.Album a WHERE a.MusicGroupId = mg.MusicGroupId)
```

Map the count to a label:

| Album count | CatalogSize |
|---|---|
| `0` | `'No albums'` |
| `1` | `'Single album'` |
| `2` | `'Small catalog'` |
| `3` | `'Mid-size catalog'` |
| *(more than 3)* | `'Rich catalog'` |

Order by `EstablishedYear` ascending.

**Hint:** A scalar subquery that returns a single integer value can be placed directly after the `CASE` keyword in a simple CASE, exactly like a column reference. The subquery is correlated — it references the outer query's alias `mg`.

**Expected outcome:** 9 rows, one per music group, each labelled by how many albums it has in the catalog.

**Answer:** [01-case.sql](../exercise-answers/01-case.sql)

---

## Exercise 4 – CASE in an UPDATE (Conditional Data Modification)

**Task:** Use a **searched CASE with `EXISTS`** inside an `UPDATE` statement to conditionally modify data, wrapped in a transaction so the result can be verified before committing.

Follow these steps:

1. Create a working copy of the `Album` table:
   ```sql
   DROP TABLE IF EXISTS dbo.tmp_album;
   SELECT * INTO dbo.tmp_album FROM dbo.Album;
   ```

2. Verify which albums are **not** the top-selling album in their group (i.e. there exists another album from the same group with higher `CopiesSold`):
   ```sql
   SELECT Name, CopiesSold
   FROM dbo.tmp_album ta
   WHERE EXISTS (
       SELECT 1 FROM dbo.tmp_album other
       WHERE other.MusicGroupId = ta.MusicGroupId
         AND other.CopiesSold > ta.CopiesSold);
   ```

3. Open a transaction with `BEGIN TRAN`.

4. Write an `UPDATE` on `dbo.tmp_album` that sets `CopiesSold` using a searched CASE:
   - **WHEN** `EXISTS` (a correlated subquery finding another album from the same group with higher `CopiesSold`) **THEN** `CopiesSold + 500000` (reissue sales boost for non-flagship albums)
   - **ELSE** keep `CopiesSold` unchanged

   Apply this to **all rows** (no `WHERE` clause on the outer `UPDATE` — let the CASE decide).

5. Verify the change — compare the updated `dbo.tmp_album` with `dbo.Album` to confirm only the non-flagship albums received the boost.

6. Roll back the transaction with `ROLLBACK TRAN`.

7. Confirm the values are restored.

**Hint:** The correlated subquery inside `EXISTS` references `dbo.tmp_album` with two aliases — one for the outer `UPDATE` row and one for the inner comparison. Use `WHERE other.MusicGroupId = dbo.tmp_album.MusicGroupId` (unaliased table reference) inside the `UPDATE … SET` CASE, since the outer table in an `UPDATE` cannot carry an alias in standard T-SQL.

**Expected outcome:** After the update (before rollback), non-flagship albums each show `CopiesSold` increased by 500 000. After the rollback, all values are restored to original.

**Answer:** [01-case.sql](../exercise-answers/01-case.sql)

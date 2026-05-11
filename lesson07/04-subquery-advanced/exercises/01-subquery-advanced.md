# Lesson 07 – Exercises: Subqueries in UPDATE, DELETE, INSERT

Use the `friends` database for all exercises.

> **Safety rule:** All DML exercises work on **temporary table copies** of the real data. Never modify the base tables directly.

The exercises use the `Friend`, `Pet`, and `Address` tables:

**Friend**

| Column | Type | Description |
|---|---|---|
| `FriendId` | `uniqueidentifier` | Primary key |
| `FirstName` | `varchar` | Friend's first name |
| `LastName` | `varchar` | Friend's last name |
| `Email` | `varchar` | Email address |
| `Birthday` | `datetime` | Date of birth — **nullable** |
| `AddressId` | `uniqueidentifier` | Foreign key to `Address` |

**Pet**

| Column | Type | Description |
|---|---|---|
| `PetId` | `uniqueidentifier` | Primary key |
| `AnimalKind` | `varchar` | Animal type |
| `AnimalMood` | `varchar` | Current mood |
| `Name` | `varchar` | Pet's name |
| `OwnerId` | `uniqueidentifier` | Foreign key to `Friend` |

**Address**

| Column | Type | Description |
|---|---|---|
| `AddressId` | `uniqueidentifier` | Primary key |
| `StreetAddress` | `varchar` | Street address |
| `ZipCode` | `int` | Zip / postal code |
| `City` | `varchar` | City |
| `Country` | `varchar` | Country |

---

## Exercise 1 – UPDATE with a Subquery

**Task:** Some friends have a `NULL` birthday. Update those friends so their `Birthday` is set to the **earliest (minimum) birthday** that exists among all friends who do have a birthday recorded.

Follow these steps:

1. Use `SELECT … INTO` to copy `FriendId`, `FirstName`, `LastName`, and `Birthday` from `dbo.Friend` into a temporary table called `#FriendUpdate`.
2. Run a `SELECT` to preview how many rows have `Birthday IS NULL` before the update.
3. Write an `UPDATE` on `#FriendUpdate` that sets `Birthday` to the result of a scalar subquery — `(SELECT MIN(Birthday) FROM dbo.Friend)` — but only for rows where `Birthday IS NULL`.
4. Run a final `SELECT *` to show the updated rows and confirm no `NULL` birthdays remain.
5. Drop the temporary table.

**Hint:** The scalar subquery in `SET Birthday = (…)` must return exactly one value. Use `WHERE Birthday IS NULL` on the outer `UPDATE` to restrict which rows are changed.

**Expected outcome:** All previously `NULL` birthday rows are now set to the earliest birthday found in the `Friend` table.

**Answer:** [01-subquery-advanced.sql](../exercise-answers/01-subquery-advanced.sql)

---

## Exercise 2 – DELETE with EXISTS

**Task:** Some friends own no pets. Delete those friends from a temporary copy of the `Friend` table using `EXISTS`.

Follow these steps:

1. Use `SELECT … INTO` to copy `FriendId`, `FirstName`, and `LastName` from `dbo.Friend` into a temporary table called `#FriendDelete`.
2. Run a `SELECT COUNT(*)` to preview how many friends will be deleted — those for whom **no pet exists** with a matching `OwnerId`.
3. Write a `DELETE` on `#FriendDelete` using `WHERE NOT EXISTS (SELECT 1 FROM dbo.Pet …)` to remove friends who own no pets.
4. Run a `SELECT COUNT(*) AS RemainingFriends` to confirm the remaining row count.
5. Drop the temporary table.

**Hint:** The correlated `NOT EXISTS` subquery links the outer table alias to `dbo.Pet` via `OwnerId = FriendId`. The subquery uses `SELECT 1` — the actual value returned doesn't matter, only whether a row exists.

**Expected outcome:** Friends who own at least one pet remain; friends with no pets are removed from the temporary table.

**Answer:** [01-subquery-advanced.sql](../exercise-answers/01-subquery-advanced.sql)

---

## Exercise 3 – INSERT with Subqueries

**Task:** Add a new pet to a temporary copy of the `Pet` table, using subqueries to look up both the owner's `FriendId` and verify the insert — without hard-coding any `uniqueidentifier` value.

Follow these steps:

1. Use `SELECT … INTO` to copy all columns from `dbo.Pet` into a temporary table called `#PetInsert`.
2. Write a `SELECT` to preview the current pets owned by the friend whose `FirstName` is `'Alice'` and `LastName` is `'Smith'` (adjust the name to match a friend in your database).
3. Write an `INSERT INTO #PetInsert` that uses a subquery in the `VALUES` clause to supply the `OwnerId`:

   ```sql
   INSERT INTO #PetInsert (PetId, AnimalKind, AnimalMood, AnimalName, OwnerId)
   VALUES (
       NEWID(),
       'Dog',
       'Happy',
       'Buddy',
       (SELECT FriendId FROM dbo.Friend WHERE FirstName = 'Alice' AND LastName = 'Smith')
   );
   ```

4. Verify the insert by selecting all pets owned by that friend from `#PetInsert` joined back to `dbo.Friend`.
5. Drop the temporary table.

**Hint:** The subquery inside `VALUES` must return exactly one row — make sure the `WHERE` clause on `dbo.Friend` uniquely identifies one friend. Use `NEWID()` to generate a new primary key for the pet.

**Expected outcome:** The temporary table contains one additional pet row linked to the correct friend's `FriendId`.

**Answer:** [01-subquery-advanced.sql](../exercise-answers/01-subquery-advanced.sql)

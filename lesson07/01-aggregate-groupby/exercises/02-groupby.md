# Lesson 07 – Exercises: GROUP BY

Use the `friends` database for all exercises.

The exercises use the `Friend`, `Pet`, and `Address` tables:

**Friend**

| Column | Type | Description |
|---|---|---|
| `FriendId` | `uniqueidentifier` | Primary key |
| `FirstName` | `varchar` | Friend's first name |
| `LastName` | `varchar` | Friend's last name |
| `Email` | `varchar` | Email address |
| `Birthday` | `datetime` | Date of birth — **nullable** |

**Pet**

| Column | Type | Description |
|---|---|---|
| `PetId` | `uniqueidentifier` | Primary key |
| `AnimalKind` | `int` | Animal type (0 = Dog, 1 = Cat, 2 = Rabbit, 3 = Fish, 4 = Bird) |
| `AnimalMood` | `int` | Current mood |
| `AnimalName` | `varchar` | Pet's name |
| `FriendId` | `uniqueidentifier` | Foreign key to `Friend` |

**Address**

| Column | Type | Description |
|---|---|---|
| `AddressId` | `uniqueidentifier` | Primary key |
| `StreetAddress` | `varchar` | Street address |
| `ZipCode` | `int` | Zip / postal code |
| `City` | `varchar` | City |
| `Country` | `varchar` | Country |

---

## Exercise 1 – Basic GROUP BY

**Task:** Write a query against the `Pet` table that returns the **number of pets per animal kind**.

Return the following columns:

| Column | Description |
|---|---|
| `AnimalKind` | The animal kind value |
| `PetCount` | Number of pets of that kind |

Order the results by `PetCount` **descending** so the most common animal kind appears first.

**Hint:** `GROUP BY` a single column. Use `COUNT(*)` to count rows within each group.

**Expected outcome:** One row per distinct `AnimalKind` value, sorted from the most to the least common.

**Answer:** [02-groupby.sql](../exercise-answers/02-groupby.sql)

---

## Exercise 2 – GROUP BY with JOIN

**Task:** Write a query that joins `Friend` and `Pet` to show **how many pets each friend owns**.

Return the following columns:

| Column | Description |
|---|---|
| `FriendId` | The friend's id |
| `FullName` | First and last name combined with a space separator |
| `PetCount` | Number of pets owned by that friend |

Order by `PetCount` **descending**.

**Hint:** Use `INNER JOIN` on `FriendId`. Group by both `FriendId` and the full name expression. Use `CONCAT_WS(' ', FirstName, LastName)` to build the full name — the same expression must appear in both `SELECT` and `GROUP BY`.

**Expected outcome:** One row per friend who owns at least one pet, showing their full name and pet count, sorted from most to fewest pets.

**Answer:** [02-groupby.sql](../exercise-answers/02-groupby.sql)

---

## Exercise 3 – GROUP BY with Date Functions

**Task:** Write **two queries** against the `Friend` table that group friends by the date parts of their `Birthday`.

**Query 1:** Return the number of friends born in each **year**.

| Column | Description |
|---|---|
| `BirthYear` | The year extracted from `Birthday` |
| `FriendCount` | Number of friends born in that year |

Order by `BirthYear` ascending.

**Query 2:** Return the number of friends born in each **year and month** combination.

| Column | Description |
|---|---|
| `BirthYear` | The year extracted from `Birthday` |
| `BirthMonth` | The month extracted from `Birthday` |
| `FriendCount` | Number of friends born in that year and month |

Order by `BirthYear` then `BirthMonth`, both ascending.

**Hint:** Use `YEAR(Birthday)` and `MONTH(Birthday)` in both the `SELECT` list and the `GROUP BY` clause. Friends with a `NULL` birthday are automatically excluded from grouped results.

**Expected outcome:**
- Query 1: one row per birth year with a count of friends.
- Query 2: one row per year-month combination with a count of friends.

**Answer:** [02-groupby.sql](../exercise-answers/02-groupby.sql)

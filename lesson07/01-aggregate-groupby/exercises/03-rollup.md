# Lesson 07 – Exercises: ROLLUP

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
| `AddressId` | `uniqueidentifier` | Foreign key to `Address` |

**Address**

| Column | Type | Description |
|---|---|---|
| `AddressId` | `uniqueidentifier` | Primary key |
| `StreetAddress` | `varchar` | Street address |
| `ZipCode` | `int` | Zip / postal code |
| `City` | `varchar` | City |
| `Country` | `varchar` | Country |

**Pet**

| Column | Type | Description |
|---|---|---|
| `PetId` | `uniqueidentifier` | Primary key |
| `AnimalKind` | `int` | Animal type (0 = Dog, 1 = Cat, 2 = Rabbit, 3 = Fish, 4 = Bird) |
| `AnimalMood` | `int` | Current mood |
| `AnimalName` | `varchar` | Pet's name |
| `OwnerId` | `uniqueidentifier` | Foreign key to `Friend` |

---

## Exercise 1 – Friends per Country and City with ROLLUP

**Task:** Write a query that returns the **number of friends per country and city**, including subtotals per country and a grand total, using `WITH ROLLUP`.

Join `Friend` to `Address` and group by `Country` and `City`. Replace the `NULL` values that `ROLLUP` produces with the labels `'All countries'` and `'All cities'` using `COALESCE`.

Return the following columns:

| Column | Description |
|---|---|
| `Country` | Country name, or `'All countries'` for the grand total row |
| `City` | City name, or `'All cities'` for country subtotal and grand total rows |
| `NrFriends` | Number of friends in that country/city combination |

Order by `Country` and `City` ascending.

**Hint:** Use `GROUP BY a.Country, a.City WITH ROLLUP`. Wrap each grouping column in `COALESCE(column, 'label')` in the `SELECT` list. `ROLLUP` produces a subtotal row for each country (where `City` is `NULL`) and one grand total row (where both `Country` and `City` are `NULL`).

**Expected outcome:** One row per country-city combination, one subtotal row per country, and one grand total row at the end — with `NULL`s replaced by meaningful labels.

**Answer:** [03-rollup.sql](../exercise-answers/03-rollup.sql)

---

## Exercise 2 – Pets per Country and City with ROLLUP

**Task:** Write a query that returns the **number of pets per country and city**, including subtotals per country and a grand total, using `WITH ROLLUP`.

Join `Pet` → `Friend` → `Address` and group by `Country` and `City`. Replace `NULL` rollup values with `'All countries'` and `'All cities'` using `COALESCE`.

Return the following columns:

| Column | Description |
|---|---|
| `Country` | Country name, or `'All countries'` for the grand total row |
| `City` | City name, or `'All cities'` for country subtotal and grand total rows |
| `NrPets` | Number of pets in that country/city combination |

Order by `Country` and `City` ascending.

**Hint:** You need two `INNER JOIN`s: `Pet` → `Friend` on `OwnerId`, then `Friend` → `Address` on `AddressId`. The `GROUP BY` and `COALESCE` pattern is the same as Exercise 1.

**Expected outcome:** One row per country-city combination, one subtotal row per country, and one grand total row at the end — with `NULL`s replaced by meaningful labels.

**Answer:** [03-rollup.sql](../exercise-answers/03-rollup.sql)

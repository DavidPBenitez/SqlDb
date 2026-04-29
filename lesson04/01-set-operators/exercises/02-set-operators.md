# Lesson 04 – Exercises: Set Operators

Use the `sakila` database for all exercises.

Relevant tables:

| Table | Key columns |
|---|---|
| `staff` | `staff_id`, `first_name`, `last_name` |
| `customer` | `customer_id`, `first_name`, `last_name` |
| `film` | `film_id`, `title` |
| `inventory` | `inventory_id`, `film_id`, `store_id` |

---

## Exercise 1 – UNION ALL

**Task:** Write a query using `UNION ALL` that produces a summary of how many distinct first names exist in the `staff` and `customer` tables. Return a label column (`'Staff'` / `'Customers'`) and the count of distinct first names. Name the columns `Source` and `DistinctFirstNames`.

Then extend the query: filter **both** halves so only names beginning with `'J'` are counted. Order the final result by `DistinctFirstNames` descending.

**Hint:** Apply `WHERE first_name LIKE 'J%'` to each `SELECT` before the `UNION ALL`, and place `ORDER BY` only at the very end.

**Expected outcome:** Two rows — one for staff, one for customers — showing how many distinct J-names each table contains, ordered from highest to lowest.

**Answer:** [02-set-operators.sql](../exercise-answers/02-set-operators.sql)

---

## Exercise 1b – UNION ALL (three tables)

**Task:** Write a query using `UNION ALL` across `customer`, `actor`, and `staff` that returns a single deduplicated list of distinct last names from all three tables combined. Each last name should appear only once in the final result, regardless of which table(s) it comes from.

**Hint:** `UNION ALL` keeps duplicates — wrap the three `SELECT last_name` statements inside a subquery (or a CTE) and apply `SELECT DISTINCT` on the outside, or use `UNION` (without `ALL`) instead of `UNION ALL` to eliminate duplicates automatically. Order the result alphabetically.

**Expected outcome:** A single column `last_name` — one row per unique last name found across all three tables, sorted A–Z.

**Answer:** [02-set-operators.sql](../exercise-answers/02-set-operators.sql)

---

## Exercise 2 – INTERSECT

**Task:** Find all last names that appear in **both** the `customer` table and the `staff` table.

1. Write a query that returns the **list** of shared last names using `INTERSECT`.
2. Wrap that query in a subquery to return just the **count** of shared last names.

**Hint:** `SELECT last_name FROM dbo.customer INTERSECT SELECT last_name FROM dbo.staff`. Alias the subquery when counting.

**Expected outcome:** First query: the actual shared last names, one per row, alphabetically. Second query: a single integer — the number of last names that appear in both tables.

**Answer:** [02-set-operators.sql](../exercise-answers/02-set-operators.sql)

---

## Exercise 3 – EXCEPT

**Task:** Find all films that exist in the `film` table but have **no copies** in the `inventory` table.

1. Write a query using `EXCEPT` on `film_id` that returns the **list** of film IDs with no inventory.
2. Wrap the query in a subquery to return just the **count**.
3. As an alternative approach, write the count query using `NOT IN` with a subquery instead of `EXCEPT` and confirm the result matches.

**Hint:** Use `SELECT film_id FROM dbo.film EXCEPT SELECT film_id FROM dbo.inventory`. For the `NOT IN` version: `WHERE film_id NOT IN (SELECT film_id FROM dbo.inventory)`.

**Expected outcome:** All three queries agree on the count. The first query lists each film ID once.

**Answer:** [02-set-operators.sql](../exercise-answers/02-set-operators.sql)

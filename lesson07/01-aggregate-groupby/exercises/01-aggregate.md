# Lesson 07 – Exercise: Aggregate Functions

Use the `friends` database for all exercises.

The exercise uses the `Friend` and `Pet` tables:

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
| `Kind` | `int` | Animal type (0 = Dog, 1 = Cat, 2 = Rabbit, 3 = Fish, 4 = Bird) |
| `AnimalMood` | `int` | Current mood of the pet |
| `AnimalName` | `varchar` | Pet's name |
| `FriendId` | `uniqueidentifier` | Foreign key to `Friend` |

---

## Exercise 1 – Aggregate Functions

Write two queries against the `friends` database.

**Query 1:** Against the `Friend` table, return a **single row** containing:

| Column | Description |
|---|---|
| `TotalFriends` | Total number of rows in the table |
| `FriendsWithBirthday` | Number of friends who have a birthday recorded (non-NULL) |
| `FriendsWithoutBirthday` | Number of friends who do **not** have a birthday recorded |
| `EarliestBirthday` | The earliest (oldest) birthday value |
| `LatestBirthday` | The most recent birthday value |

**Hint:** `COUNT(*)` counts all rows regardless of NULLs; `COUNT(column)` skips NULL values. Use `MIN` and `MAX` on the `Birthday` column.

**Expected outcome:** One result set with a single row of aggregate statistics about friends.

---

**Query 2:** Against the `Pet` table, return a **single row** containing:

| Column | Description |
|---|---|
| `TotalPets` | Total number of pets |
| `DistinctKinds` | Number of distinct animal kinds present |
| `DistinctMoods` | Number of distinct moods present |

**Hint:** Use `COUNT(DISTINCT column)` to count unique values within a column.

**Expected outcome:** One result set with a single row of aggregate statistics about pets.

---

**Answer:** [01-aggregate.sql](../exercise-answers/01-aggregate.sql)

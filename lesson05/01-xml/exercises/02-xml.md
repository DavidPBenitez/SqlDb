# Lesson 05 – Exercises: XML

Use the `music` database for all exercises.

The database has four tables:

| Table | Key columns |
|---|---|
| `Artist` | `ArtistId`, `FirstName`, `LastName`, `BirthDay` |
| `MusicGroup` | `MusicGroupId`, `Name`, `EstablishedYear`, `Genre` |
| `Album` | `AlbumId`, `Name`, `ReleaseYear`, `CopiesSold`, `MusicGroupId` |
| `ArtistMusicGroup` | `ArtistId`, `MusicGroupId` |

---

## Exercise 1 – FOR XML AUTO

**Task:** Write a query that returns music group and album data as XML using `FOR XML AUTO`. Join `MusicGroup` to `Album` and return all columns. The XML element names should be derived automatically from the table aliases.

Then store the result in an `XML` variable called `@musicXML` and display it with a `SELECT`.

**Hint:** Use `FOR XML AUTO` at the end of the query. To assign to a variable, wrap the query in `SET @musicXML = (SELECT ... FOR XML AUTO)`.

**Expected outcome:** An XML document where each `MusicGroup` element contains nested `Album` child elements for every album belonging to that group.

**Answer:** [02-xml.sql](../exercise-answers/02-xml.sql)

---

## Exercise 2 – FOR XML PATH

**Task:** Write a query that produces a structured XML output using `FOR XML PATH('MusicGroup')`. For each music group, include:

| XML output | Source |
|---|---|
| `@MusicGroupId` attribute | `MusicGroup.MusicGroupId` |
| `Name` element | `MusicGroup.Name` |
| `Genre` element | `MusicGroup.Genre` |
| `EstablishedYear` element | `MusicGroup.EstablishedYear` |
| `Album` element | `Album.Name` and `Album.ReleaseYear` formatted as `'<AlbumName> (<ReleaseYear>)'` |

Join `MusicGroup` to `Album`. Use `CONCAT` or string concatenation to format the `Album` element value.

**Hint:** Use column aliases with `/` notation to control element nesting, e.g. `mg.Name "Name"`. Prefix an alias with `@` to make it an XML attribute.

**Expected outcome:** One `<MusicGroup>` element per album row, each carrying the group's details and a formatted album description.

**Answer:** [02-xml.sql](../exercise-answers/02-xml.sql)

---

## Exercise 3 – Load data from an XML file

**Task:** You have been provided with an XML file `xml-music-example.xml` containing `<Album>` records. Load its contents into a temporary table `#fromXML` with the following columns:

| Column | XML source |
|---|---|
| `AlbumId` | `@AlbumId` attribute on `<Album>` |
| `Name` | `<Name>` child element |
| `ReleaseYear` | `<ReleaseYear>` child element |
| `Genre` | `<Genre>` child element |

Steps to complete:

1. Copy the XML file into the Docker container:
   ```
   docker exec -u root sql2022container mkdir /usr/xmlfiles
   docker cp xml-music-example.xml sql2022container:/usr/xmlfiles/
   ```
2. Use `OPENROWSET(BULK ..., SINGLE_BLOB)` to read the file.
3. `CAST` the blob to the `xml` data type.
4. Use `CROSS APPLY ... .nodes('Album')` to shred the XML into rows.
5. Extract `@AlbumId` as `UNIQUEIDENTIFIER` and the child elements using `.query(...).value('.', 'NVARCHAR(200)')`.
6. Use `SELECT INTO #fromXML` to avoid declaring the table schema up front.
7. Strip any tab (`NCHAR(9)`) and newline (`NCHAR(10)`) characters from the text columns with `UPDATE` and `REPLACE`.
8. `SELECT * FROM #fromXML` to verify the result, then `DROP TABLE #fromXML`.

**Hint:** Attributes are read with `.value('@AttributeName', 'datatype')`. Child element text is read with `.query('ElementName').value('.', 'NVARCHAR(200)')`.

**Answer:** [03-xml.sql](../exercise-answers/03-xml.sql)

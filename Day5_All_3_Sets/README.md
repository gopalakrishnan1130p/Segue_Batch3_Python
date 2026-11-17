# Hexaware Python Track – Day 5 Assignment (All 3 Sets)

This pack contains separate working examples for all three assignment sets:
1. Retail Inventory and Product Reviews
2. Bank Branch Accounts and Customer Activity
3. Hospital Patient Records and Clinical Notes

## Software required
- Microsoft SQL Server (the assignment mentions SQL Server 2025)
- SQL Server Management Studio (SSMS)
- MongoDB 8.0
- MongoDB Compass or `mongosh`

## How to execute
For each set:
1. Open the `schema.sql` file in SSMS and execute it.
2. Open `seed_data.sql` in SSMS and execute it.
3. Review the result grids and Messages tab. The deliberately failing SQL statements are wrapped in TRY/CATCH so the rest of the script can continue.
4. Open `collections.js` in `mongosh` or MongoDB Compass Playground and execute it against a MongoDB server.
5. Open `ER_Diagram.md` for the Mermaid ER diagram. Paste the Mermaid code into https://mermaid.live to export it as an image if required.
6. Read `Notes.md` for the normalisation explanation, assumptions and operation comparison.

> Run each set's SQL scripts separately. The scripts create/use a database named for that set.
> The seed scripts are designed for a fresh database. If you rerun them, remove the existing sample rows or recreate the database first.

## Important
- These are sample records for an academic assignment, not real customer, bank or patient data.
- The bank activity and hospital clinical notes are modelled as MongoDB documents as requested.
- Review the assumptions in each `Notes.md` and adjust names/dates if your trainer gives different requirements.

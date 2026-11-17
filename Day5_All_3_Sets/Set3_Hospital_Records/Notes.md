# Set 3 – Explanation and Assumptions

## Normalisation to 3NF
- 1NF: Store one patient, doctor and visit value per field; avoid repeating groups in the wide sheet.
- 2NF: Each table uses a single-column primary key, so non-key attributes depend on the whole key. Billing is separated and linked to one Visit.
- 3NF: Department details depend on DepartmentID, not DoctorID; patient address depends on PatientID; doctor name/department depend on DoctorID; visit diagnosis/date/prescription depend on VisitID; billing amount/status depend on BillingID/VisitID. These are separated into Patient, Department, Doctor, Visit and Billing.
- Clinical notes are stored as MongoDB documents because their structure may vary by visit (symptoms, vitals, lab results, follow-up information).

## Three assumptions
1. Each doctor belongs to one department.
2. Each visit is for one patient and is handled by one doctor.
3. Each visit generates at most one billing record; therefore Billing.VisitID is UNIQUE. A visit date cannot be in the future.

## ALTER TABLE demonstrations
- `ALTER TABLE Patient ADD InsuranceID`: adds an optional insurance identifier without requiring existing rows to have a value.
- `sp_rename`: changes the SQL table name from Billing to PatientBilling; the table's data and relationships remain.
- `ALTER TABLE ... DROP CONSTRAINT`: temporarily removes the non-negative bill amount rule. The script demonstrates that a negative amount can then be inserted, rolls it back, and recreates the CHECK constraint so the final database remains protected.

## MongoDB choice
Clinical notes may have different structures for different diagnoses or visits. MongoDB documents allow optional nested objects and arrays such as vitals and lab results without adding many nullable columns to a relational table.

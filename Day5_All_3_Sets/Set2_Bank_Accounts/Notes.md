# Set 2 – Explanation and Assumptions

## Normalisation to 3NF/BCNF
- Customer address and contact details are stored once in Customer.
- Branch details are stored once in Branch.
- Account type descriptions are stored in AccountType.
- Manager details and their branch assignment are stored in RelationshipManager.
- Account-specific facts (account number, type, branch/manager assignment, balance and opening date) are stored in Account.
- The many-to-many ownership relationship is stored in AccountCustomer.

## Keys
- Candidate key for Customer: `CustomerID`; `Email` is an alternate candidate key because it is UNIQUE.
- Candidate key for Account: `AccountID`; `AccountNumber` is an alternate candidate key because it is UNIQUE.
- Candidate key for Branch: `BranchID`; `(BranchName, City)` is an alternate candidate key.
- Composite primary key: `(AccountID, CustomerID)` in AccountCustomer. Both columns together uniquely identify an account-holder relationship.
- Composite foreign key: `(ManagerID, BranchID)` in Account references the matching manager/branch pair.

## DROP vs TRUNCATE vs DELETE (SQL Server)
- DELETE removes selected/all rows and supports WHERE. It normally does not reset the IDENTITY counter. It can be rolled back inside a transaction.
- TRUNCATE removes all rows, does not support WHERE, and resets the identity counter. It can be rolled back in SQL Server when used inside a transaction and when permitted by constraints.
- DROP removes the table definition and its data. In SQL Server, this DDL operation can be rolled back inside a transaction.
- The script demonstrates identity values and rollback using an isolated `CommandDemo` table.

## Why MongoDB for activity logs?
Activity logs are time-stamped event documents with potentially changing fields (device, IP, event type, metadata). A capped collection provides bounded storage and efficient insertion-order retention for this sample.

## Assumptions
1. Each account has at least one holder; joint holders are supported through AccountCustomer.
2. Each account is assigned to one relationship manager, and the manager belongs to the same branch as the account.
3. For this exercise, savings balances must be non-negative. The CHECK expression is defined on Account using the AccountTypeName value; other account types are not restricted by that specific check.
4. The activity query returns the five most recent LOGIN events for customer `CUST001`, not the five most recent events of every type.

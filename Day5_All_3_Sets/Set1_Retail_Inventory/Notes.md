# Set 1 – Explanation and Assumptions

## Normalisation to 3NF
- 1NF: Each spreadsheet cell is atomic. Reviews are moved out of the free-text stock sheet and stored as separate MongoDB documents.
- 2NF: The stock quantity depends on the combination of Product and Warehouse, so it is stored in `Inventory` with a unique `(ProductID, WarehouseID)` pair. Product details are stored separately.
- 3NF: Supplier name/phone depend on `SupplierID`, category name depends on `CategoryID`, and warehouse details depend on `WarehouseID`. These details are separated from Product/Inventory to remove transitive dependencies.

## Anomalies in the original spreadsheet
- Insert anomaly: A supplier or warehouse cannot be recorded easily until a product stock row exists.
- Update anomaly: A supplier phone repeated across many product rows must be changed in every row; missing one row causes inconsistent data.
- Delete anomaly: Deleting the only product row for a supplier may also remove the only stored copy of that supplier's contact details.

## MongoDB decisions
- Product reviews: MongoDB suits variable-length review text, ratings, optional purchase verification and evolving review metadata.
- Search activity: MongoDB suits event-style documents whose fields may vary by search type and whose volume can grow quickly.

## Referential actions
- Product-to-Inventory uses `ON DELETE CASCADE`, so stock rows are removed when a product is deleted.
- Product-to-Supplier and Product-to-Category use `ON DELETE NO ACTION`, preventing deletion of a supplier/category still used by products.
- `ON UPDATE CASCADE` propagates changed parent keys.

## Assumptions
1. Each product has one primary supplier and one category.
2. A product may be stocked in multiple warehouses; therefore Inventory uses a product/warehouse unique pair.
3. A discontinued product is removed from the active product catalogue in this exercise; its inventory rows cascade-delete.

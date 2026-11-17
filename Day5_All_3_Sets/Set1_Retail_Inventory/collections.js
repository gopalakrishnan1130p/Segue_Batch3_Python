// Run with mongosh against MongoDB 8.0.
use("Day5_RetailInventory");

db.createCollection("reviews", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["sku", "customerId", "rating", "reviewText", "createdAt"],
      properties: {
        sku: { bsonType: "string", description: "Product SKU is required" },
        customerId: { bsonType: "string" },
        rating: { bsonType: "int", minimum: 1, maximum: 5 },
        reviewText: { bsonType: "string", minLength: 1 },
        createdAt: { bsonType: "date" },
        verifiedPurchase: { bsonType: "bool" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

db.reviews.insertMany([
  {sku:"SKU1001",customerId:"C001",rating:5,reviewText:"Works very well",createdAt:new Date("2026-10-01"),verifiedPurchase:true},
  {sku:"SKU1002",customerId:"C002",rating:4,reviewText:"Good keyboard",createdAt:new Date("2026-10-02"),verifiedPurchase:true},
  {sku:"SKU1003",customerId:"C003",rating:5,reviewText:"Useful notebook",createdAt:new Date("2026-10-03"),verifiedPurchase:false},
  {sku:"SKU1004",customerId:"C004",rating:3,reviewText:"Comfort is average",createdAt:new Date("2026-10-04"),verifiedPurchase:true},
  {sku:"SKU1005",customerId:"C005",rating:4,reviewText:"Good bottle",createdAt:new Date("2026-10-05"),verifiedPurchase:true},
  {sku:"SKU1006",customerId:"C006",rating:5,reviewText:"Great bat",createdAt:new Date("2026-10-06"),verifiedPurchase:true},
  {sku:"SKU1007",customerId:"C007",rating:2,reviewText:"Colour was different",createdAt:new Date("2026-10-07"),verifiedPurchase:false},
  {sku:"SKU1008",customerId:"C008",rating:4,reviewText:"Comfortable shoes",createdAt:new Date("2026-10-08"),verifiedPurchase:true},
  {sku:"SKU1009",customerId:"C009",rating:5,reviewText:"Easy to understand",createdAt:new Date("2026-10-09"),verifiedPurchase:true},
  {sku:"SKU1001",customerId:"C010",rating:4,reviewText:"Value for money",createdAt:new Date("2026-10-10"),verifiedPurchase:false}
]);

// find
db.reviews.find({ sku: "SKU1001" });

// updateOne
db.reviews.updateOne(
  { customerId: "C001", sku: "SKU1001" },
  { $set: { reviewText: "Works very well and is easy to use" } }
);

// deleteOne
db.reviews.deleteOne({ customerId: "C010", sku: "SKU1001" });

// Verify final documents
db.reviews.find().sort({ createdAt: 1 });

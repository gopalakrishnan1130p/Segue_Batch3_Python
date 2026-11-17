// Run with mongosh against MongoDB 8.0.
use("Day5_BankAccounts");

// A capped collection has a fixed maximum size and preserves insertion order.
// When it reaches the limit, MongoDB overwrites the oldest documents.
db.createCollection("customerActivity", {
  capped: true,
  size: 1048576, // 1 MB
  max: 1000
});

const activityDocs = [];
for (let i = 1; i <= 20; i++) {
  activityDocs.push({
    customerId: "CUST001",
    eventType: i % 3 === 0 ? "TRANSFER" : "LOGIN",
    eventTime: new Date(Date.now() - (20 - i) * 60 * 1000),
    device: i % 2 === 0 ? "Android" : "Web",
    ipAddress: "192.0.2." + i,
    success: true
  });
}
db.customerActivity.insertMany(activityDocs);

// Insert a few events for another customer to show filtering.
db.customerActivity.insertMany([
  {customerId:"CUST002",eventType:"LOGIN",eventTime:new Date(),device:"Web",success:true},
  {customerId:"CUST002",eventType:"LOGIN",eventTime:new Date(Date.now()-60000),device:"Android",success:true}
]);

// Last five LOGIN events for one customer.
db.customerActivity.find(
  { customerId: "CUST001", eventType: "LOGIN" }
).sort({ eventTime: -1 }).limit(5);

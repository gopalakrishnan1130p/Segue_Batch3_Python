// Day 6 Assignment - Set 1: Retail Sales Reporting (MongoDB 8.0)

use retail;

db.orders.insertMany([
  { order_id: 1001, city: "Chennai", order_date: ISODate("2026-08-05"), status: "Paid", items: [{ product: "Wireless Keyboard", qty: 1, price: 4500 }, { product: "ANC Headphones", qty: 1, price: 8000 }] },
  { order_id: 1002, city: "Chennai", order_date: ISODate("2026-08-18"), status: "Paid", items: [{ product: "Wireless Keyboard", qty: 1, price: 4500 }] },
  { order_id: 1003, city: "Chennai", order_date: ISODate("2026-09-10"), status: "Paid", items: [{ product: "ANC Headphones", qty: 1, price: 8000 }] },
  { order_id: 1004, city: "Chennai", order_date: ISODate("2026-10-02"), status: "Unpaid", items: [{ product: "USB-C Dock", qty: 1, price: 3500 }] },
  { order_id: 1005, city: "Bengaluru", order_date: ISODate("2026-08-18"), status: "Paid", items: [{ product: "ANC Headphones", qty: 1, price: 8000 }, { product: "Office Chair", qty: 1, price: 12000 }] },
  { order_id: 1006, city: "Bengaluru", order_date: ISODate("2026-09-22"), status: "Paid", items: [{ product: "USB-C Dock", qty: 1, price: 3500 }, { product: "Steel Water Bottle", qty: 2, price: 800 }] },
  { order_id: 1007, city: "Chennai", order_date: ISODate("2026-09-14"), status: "Paid", items: [{ product: "Office Chair", qty: 1, price: 12000 }] },
  { order_id: 1008, city: "Mumbai", order_date: ISODate("2026-10-05"), status: "Unpaid", items: [{ product: "Desk Organizer", qty: 2, price: 1500 }] },
  { order_id: 1009, city: "Bengaluru", order_date: ISODate("2026-10-12"), status: "Paid", items: [{ product: "ANC Headphones", qty: 1, price: 8000 }, { product: "Desk Organizer", qty: 1, price: 1500 }] }
]);

// 1. Month-wise sales
db.orders.aggregate([
  { $match: { status: { $in: ["Paid", "Unpaid"] } } },
  { $unwind: "$items" },
  { $group: { _id: { $dateToString: { format: "%Y-%m", date: "$order_date" } }, total_sales: { $sum: { $multiply: ["$items.qty", "$items.price"] } } } },
  { $sort: { _id: 1 } }
]);

// 2. Top 5 products by revenue
db.orders.aggregate([
  { $match: { status: { $ne: "Cancelled" } } },
  { $unwind: "$items" },
  { $group: { _id: "$items.product", revenue: { $sum: { $multiply: ["$items.qty", "$items.price"] } } } },
  { $sort: { revenue: -1 } },
  { $limit: 5 }
]);

// 3. Average basket value per city
db.orders.aggregate([
  { $match: { status: { $ne: "Cancelled" } } },
  { $unwind: "$items" },
  { $group: { _id: { order_id: "$order_id", city: "$city" }, basket_total: { $sum: { $multiply: ["$items.qty", "$items.price"] } } } },
  { $group: { _id: "$_id.city", avg_basket: { $round: [{ $avg: "$basket_total" }, 2] } } },
  { $sort: { avg_basket: -1 } }
]);

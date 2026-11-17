// Day 6 Assignment - Set 3: Telecom Usage and Billing Reporting (MongoDB 8.0)

use telecom;

db.usage_events.insertMany([
  { subscriber_id: 1001, cell_tower_id: "TWR-CHN-01", event_type: "DATA", session_seconds: 1800, data_mb: 1200, timestamp: ISODate("2026-10-14T09:15:00Z") },
  { subscriber_id: 1002, cell_tower_id: "TWR-CHN-01", event_type: "DATA", session_seconds: 2400, data_mb: 1850, timestamp: ISODate("2026-10-14T09:42:00Z") },
  { subscriber_id: 1003, cell_tower_id: "TWR-KOC-04", event_type: "VOICE", session_seconds: 600, data_mb: 0, timestamp: ISODate("2026-10-14T10:10:00Z") },
  { subscriber_id: 1004, cell_tower_id: "TWR-BLR-02", event_type: "DATA", session_seconds: 3600, data_mb: 2500, timestamp: ISODate("2026-10-14T14:20:00Z") },
  { subscriber_id: 1001, cell_tower_id: "TWR-CHN-01", event_type: "DATA", session_seconds: 1200, data_mb: 950, timestamp: ISODate("2026-10-14T14:50:00Z") },
  { subscriber_id: 1005, cell_tower_id: "TWR-KOC-04", event_type: "DATA", session_seconds: 3000, data_mb: 2100, timestamp: ISODate("2026-10-14T20:05:00Z") }
]);

// 1. Hourly usage
db.usage_events.aggregate([
  { $group: { _id: { $hour: "$timestamp" }, events: { $sum: 1 }, total_data_mb: { $sum: "$data_mb" } } },
  { $sort: { _id: 1 } }
]);

// 2. Average session length
db.usage_events.aggregate([
  { $group: { _id: "$event_type", avg_seconds: { $avg: "$session_seconds" } } }
]);

// 3. Busiest cell tower
db.usage_events.aggregate([
  { $group: { _id: "$cell_tower_id", total_events: { $sum: 1 }, total_data_mb: { $sum: "$data_mb" } } },
  { $sort: { total_events: -1 } },
  { $limit: 1 }
]);

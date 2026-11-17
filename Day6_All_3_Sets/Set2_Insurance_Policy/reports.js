// Day 6 Assignment - Set 2: Insurance Policy Reporting (MongoDB 8.0)

use insurance;

db.claims_notes.insertMany([
  { claim_id: "CLM-501", status: "Settled", damage_category: "Hospitalization", filed_date: ISODate("2026-04-10"), settled_date: ISODate("2026-04-18") },
  { claim_id: "CLM-502", status: "Settled", damage_category: "Hospitalization", filed_date: ISODate("2026-06-15"), settled_date: ISODate("2026-06-25") },
  { claim_id: "CLM-503", status: "Settled", damage_category: "Collision Damage", filed_date: ISODate("2026-07-20"), settled_date: ISODate("2026-07-26") },
  { claim_id: "CLM-504", status: "In Review", damage_category: "Hospitalization", filed_date: ISODate("2026-08-05"), settled_date: null },
  { claim_id: "CLM-505", status: "Settled", damage_category: "Flood Damage", filed_date: ISODate("2026-08-12"), settled_date: ISODate("2026-08-24") },
  { claim_id: "CLM-506", status: "Rejected", damage_category: "Windshield Crack", filed_date: ISODate("2026-09-01"), settled_date: null }
]);

// 1. Claims per status
db.claims_notes.aggregate([
  { $group: { _id: "$status", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]);

// 2. Average settlement time (days)
db.claims_notes.aggregate([
  { $match: { status: "Settled" } },
  { $project: { days: { $dateDiff: { startDate: "$filed_date", endDate: "$settled_date", unit: "day" } } } },
  { $group: { _id: null, avg_settlement_days: { $avg: "$days" } } }
]);

// 3. Top 3 damage categories
db.claims_notes.aggregate([
  { $group: { _id: "$damage_category", total: { $sum: 1 } } },
  { $sort: { total: -1 } },
  { $limit: 3 }
]);

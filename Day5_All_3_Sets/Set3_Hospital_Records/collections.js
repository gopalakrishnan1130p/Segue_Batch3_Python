// Run with mongosh against MongoDB 8.0.
use("Day5_HospitalRecords");

db.createCollection("clinicalNotes", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["patientId", "visitId", "diagnosis", "createdAt"],
      properties: {
        patientId: { bsonType: "int" },
        visitId: { bsonType: "int" },
        diagnosis: { bsonType: "string" },
        createdAt: { bsonType: "date" },
        symptoms: { bsonType: "array", items: { bsonType: "string" } },
        vitals: {
          bsonType: "object",
          properties: {
            temperatureC: { bsonType: ["double", "int", "decimal"] },
            pulse: { bsonType: "int" },
            bloodPressure: { bsonType: "string" }
          }
        },
        labResults: { bsonType: "array" },
        treatmentPlan: { bsonType: "string" },
        followUp: { bsonType: "string" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// Document shape 1: symptoms and vital signs.
db.clinicalNotes.insertOne({
  patientId: 1,
  visitId: 1,
  diagnosis: "Hypertension",
  createdAt: new Date("2026-10-02"),
  symptoms: ["headache", "dizziness"],
  vitals: { temperatureC: 36.8, pulse: 82, bloodPressure: "145/90" },
  treatmentPlan: "Monitor blood pressure and follow prescribed medication",
  followUp: "Review after two weeks"
});

// Document shape 2: lab results and a different set of fields.
db.clinicalNotes.insertOne({
  patientId: 2,
  visitId: 2,
  diagnosis: "Migraine",
  createdAt: new Date("2026-10-04"),
  symptoms: ["severe headache", "light sensitivity"],
  labResults: [
    { test: "CBC", result: "Normal" },
    { test: "Eye examination", result: "No abnormality detected" }
  ],
  treatmentPlan: "Medication and adequate rest"
});

// Query by diagnosis.
db.clinicalNotes.find({ diagnosis: "Hypertension" });
db.clinicalNotes.find({ diagnosis: { $regex: "Migraine", $options: "i" } });

USE Day5_HospitalRecords;
GO

INSERT INTO dbo.Patient (PatientName,AddressLine,City,Phone) VALUES
('Anand R','10 Lake View','Chennai','9000000001'),
('Bhuvana S','11 Market Road','Chennai','9000000002'),
('Charu M','12 Temple Street','Madurai','9000000003'),
('Dinesh K','13 Park Avenue','Coimbatore','9000000004'),
('Elakkiya P','14 Main Road','Salem','9000000005'),
('Faisal A','15 Beach Road','Chennai','9000000006'),
('Geetha V','16 North Street','Trichy','9000000007'),
('Hari N','17 South Street','Vellore','9000000008'),
('Indhu L','18 School Road','Erode','9000000009'),
('Jeeva T','19 Gandhi Street','Chennai','9000000010');

INSERT INTO dbo.Department (DepartmentName) VALUES
('Cardiology'),('Neurology'),('Orthopaedics'),('Paediatrics'),
('Dermatology'),('ENT'),('General Medicine'),('Ophthalmology'),
('Oncology'),('Dentistry');

INSERT INTO dbo.Doctor (DoctorName,DepartmentID) VALUES
('Dr. Kumar',1),('Dr. Meera',2),('Dr. Ravi',3),('Dr. Nisha',4),
('Dr. Arun',5),('Dr. Priya',6),('Dr. Suresh',7),('Dr. Divya',8),
('Dr. Karthik',9),('Dr. Anitha',10);

INSERT INTO dbo.Visit (PatientID,DoctorID,VisitDate,Diagnosis,Prescription) VALUES
(1,1,'2026-10-02','Hypertension','Medication A'),
(2,2,'2026-10-04','Migraine','Medication B'),
(3,3,'2026-10-06','Knee pain','Physiotherapy'),
(4,4,'2026-10-08','Seasonal fever','Rest and fluids'),
(5,5,'2026-10-10','Skin allergy','Topical cream'),
(6,6,'2026-10-12','Ear infection','Medication C'),
(7,7,'2026-10-14','Viral fever','Medication D'),
(8,8,'2026-10-16','Eye irritation','Eye drops'),
(9,9,'2026-10-18','Anaemia review','Supplement advice'),
(10,10,'2026-10-20','Tooth decay','Dental treatment');

INSERT INTO dbo.Billing (VisitID,BillAmount,Status) VALUES
(1,800,'Paid'),(2,650,'Open'),(3,1200,'Pending'),(4,500,'Paid'),
(5,900,'Open'),(6,700,'Paid'),(7,450,'Pending'),(8,600,'Open'),
(9,1500,'Paid'),(10,1100,'Open');
GO

-- ALTER TABLE: add insurance_id to Patient.
ALTER TABLE dbo.Patient ADD InsuranceID VARCHAR(30) NULL;
UPDATE dbo.Patient SET InsuranceID = 'INS-' + RIGHT('000' + CAST(PatientID AS VARCHAR(3)),3)
WHERE PatientID <= 3;
SELECT PatientID, PatientName, InsuranceID FROM dbo.Patient;
GO

-- Rename Billing to PatientBilling.
EXEC sys.sp_rename 'dbo.Billing', 'PatientBilling';
GO

-- Demonstrate dropping a constraint, then restore it to keep the final schema safe.
ALTER TABLE dbo.PatientBilling DROP CONSTRAINT CK_Billing_BillAmount;
GO

BEGIN TRANSACTION;
UPDATE dbo.PatientBilling
SET BillAmount = -100
WHERE VisitID = 10; -- succeeds only while the CHECK constraint is absent
SELECT * FROM dbo.PatientBilling WHERE BillAmount < 0;
ROLLBACK TRANSACTION;
GO

-- Recreate the CHECK constraint after the demonstration.
ALTER TABLE dbo.PatientBilling
ADD CONSTRAINT CK_PatientBilling_BillAmount CHECK (BillAmount >= 0);
GO

-- CRUD examples.
UPDATE dbo.Patient SET AddressLine = '22 Lake View'
WHERE PatientID = 1;

SELECT * FROM dbo.Patient WHERE PatientID = 1;

DELETE FROM dbo.PatientBilling
WHERE VisitID = 10 AND Status = 'Open';

-- Restore the sample billing row for the final joins.
INSERT INTO dbo.PatientBilling (VisitID,BillAmount,Status)
VALUES (10,1100,'Open');
GO

-- Patients who visited during October 2026.
SELECT p.PatientID, p.PatientName, v.VisitDate, v.Diagnosis
FROM dbo.Patient AS p
JOIN dbo.Visit AS v ON p.PatientID = v.PatientID
WHERE v.VisitDate >= '20261001'
  AND v.VisitDate < '20261101'
ORDER BY v.VisitDate;

-- Doctors in a department using WHERE and LIKE.
SELECT d.DoctorName, dep.DepartmentName
FROM dbo.Doctor AS d
JOIN dbo.Department AS dep ON d.DepartmentID = dep.DepartmentID
WHERE dep.DepartmentName LIKE '%Cardiology%';
GO

-- Final billing/visit view.
SELECT p.PatientName, d.DoctorName, v.VisitDate, v.Diagnosis,
       pb.BillAmount, pb.Status
FROM dbo.Visit AS v
JOIN dbo.Patient AS p ON v.PatientID = p.PatientID
JOIN dbo.Doctor AS d ON v.DoctorID = d.DoctorID
JOIN dbo.PatientBilling AS pb ON v.VisitID = pb.VisitID
ORDER BY v.VisitDate;
GO

--------------Create the database---------------
USE master ;
DROP DATABASE IF EXISTS UniversityDB;
GO
CREATE DATABASE UniversityDB;
GO

------------------ Use the database -------------------
USE UniversityDB;
GO
--------------------- Create the Schemas----------------------

CREATE SCHEMA STG ; ---for Data Source

CREATE SCHEMA Students; -- Student
CREATE SCHEMA Feedback; --Feedback_Questions, Feedback_Student
CREATE SCHEMA HumanResources; -- Departmant, Instructor
CREATE SCHEMA Cources; --Cource , program, Student_Cource

GO
------------------------- Count Table = 8 ----------------
-------------------------------------------------------------
-------------------- Create Department table----------------
CREATE TABLE HumanResources.Department (
    DID INT IDENTITY(1,1), -- Primary Key constraint
    Dname NVARCHAR(100) NOT NULL, 
	CONSTRAINT PK_Department_DID PRIMARY KEY (DID)
);
GO
-------------------- Load Department table----------------
INSERT INTO [HumanResources].[Department] ([Dname])
SELECT DISTINCT [Teacher_department] 
FROM [UniversityDB].[STG].[Data]
where [Teacher_department] is not null;

Go

-------------- Create Program table ------------------
CREATE TABLE Students.Program (
    PID INT IDENTITY(100,1),
    Department NVARCHAR(100) NOT NULL,
    Specialization NVARCHAR(100) NOT NULL,
    PDescription NVARCHAR(255),
	CONSTRAINT PK_Program_PID PRIMARY KEY (PID)
);
GO
-------------- Load Program table ------------------
INSERT INTO [Students].[Program] ([Department], [Specialization], [PDescription])
SELECT DISTINCT [department], [specialization], (N'يدرس '+[department]+N' شعبة'+[specialization]) [PDescription]
FROM [UniversityDB].[STG].[Data]
--where [Teacher_department] is not null;
Go
-------------- Create Student table ----------------------
CREATE TABLE Students.Student (
    S_ID INT ,
    Sname NVARCHAR(100) NOT NULL,
    Semail NVARCHAR(100) NOT NULL UNIQUE,
    SStatus NVARCHAR(20) NOT NULL,
    Slevel CHAR NOT NULL,       
    PID INT NOT NULL,
	CONSTRAINT PK_Student_S_ID PRIMARY KEY (S_ID), -- Primary Key constraint
    CONSTRAINT FK_Student_Program FOREIGN KEY (PID) REFERENCES Students.Program(PID) -- Foreign Key for Program

	
);

GO

-------------- Load Student table ----------------------
INSERT INTO [Students].[Student] ([S_ID], [Sname], [Semail], [SStatus], [Slevel], [PID])
SELECT DISTINCT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], [student_name], [student_email], [student_status], [studentGrade], [Students].[Program].[PID]
FROM [UniversityDB].[STG].[Data]
join [UniversityDB].[Students].[Program] 
ON [UniversityDB].[Students].[Program].[Department] = [UniversityDB].[STG].[Data].department
and [UniversityDB].[Students].[Program].[Specialization] = [UniversityDB].[STG].[Data].specialization;



Go
----------------- Create Instructor table-------------
--Drop TABLE HumanResources.Instructor
CREATE TABLE HumanResources.Instructor (
    InsID INT  , -- Primary Key constraint
    Ins_name NVARCHAR(100) NOT NULL,
    Degree NVARCHAR(100),
    Ins_Phone NVARCHAR(100),
    Ins_email NVARCHAR(255) NOT NULL UNIQUE,
    DID INT NOT NULL,  -- Foreign key for Department
	CONSTRAINT PK_Instructor_InsID PRIMARY KEY (InsID),
    CONSTRAINT FK_Instructor_Department FOREIGN KEY (DID) REFERENCES HumanResources.Department(DID) -- Foreign Key constraint
);
GO
----------------- Load Instructor table-------------
INSERT INTO [HumanResources].[Instructor] ([InsID], [Ins_name], [Degree], [Ins_Phone], [Ins_email], [DID])
SELECT distinct (CAST(SUBSTRING(([Teacher_name]), 12, 18) AS int))[Teacher_ID], [Teacher_name], [Teacher_degree], [Teacher_telephone], [Teacher_email], [HumanResources].[Department].[DID]
FROM [UniversityDB].[STG].[Data]
join [UniversityDB].[HumanResources].[Department] 
ON [UniversityDB].[HumanResources].[Department].[Dname] = [UniversityDB].[STG].[Data].[Teacher_department]
where [Teacher_name] is not null;
Go
------------Create cource table-----------------
--drop table Cources.cource
CREATE TABLE Cources.cource (
    CID INT , 
    Cname NVARCHAR(255), 
	gradelevel char, 
    score_written FLOAT, 
    with_written BIT, 
    Bubble_sheet NVARCHAR(255),
    InsID INT,      -- Foreign key for Instructor
    PID INT NOT NULL,        -- Foreign key for Program
	CONSTRAINT PK_cource_CID PRIMARY KEY( CID),
    CONSTRAINT FK_cource_Instructor FOREIGN KEY (InsID) REFERENCES HumanResources.Instructor(InsID), -- Foreign Key constraint
    CONSTRAINT FK_cource_Program FOREIGN KEY (PID) REFERENCES Students.Program(PID) -- Foreign Key constraint
);
GO
------------Load cource table-----------------
INSERT INTO [Cources].[cource] ([CID], [Cname], [gradelevel], [score_written], [with_written], [Bubble_sheet], [InsID], [PID])
SELECT distinct (CAST(SUBSTRING(([subject_code]), 9, 18) AS int))[CID], [subject_title], [subject_Grade],[score_written], [with_written], [Bubble_sheet],(CAST(SUBSTRING(([Teacher_name]), 12, 18) AS int))[InsID], [Students].[Program].[PID]
FROM [UniversityDB].[STG].[Data]
join [UniversityDB].[Students].[Program] 
ON [UniversityDB].[Students].[Program].[Department] = [UniversityDB].[STG].[Data].department
and [UniversityDB].[Students].[Program].[Specialization] = [UniversityDB].[STG].[Data].specialization
Go
------------Create Student_cource table == Gether from Relationship(Study) -----------------
--drop table Cources.Student_cource
CREATE TABLE Cources.Student_cource(
    S_ID INT, 
    CID INT, 
	score_Grade Float,
	score_percent FLOAT,
    CONSTRAINT PK_Student_cource PRIMARY KEY (S_ID, CID),
    CONSTRAINT FK_Student_S_ID  FOREIGN KEY (S_ID) REFERENCES Students.Student(S_ID),
    CONSTRAINT FK_student_cource_CID FOREIGN KEY (CID) REFERENCES Cources.Cource(CID)

	);
GO

------------Load Student_cource table -----------------
INSERT INTO [Cources].[Student_cource] ([S_ID], [CID], [score_Grade], [score_percent])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], [Cources].[cource].[CID], [STG].[Data].[score], [STG].[Data].[percent]
FROM [UniversityDB].[STG].[Data]
join [UniversityDB].[Cources].[cource]
ON [UniversityDB].[STG].[Data].[subject_title] = [UniversityDB].[Cources].[cource].[Cname]
Go
---------------------------------------------------------------
----------------------------- Feedback -------------------------
------------------------------------------------------------
---------- Create Feedback_Questions table----------------

CREATE TABLE Feedback.Feedback_Questions (
   	QuestionID INT  ,
	QuestionCategory NVARCHAR(50),
	QuestionText NVARCHAR(Max) ,   
	CONSTRAINT PK_Feedback_QuestionID PRIMARY KEY (QuestionID),
    
);
GO
---------- Load Feedback_Questions table----------------
INSERT INTO [Feedback].[Feedback_Questions] ([QuestionID], [QuestionCategory], [QuestionText])
SELECT [w] AS [QuestionID], N'تقييم محتوى المقرر' AS [QuestionCategory], [تقييم محتوى المقرر] AS [QuestionText]
FROM [UniversityDB].[STG].[Question_Text]
where [w] is not null
Go
----------------
INSERT INTO [Feedback].[Feedback_Questions] ([QuestionID], [QuestionCategory], [QuestionText])
SELECT [x] AS [QuestionID], N'تقييم عضو هيئة التدريس' AS [QuestionCategory], [تقييم عضو هيئة التدريس] AS [QuestionText]
FROM [UniversityDB].[STG].[Question_Text]
where [x] is not null
Go
------------------
INSERT INTO [Feedback].[Feedback_Questions] ([QuestionID], [QuestionCategory], [QuestionText])
SELECT [y] AS [QuestionID], N'تقييم الامتحانات والتكليفات' AS [QuestionCategory], [تقييم الامتحانات والتكليفات] AS [QuestionText]
FROM [UniversityDB].[STG].[Question_Text]
where [y] is not null
Go
------------------
INSERT INTO [Feedback].[Feedback_Questions] ([QuestionID], [QuestionCategory], [QuestionText])
SELECT [z] AS [QuestionID], N'تقييم صفحة المقرر' AS [QuestionCategory], [تقييم صفحة المقرر] AS [QuestionText]
FROM [UniversityDB].[STG].[Question_Text]
where [z] is not null
Go
-----------------
INSERT INTO [Feedback].[Feedback_Questions] ([QuestionID], [QuestionCategory], [QuestionText])
SELECT [Text] AS [QuestionID], N'الأسئلة المفتوحة' AS [QuestionCategory], [الأسئلة المفتوحة] AS [QuestionText]
FROM [UniversityDB].[STG].[Question_Text]
where [Text] is not null
Go
---------Create Feedback_Student table == Gether from Relationship(Response) -------------

CREATE TABLE Feedback.Student_Feedback (
    S_ID INT NOT NULL,         -- Foreign key for Student
    CID INT NOT NULL,         -- Foreign Key For Cource  
	QuestionID INT NOT NULL,  -- Foreign key for Feedback_Question
    Response nvarchar(max)
    CONSTRAINT PK_Student_Feedback PRIMARY KEY (S_ID,CID,QuestionID), -- Composite Primary Key constraint
    CONSTRAINT FK_Response_Student FOREIGN KEY (S_ID) REFERENCES Students.Student(S_ID), -- Foreign Key constraint
	CONSTRAINT FK_Response_Cource FOREIGN KEY (CID) REFERENCES Cources.Cource(CID),  --Foreign Key constraint
    CONSTRAINT FK_Response_FeedbackQuestion FOREIGN KEY (QuestionID) REFERENCES Feedback.Feedback_Questions(QuestionID) -- Foreign Key constraint
);
GO
---------Load Feedback_Student table-------------
---100--w-----
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 100 AS [QuestionID], [STG].[Data].[w1]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w1] is not null 
Go
---101-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 101 AS [QuestionID], [STG].[Data].[w2]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w2] is not null 
GO
---102-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 102 AS [QuestionID], [STG].[Data].[w3]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w3] is not null 
GO
---103-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 103 AS [QuestionID], [STG].[Data].[w4]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w4] is not null 
GO
---104-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 104 AS [QuestionID], [STG].[Data].[w5]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w5] is not null 
GO
---105-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 105 AS [QuestionID], [STG].[Data].[w6]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w6] is not null 
GO
---106-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 106 AS [QuestionID], [STG].[Data].[w7]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w7] is not null 
GO
---107-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 107 AS [QuestionID], [STG].[Data].[w8]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w8] is not null 
GO
---108-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 108 AS [QuestionID], [STG].[Data].[w9]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w9] is not null 
GO
---109-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 109 AS [QuestionID], [STG].[Data].[w10]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w10] is not null 
GO
---110-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 110 AS [QuestionID], [STG].[Data].[w11]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[w11] is not null 
GO
---200---x----
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 200 AS [QuestionID], [STG].[Data].[x1]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x1] is not null 
GO
---201-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 201 AS [QuestionID], [STG].[Data].[x2]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x2] is not null 
GO
---202-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 202 AS [QuestionID], [STG].[Data].[x3]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x3] is not null 
GO

---203---x----
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 203 AS [QuestionID], [STG].[Data].[x4]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x4] is not null 
GO

---204-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 204 AS [QuestionID], [STG].[Data].[x5]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x5] is not null 
GO

---205-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 205 AS [QuestionID], [STG].[Data].[x6]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x6] is not null 
GO

---206-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 206 AS [QuestionID], [STG].[Data].[x7]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x7] is not null 
GO

---207-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 207 AS [QuestionID], [STG].[Data].[x8]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x8] is not null 
GO

---208-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 208 AS [QuestionID], [STG].[Data].[x9]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x9] is not null 
GO

---209-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 209 AS [QuestionID], [STG].[Data].[x10]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x10] is not null 
GO

---210-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 210 AS [QuestionID], [STG].[Data].[x11]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x11] is not null 
GO

---211-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 211 AS [QuestionID], [STG].[Data].[x12]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x12] is not null 
GO

---212-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 212 AS [QuestionID], [STG].[Data].[x13]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x13] is not null 
GO

---213-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 213 AS [QuestionID], [STG].[Data].[x14]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[x14] is not null 
GO

---300---y----
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 300 AS [QuestionID], [STG].[Data].[y1]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[y1] is not null 
GO

---301-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 301 AS [QuestionID], [STG].[Data].[y2]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[y2] is not null 
GO

---302-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 302 AS [QuestionID], [STG].[Data].[y3]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[y3] is not null 
GO

---303-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 303 AS [QuestionID], [STG].[Data].[y4]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[y4] is not null 
GO

---304-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 304 AS [QuestionID], [STG].[Data].[y5]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[y5] is not null 
GO

---305-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 305 AS [QuestionID], [STG].[Data].[y6]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[y6] is not null 
GO

---400---z----
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 400 AS [QuestionID], [STG].[Data].[z1]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[z1] is not null 
GO

---401-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 401 AS [QuestionID], [STG].[Data].[z2]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[z2] is not null 
GO

---402-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 402 AS [QuestionID], [STG].[Data].[z3]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[z3] is not null 
GO

---403-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 403 AS [QuestionID], [STG].[Data].[z4]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[z4] is not null 
GO

---404-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 404 AS [QuestionID], [STG].[Data].[z5]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[z5] is not null 
GO

---405-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 405 AS [QuestionID], [STG].[Data].[z6]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[z6] is not null 
GO

---406-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 406 AS [QuestionID], [STG].[Data].[z7]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[z7] is not null 
GO

---407-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 407 AS [QuestionID], [STG].[Data].[z8]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[z8] is not null 
GO

---500---open----
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 500 AS [QuestionID], [STG].[Data].[Pros]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[Pros] is not null 
GO

---501-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 501 AS [QuestionID], [STG].[Data].[Cons]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[Cons] is not null 
GO

---502-------
INSERT INTO [Feedback].[Student_Feedback] ([S_ID], [CID], [QuestionID], [Response])
SELECT CAST(SUBSTRING([student_id], 9, 15) AS int)[student_id], CAST(SUBSTRING([subject_code], 9, 18) AS int)[CID], 502 AS [QuestionID], [STG].[Data].[Suggestions]
FROM [UniversityDB].[STG].[Data]
--where [UniversityDB].[STG].[Data].[Suggestions] is not null 
GO


------------------------------------1.2 VERSION---------------------------------------------
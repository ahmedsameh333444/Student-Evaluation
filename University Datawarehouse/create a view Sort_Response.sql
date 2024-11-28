USE UniversityDB;
GO

drop view Sort_Response
CREATE VIEW Sort_Response AS
SELECT 
  Feedback.Student_Feedback.S_ID,
  Feedback.Student_Feedback.CID,
  Feedback.Student_Feedback.QuestionID,
  
  -- Handling open questions
  CAST(MAX(CASE 
    WHEN Feedback.Student_Feedback.QuestionID BETWEEN 500 AND 502 
    THEN Feedback.Student_Feedback.Response 
  END) AS NVARCHAR(4000)) AS open_questions,

  -- Handling course page evaluation
  CAST(MAX(CASE 
    WHEN Feedback.Student_Feedback.QuestionID BETWEEN 400 AND 407 
    THEN Feedback.Student_Feedback.Response 
  END) AS INT) AS course_page_evaluation,

  -- Handling exam evaluation
  CAST(MAX(CASE 
    WHEN Feedback.Student_Feedback.QuestionID BETWEEN 300 AND 305 
    THEN Feedback.Student_Feedback.Response 
  END) AS INT) AS exam_evaluation,

  -- Handling instructor evaluation
  CAST(MAX(CASE 
    WHEN Feedback.Student_Feedback.QuestionID BETWEEN 200 AND 213 
    THEN Feedback.Student_Feedback.Response 
  END) AS INT) AS instructor_evaluation,

  -- Handling general evaluation
  CAST(MAX(CASE 
    WHEN Feedback.Student_Feedback.QuestionID BETWEEN 100 AND 110 
    THEN Feedback.Student_Feedback.Response 
  END) AS INT) AS cource_evaluation

FROM 
  Feedback.Student_Feedback
GROUP BY 
  Feedback.Student_Feedback.S_ID,
  Feedback.Student_Feedback.CID,
  Feedback.Student_Feedback.QuestionID;
GO
select * from Sort_Response

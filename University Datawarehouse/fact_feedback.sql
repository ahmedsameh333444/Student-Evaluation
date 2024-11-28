use UniversityDWH;
go 
if exists(select * 
          from sys.tables
		  where name='fact_feedback')
		  drop table fact_feedback;

create table fact_feedback(
fact_key int identity(1,1) not null , --surrogate key 
S_key int not null,
C_key int not null,
question_key int not null,
ins_key int not null,
date_key date ,
cource_evaluation int,
instructor_evaluation int,
exam_evaluation int,
cource_page_evaluation int,
open_questions nvarchar(max),
score_percent float, 
constraint pk_fact_key primary key clustered (fact_key),
constraint fk_dim_student foreign key (S_key) references  dim_student(S_key),
constraint fk_dim_cource foreign key (C_key) references  dim_cource(C_key),
constraint fk_dim_feedbackquestions foreign key (question_key) references  dim_feedbackquestions(question_key),
constraint fk_dim_instructor foreign key (ins_key) references  dim_instructor(ins_key),
--constraint fk_dim_date foreign key (date_key) references dim_date(date_key)
)

------creat indxes
if exists(select * 
          from sys.indexes
		  where name ='fact_feedback_dim_cource'
		  and object_id=Object_id('fact_feedback'))
		  drop index fact_feedback.fact_feedback_dim_cource
create index fact_feedback_dim_cource
on fact_feedback(C_key);

if exists(select * 
          from sys.indexes
		  where name ='fact_feedback_dim_feedbackquestions'
		  and object_id=Object_id('fact_feedback'))
		  drop index fact_feedback.fact_feedback_dim_feedbackquestions
create index fact_feedback_dim_feedbackquestions
on fact_feedback(question_key);

if exists(select * 
          from sys.indexes
		  where name ='fact_feedback_dim_instructor'
		  and object_id=Object_id('fact_feedback'))
		  drop index fact_feedback.fact_feedback_dim_instructor
create index fact_feedback_dim_instructor
on fact_feedback(ins_key);

if exists(select * 
          from sys.indexes
		  where name ='fact_feedback_dim_student'
		  and object_id=Object_id('fact_feedback'))
		  drop index fact_feedback.fact_feedback_dim_student
create index fact_feedback_dim_student
on fact_feedback(S_key);

use UniversityDWH;
go

if exists ( select * 
            from sys.tables
			where name ='dim_feedbackquestions')
			drop table dim_feedbackquestions

create table dim_feedbackquestions(
question_key int identity(1,1) not null ,--- surrgate key
question_id int not null,
question_tex nvarchar(max),
question_category nvarchar(50)
constraint pk_dim_feedbackquestions primary key clustered (question_key)
)
----- create forgien key
 if exists (select * 
             from sys.tables
			 where name ='fact_feedback')
			 alter table fact_feedback
			 add constraint fk_fact_feedback_dim_feedbackquestions foreign key (question_key)
			 references dim_feedbackquestions(question_key); 
------ create index
if exists (select * 
           from sys.indexes
		   where name ='dim_feedbackquestions_question_id'
		   and object_id=Object_id('dim_feedbackquestions'))
		   drop index dim_feedbackquestions.dim_feedbackquestions_question_id

	create index dim_feedbackquestions_question_id
	on dim_feedbackquestions(question_id)
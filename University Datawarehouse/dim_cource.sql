use UniversityDWH;
go
 if exists ( select * 
             from sys.tables 
			 where name ='dim_cource')
			 drop table dim_cource 

create table dim_cource (
C_key int identity (1,1) not null, ---surrogate key
C_id int not null,
C_name nvarchar(255),
score_written float,
with_written bit,
bubble_sheet nvarchar(255)
constraint pk_dim_cource primary key clustered (C_key)
)

-----create forgien key 
if exists (select * 
          from sys.tables 
		  where name= 'fact_feedback')
		  alter table fact_feedback 
		  add constraint fk_fact_feedback_dim_cource foreign key (C_key)
		  references dim_cource(C_key);

------- create index 
if exists ( select * 
           from sys.indexes
		   where name='dim_cource_C_id'
		   and object_id=Object_id('dim_cource'))
		   drop index dim_course.dim_cource_C_id

create index dim_cource_C_id
on dim_cource(C_id)
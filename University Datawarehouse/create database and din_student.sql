create database UniversityDWH;
go 
use UniversityDWH;
---------------create table dim_student ---------
if exists ( select * 
            from sys.objects 
			where name='dim_student'
			and type='U' )
			drop table dim_student
			go

create table dim_student(
S_key int identity(1,1) not null ,---- surrogate key
S_id int not null , 
Sname nvarchar(400),
Semail nvarchar(400),
Sstatus nvarchar(20),
Slevel char(1),
Dname nvarchar(100),
Specialization nvarchar(100)
constraint pk_dim_student primary key clustered (S_key)
)
------ create foreign key
if exists (select * 
           from sys.tables
		   where name ='fact_feedback')
		   alter table fact_feedback
		   add constraint fk_fact_feedback_dim_student foreign key (S_key)
		   references dim_student(S_key);


-----create index
if exists (select * 
           from sys.indexes
		   where name ='dim_student_S_id'
		   AND object_id = Object_id('dim_student'))
		   drop index dim_student.dim_student_S_id
		   
create index dim_student_S_id
on dim_student(S_id)

use UniversityDWH;
go
if exists (select *     
           from sys.tables 
		   where name='dim_instructor')
		   drop table dim_instructor

create table dim_instructor(
ins_key int identity(1,1) not null , ----- surrogate key
ins_id int not null,
ins_name nvarchar(100),
degree nvarchar(100),
ins_phone nvarchar(100),
ins_email nvarchar(255),
constraint pk_dim_instructor primary key clustered (ins_key)

)
---------- create forgien key
if exists ( select * 
            from sys.tables
			where name ='fact_feedback')
			alter table fact_feedback
			add constraint fk_fact_table_dim_instructor foreign key (ins_key)
			references dim_instructor(ins_key)


	----- create index
	if exists (select * 
	           from sys.indexes
			   where name='dim_instructor_ins_id'
			and object_id=Object_id('dim_instructor'))
			drop index dim_instructor.dim_instructor_ins_id

create index  dim_instructor_ins_id
on dim_instructor(ins_id)
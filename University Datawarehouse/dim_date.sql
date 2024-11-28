use UniversityDWH;
go
if exists (select *  
          from sys.tables 
		  where name = 'dim_date')
		  drop table dim_date;

create table dim_date (
date_key int identity(1,1)  not null ,---- surrogate key
full_data date not null,
day int,
mounth int ,
quareter int ,
year int 
constraint pk_dim_date primary key clustered (date_key)
)

----create forigen key
if exists(select *
          from sys.tables
		  where name ='fact_feedback')
		  alter table fact_feedback
		  add constraint fk_fact_feedback_dim_date foreign key (date_key)
		  references dim_date(date_key)

		  
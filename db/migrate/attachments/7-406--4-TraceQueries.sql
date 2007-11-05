--TraceQueries
--VBoerner 
--02/27/2007


--Pattern Matching on TextData
select *
from dbo.ectsqldev01_030207B
where 
    --TextData like 'exec dbo.Trav%' 
    --TextData like '%6000[^36]%'


--ORDER BY with Date range filter
--NOTE: As TextData is a NVarchar column, you will need to
--      cast it per below to use ORDER BY or other string
--      manipulation functions.
select StartTime, cast(textdata as varchar(2000))
from dbo.ECTSQLDEV01_030107
where StartTime between '2007-03-01 12:30:00.047' and '2007-03-01 12:35:50.173'
order by cast(textdata as varchar(2000))


--Database Name
--NOTE: This will only work on the same server 
--      that the trace was generated from.
select d.name, t.*
from dbo.ECTSQLDEV01_030107 t
join master..sysdatabases d on t.DatabaseID = d.dbid
where d.name like '%_A'  --DB Name filter


--DatabaseID lookup
select *
from master..sysdatabases


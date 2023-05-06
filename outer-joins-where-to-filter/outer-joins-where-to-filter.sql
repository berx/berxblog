-- check also: 
--  https://berxblog.blogspot.com/2023/05/outer-joins-where-to-filter.html
--  https://livesql.oracle.com/apex/livesql/s/o49x9l41t82npiyx9ccoypghu

CREATE TABLE "PAR" 
   (	"ID" NUMBER, 
	"P_NAME" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP", 
	 CONSTRAINT "PAR_PK" PRIMARY KEY ("ID")
	 )
;

REM INSERTING into BERX.PAR
SET DEFINE OFF;
Insert into PAR (ID,P_NAME) values ('1','P_one');
Insert into PAR (ID,P_NAME) values ('2','P_two');
Insert into PAR (ID,P_NAME) values ('3','P_three');
Insert into PAR (ID,P_NAME) values ('4','P_four');
-- drop table CLD;

CREATE TABLE "CLD" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"P_ID" NUMBER NOT NULL ENABLE, 
	"C_NAME" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"AGE_RANGE" NUMBER(2,0) NOT NULL ENABLE, 
	 CONSTRAINT "CLD_PK" PRIMARY KEY ("ID") ,
     CONSTRAINT "CLD_PAR_FK" FOREIGN KEY ("P_ID")
	  REFERENCES "PAR" ("ID") ENABLE	 
);	 

REM INSERTING into BERX.CLD
SET DEFINE OFF;
Insert into CLD (ID,P_ID,C_NAME,AGE_RANGE) values ('1','1','1_10','10');
Insert into CLD (ID,P_ID,C_NAME,AGE_RANGE) values ('2','2','2_10','10');
Insert into CLD (ID,P_ID,C_NAME,AGE_RANGE) values ('3','3','3_10','10');
Insert into CLD (ID,P_ID,C_NAME,AGE_RANGE) values ('4','4','4_20','20');

commit;

------------------------ Preparation done --------------------

select /* ANSI 1 */ pr.*, cd.*
from par pr left outer join cld cd on (pr.id = cd.p_id and age_range > 10)
;

explain plan for select /* ANSI 1 */ pr.*, cd.*
from par pr left outer join cld cd on (pr.id = cd.p_id and age_range > 10)
;
select * from dbms_xplan.display();

select * from dbms_xplan.display_cursor( sql_id => (
select /* xxx */ sql_id --, sql_text
from v$sql 
where sql_text like '%ANSI 1%' and sql_text not like '% xxx %' and sql_text not like 'explain%' 
                                                    ) , 
    format => 'ALL +adaptive')
;

select /* ANSI 2 */  pr.*, cd.*
from par pr left outer join cld cd on pr.id = cd.p_id 
where age_range > 10
;

explain plan for select /* ANSI 2 */  pr.*, cd.*
from par pr left outer join cld cd on pr.id = cd.p_id 
where age_range > 10
;
select * from dbms_xplan.display();

select * from dbms_xplan.display_cursor( sql_id => (
select /* xxx */ sql_id --, sql_text
from v$sql 
where sql_text like '%ANSI 2%' and sql_text not like '% xxx %' and sql_text not like 'explain%' 
                                                    ) , 
    format => 'ALL +adaptive')
;

select /*+ ANSI 3 */  pr.*, cd.*
from par pr left outer join 
     (select /*+ NO_MERGE */ * from cld where age_range > 10 ) cd 
                                   on pr.id = cd.p_id 
;

explain plan for select /*+ ANSI 3 */  pr.*, cd.*
from par pr left outer join 
     (select /*+ NO_MERGE */ * from cld where age_range > 10 ) cd 
                                   on pr.id = cd.p_id 
;
select * from dbms_xplan.display();

select * from dbms_xplan.display_cursor( sql_id => (
select /* xxx */ sql_id --, sql_text
from v$sql 
where sql_text like '%ANSI 3%' and sql_text not like '% xxx %' and sql_text not like 'explain%' 
                                                    ) , 
    format => 'ALL +adaptive')
;


select /* Oracle 2 */  pr.*, cd.*
from par pr , cld cd
where pr.id = p_id (+)
  and cd.age_range > 10
;

explain plan for select /* Oracle 2 */  pr.*, cd.*
from par pr , cld cd
where pr.id = p_id (+)
  and cd.age_range > 10
;
select * from dbms_xplan.display();


select * from dbms_xplan.display_cursor( sql_id => (
select /* xxx */ sql_id --, sql_text
from v$sql 
where sql_text like '% Oracle 2 %' and sql_text not like '% xxx %' and sql_text not like 'explain%' 
                                                    ) , 
    format => 'ALL +adaptive')
;


select /* Oracle 1 */  pr.*, cd.*
from par pr , cld cd
where pr.id = p_id (+)
  and cd.age_range (+)> 10 
;

explain plan for select /* Oracle 1 */  pr.*, cd.*
from par pr , cld cd
where pr.id = p_id (+)
  and cd.age_range (+)> 10 
;
select * from dbms_xplan.display();

select * from dbms_xplan.display_cursor( sql_id => (
select /* xxx */ sql_id --, sql_text
from v$sql 
where sql_text like '%ANSI 1%' and sql_text not like '% xxx %' and sql_text not like 'explain%' 
                                                    ) , 
    format => 'ALL +adaptive')
;


select /* Oracle 3 */  pr.*, cd.*
from par pr , 
     ( select  /*+ NO_MERGE */ * from cld where age_range > 10 ) cd
where pr.id = p_id (+)
;

explain plan for select /* Oracle 3 */  pr.*, cd.*
from par pr , 
     ( select  /*+ NO_MERGE */ * from cld where age_range > 10 ) cd
where pr.id = p_id (+)
;
select * from dbms_xplan.display();

select * from dbms_xplan.display_cursor( sql_id => (
select /* xxx */ sql_id --, sql_text
from v$sql 
where sql_text like '%ANSI 1%' and sql_text not like '% xxx %' and sql_text not like 'explain%' 
                                                    ) , 
    format => 'ALL +adaptive')
;

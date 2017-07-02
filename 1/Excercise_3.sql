--Excercise 3------------------------------------------------------
--Clear plan table
delete from plan_table;
--Explain...
explain plan for
SELECT c.name, o.price, o.profit
FROM customers c JOIN orders o ON c.id=o.customer_id
WHERE profitlevel='High' AND age=50 and credit_limit=5000;
--3.1
SELECT COST FROM PLAN_TABLE WHERE ID=0;--Best Estimated Cost

SELECT CPU_COST,IO_COST FROM PLAN_TABLE where id=0;--Costs

--3.2
SELECT CARDINALITY FROM PLAN_TABLE WHERE ID=0;--Estimated rows to be returned.
--Number of Rows actually returned.
SELECT count(*) as cardinality
FROM customers c JOIN orders o ON c.id=o.customer_id
WHERE profitlevel='High' AND age=50 and credit_limit=5000;
--In order to find the Planner's execution plan...
select id, parent_id, operation, object_name,filter_predicates  from plan_table
start with id=0
connect by prior id=parent_id;

--3.3
--CREATE INDEXES
CREATE INDEX IND_PROFIT ON ORDERS(PROFITLEVEL) ;
CREATE INDEX IND_AGE ON CUSTOMERS(AGE);
CREATE INDEX IND_CRED ON CUSTOMERS(CREDIT_LIMIT);

--RERUN EXPLAIN
EXPLAIN PLAN FOR
SELECT c.name, o.price, o.profit
FROM customers c JOIN orders o ON c.id=o.customer_id
WHERE profitlevel='High' AND age=50 and credit_limit=5000;

SELECT PLAN_ID,COST FROM PLAN_TABLE WHERE ID=0;
--Returns 2 different costs for plans with and without the indexes.

----------------------------------------------------------------------
commit;

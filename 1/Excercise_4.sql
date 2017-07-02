--Excercise 4------------------------------------------------------
--Clear plan table
delete from plan_table;
--Drop all indexes
DROP INDEX IND_PROFIT ;
DROP INDEX IND_AGE ;
DROP INDEX IND_CRED;

--4.1
--Explain for new query.
EXPLAIN PLAN FOR
SELECT c.name, o.price, o.profit
FROM customers c JOIN orders o ON c.id=o.customer_id
WHERE profitlevel='High' AND age=50 and credit_limit>5000;

SELECT COST FROM PLAN_TABLE WHERE ID=0;--Best Estimated Cost

SELECT CPU_COST,IO_COST FROM PLAN_TABLE where id=0;--Costs

--4.2
--CREATE INDEXES
CREATE INDEX IND_PROFIT ON ORDERS(PROFITLEVEL) ;
CREATE INDEX IND_AGE ON CUSTOMERS(AGE);
CREATE INDEX IND_CRED ON CUSTOMERS(CREDIT_LIMIT);

--RERUN EXPLAIN
EXPLAIN PLAN FOR
SELECT c.name, o.price, o.profit
FROM customers c JOIN orders o ON c.id=o.customer_id
WHERE profitlevel='High' AND age=50 and credit_limit>5000;

SELECT PLAN_ID,COST FROM PLAN_TABLE WHERE ID=0;
--Returns 2 different costs for plans with and without the indexes.
-----------------------------------------------------------------------
commit;

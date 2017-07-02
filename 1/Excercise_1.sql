--ENVIRONMENT SETUP------------------------------------------------------
SET serveroutput ON;
alter session set nls_date_format='DD-MM-YYYY';
drop table orders;
drop table customers;

--FUNCTIONS--------------------------------------------------------------

--Computes age of customer...
create or replace FUNCTION customer_age( x IN DATE )
RETURN INT IS
 age INT := 0;
BEGIN
  age := SYSDATE - TO_DATE(x, 'DD-MM-YYYY');
  age := age/365;
  RETURN age;
END;
/

--Computes profit of order...
create or replace FUNCTION order_profit( price IN NUMBER , cost IN NUMBER )
RETURN NUMBER IS
  profit NUMBER := 0.00;
BEGIN
  profit := price - cost;
  RETURN profit;
END;
/

--Finds profitlevel of order...
create or replace FUNCTION profit_level( price IN NUMBER , cost IN NUMBER )
RETURN VARCHAR IS
  profitlevel VARCHAR(6) := 'NONE';
BEGIN
  IF( order_profit(price,cost)< 1000.00 ) THEN
    RETURN 'Low';
  ELSIF( order_profit(price,cost)< 5000.00 ) THEN
    RETURN 'Medium';
  ELSE
    RETURN 'High';
  END IF;
END;
/

--Excercise 1------------------------------------------------------

--Table creation for customers...
create table customers(
id number NOT NULL,
name varchar2(65) NOT NULL,
gender varchar2(10) NOT NULL,
age number NOT NULL,
marital_status varchar2(20),
income_level varchar2(30),
credit_limit number
);

--Fill the 'customers' table...
DECLARE
  cust xsales.customers%rowtype; --Record of original customers table
  cursor cust_cursor is select * from xsales.customers; --Cursor
  age INT;
BEGIN
  Open cust_cursor;
  Loop --For each row/record...
    Fetch cust_cursor into cust;
    age:=customer_age(cust.birth_date); --find age
    insert into CUSTOMERS(ID,NAME,AGE,GENDER,MARITAL_STATUS,INCOME_LEVEL,CREDIT_LIMIT) values(cust.id,cust.name,age,cust.gender,cust.marital_status,cust.income_level,cust.credit_limit);
    Exit when cust_cursor%Notfound;
  End loop;
  Close cust_cursor;
END;
/

--Table creation for orders...
create table orders(
order_id number NOT NULL,
customer_id number NOT NULL,
price NUMBER(10,2) NOT NULL,
cost NUMBER(10,2) NOT NULL,
profit NUMBER(10,2) NOT NULL,
profitlevel VARCHAR(6) NOT NULL,
CONSTRAINT chk_profitlevel CHECK(profitlevel IN('Low' , 'Medium' , 'High'))
);

--Fill the 'orders' table...
DECLARE
  --Cursor for a query
  CURSOR orders_cursor IS
  SELECT o.id , o.customer_id , SUM(i.amount) as amount , SUM(i.cost) as cost
  FROM xsales.orders o JOIN xsales.order_items i ON o.ID=i.order_id
  GROUP BY o.id, o.customer_id;--A Join that brings the total amount and cost for each combination of order id and customer id
  ord  orders_cursor%rowtype;--Record of the above cusror
  proflevel VARCHAR(6);--profitlevel
  profit NUMBER;--profit
BEGIN
  OPEN orders_cursor;
  LOOP --For each row...
    FETCH orders_cursor INTO ord;
    profit := order_profit(ord.amount,ord.cost);--find profit
    proflevel := PROFIT_LEVEL(ord.amount,ord.cost);--find profit level
    INSERT INTO orders(ORDER_ID,CUSTOMER_ID,PRICE,COST,PROFIT,PROFITLEVEL) VALUES(ord.ID,ord.CUSTOMER_ID,ord.amount,ord.cost,profit,proflevel);
    EXIT WHEN orders_cursor%Notfound;
  END LOOP;
  CLOSE orders_cursor;
END;
/
------------------------------------------------------------------------------------
commit;

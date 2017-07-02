--Excercise 2------------------------------------------------------
--2.a----
select count(*) from customers;
select count(*) from orders;

--2.b----
--How many rows for each value of...
--age
select age , count(age) as alloc from customers group by age order by age;
--credit_limit
select credit_limit , count(credit_limit) as alloc from customers group by credit_limit order by credit_limit;
--income_level
select income_level , count(income_level) as alloc from customers group by income_level order by income_level;
--...in 'Customers' table.

--Range of Profit in 'Orders' table...
select max(profit)-min(profit) as profit_range from orders;

--2.c----
--add 3 more coloumns to customers...
ALTER TABLE customers ADD total_money_spend NUMBER(10,2) DEFAULT 0.00;
ALTER TABLE customers ADD total_orders_made NUMBER DEFAULT 0 ;
ALTER TABLE customers ADD total_profit NUMBER(10,2) DEFAULT 0.00;
--fill the new coloumns...
DECLARE
  --Each of the below relations (inside the cursors) have only ONE customer per row...
  --For easy iteration, they are ordered by the customer's id...
  CURSOR cust_cursor IS
  select * from customers order by id
  FOR UPDATE;
  cust customers%rowtype;
  CURSOR ord_cursor IS
  select customer_id , sum(price) as total_money , count(order_id) as orders_made , sum(profit) as total_profit
  from orders group by customer_id order by customer_id;
  ord ord_cursor%rowtype;
  --temporary variables
  money_spent NUMBER;
  ORDERS_MADE NUMBER;
  total_prof NUMBER;
BEGIN
  --Initialize cursors
  OPEN cust_cursor;
  OPEN ord_cursor;
  FETCH cust_cursor INTO cust;
  FETCH ord_cursor INTO ord;
  LOOP--loop thorough both cursors
    --If customer hasn't made an order, everything remains 0.
    --Check if customer has made an order...
    IF( cust.id != ord.customer_id) THEN
      FETCH cust_cursor INTO cust;
      CONTINUE;--if not go to next customer.
    END IF;
    --update values for customer
    money_spent := ord.total_money;
    orders_made := ord.orders_made;
    total_prof := ord.total_profit;
    UPDATE CUSTOMERS SET total_money_spend = money_spent, total_orders_made=orders_made, total_profit=total_prof WHERE CURRENT OF cust_cursor;
    --go to next customer
    FETCH cust_cursor INTO cust;
    FETCH ord_cursor INTO ord;
    --Loop ends when iteration over one of the ordered relations has stopped...
    EXIT WHEN ord_cursor%Notfound OR cust_cursor%Notfound;
  END LOOP;
  CLOSE cust_cursor;
  CLOSE ord_cursor;
END;
/

--2.d----
select customer_id , avg(price) as MONEY_SPENT from ORDERS group by customer_id having avg(price) >10000 ;

--2.e----
--Add one more coloumn to customers table.
ALTER TABLE CUSTOMERS ADD coupon NUMBER(10,2) DEFAULT 0.00;
--Find the corresponding coupon and add it for each customer.
DECLARE
  --This relation has only the average price paid by each customer.
  CURSOR ord_cursor IS
  SELECT customer_id ,  avg(price) as avg_price
  FROM orders GROUP BY customer_id ORDER BY  customer_id;
  ord ord_cursor%rowtype;
  CURSOR cust_cursor IS
  select * from customers order by id
  FOR UPDATE;
  cust cust_cursor%rowtype;
  coup NUMBER(10,2);
BEGIN
  OPEN cust_cursor;
  OPEN ord_cursor;
  FETCH cust_cursor INTO cust;
  FETCH ord_cursor INTO ord;
  LOOP--Go through all customers
    --Check if customer has made an order...
    IF( cust.id != ord.customer_id) THEN
      FETCH cust_cursor INTO cust;
      CONTINUE;--if not go to next customer.
    END IF;
    --Find if customer shound get a 10% discount coupon.
    IF(cust.total_orders_made > 3 OR cust.total_money_spend > 30000) THEN
      coup := cust.TOTAL_PROFIT / 10;
      UPDATE CUSTOMERS SET coupon=coup  WHERE CURRENT OF cust_cursor;
      --If true, add coupon and go to next customer.
    --Find if customer shound get a 5% discount coupon.
    ELSIF(ord.avg_price > 5000) THEN
      coup := cust.TOTAL_PROFIT / 20;
      UPDATE CUSTOMERS SET coupon = coup  WHERE CURRENT OF cust_cursor;
      --If true, add coupon and go to next customer.
    END IF;
    --go to next customer
    FETCH cust_cursor INTO cust;
    FETCH ord_cursor INTO ord;
    --Loop ends when iteration over one of the ordered relations has stopped...
    EXIT WHEN ord_cursor%Notfound OR cust_cursor%Notfound;
  END LOOP;
  CLOSE cust_cursor;
  CLOSE ord_cursor;
END;
/

--2.f----
SELECT sum(total_profit) - sum(coupon) as actual_profit
FROM customers;

------------------------------------------------------------------------------------
commit;

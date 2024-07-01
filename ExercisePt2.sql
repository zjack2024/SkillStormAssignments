use hr_db

--countries - country_id, country_name, region_id
--departments - department_id, department_name, manager_id, location_id
--employees - employee_id, first_name,last_name,email,phone_number,hire_date,job_id,salary,commission_pct,manager_id,department_id
--job_history
--jobs
--locations
--regions

WITH avg_department AS (
	SELECT d.department_id,d.department_name, ROUND(AVG(e.salary),2) AS avg_department_salary
	FROM departments d
	LEFT JOIN employees e
	ON d.department_id=e.department_id
	GROUP BY d.department_id,d.department_name
),
above_avg AS (
	SELECT e.employee_id, d.department_name,e.salary,ad.avg_department_salary,d.department_id
	FROM employees e
	JOIN departments d
	ON d.department_id=e.department_id
	JOIN avg_department ad ON d.department_id=ad.department_id
	WHERE e.salary>ad.avg_department_salary
	)
SELECT aa.employee_id,aa.department_name,aa.salary,aa.avg_department_salary
FROM above_avg aa
ORDER BY aa.department_id ASC, aa.salary DESC

--Exercise 2
WITH cum_department AS (
	SELECT
		e.employee_id,
        d.department_name,
        e.salary,
        ROUND(SUM(e.salary) OVER (PARTITION BY d.department_name ORDER BY e.salary ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cum_salary
	FROM departments d
	JOIN employees e
	ON d.department_id=e.department_id
	WHERE d.department_name IN ('Finance', 'IT')

)
SELECT DISTINCT c.employee_id,c.department_name,c.salary,c.cum_salary
FROM cum_department c
ORDER BY c.department_name ASC, c.salary ASC


--Exercise 3
WITH d_rank AS (
	SELECT
		e.employee_id,
		d.department_id,
        d.department_name,
        e.salary,
        DENSE_RANK() OVER (PARTITION BY d.department_name ORDER BY e.salary ASC) AS ranks
	FROM departments d
	JOIN employees e
	ON d.department_id=e.department_id
)
SELECT dr.employee_id,dr.department_id,dr.department_name,dr.salary,dr.ranks AS employee_rank
FROM d_rank dr
WHERE dr.ranks<4
ORDER BY dr.department_id ASC, dr.salary DESC

--Exercise 4
use retail_db

WITH product_able AS(
	SELECT
		p.product_id,
		p.product_name,
		ROUND(SUM(oi.order_item_product_price*oi.order_item_quantity), 2) AS revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(oi.order_item_quantity * oi.order_item_product_price) DESC) AS product_rank
	FROM
		orders o
		JOIN order_items oi ON o.order_id=oi.order_item_order_id
		JOIN products p ON oi.order_item_product_id=p.product_id
	WHERE o.order_status IN ('CLOSED','COMPLETE') AND MONTH(o.order_date)=1 AND YEAR(o.order_date)=2014
	GROUP BY p.product_id, p.product_name
)
SELECT
	pa.product_id,
	pa.product_name,
	pa.revenue,
	pa.product_rank
FROM product_able pa
WHERE
	pa.product_rank<=3
ORDER BY pa.revenue DESC


--Exercise 5
WITH product_able AS(
	SELECT
		c.category_id,
		c.category_name,
		p.product_id,
		p.product_name,
		ROUND(SUM(oi.order_item_product_price*oi.order_item_quantity), 2) AS revenue,
		ROW_NUMBER() OVER (PARTITION BY c.category_name ORDER BY SUM(oi.order_item_quantity * oi.order_item_product_price) DESC) AS product_rank
	FROM
		orders o
		JOIN order_items oi ON o.order_id=oi.order_item_order_id
		JOIN products p ON oi.order_item_product_id=p.product_id
		JOIN categories c ON p.product_category_id=c.category_id
	WHERE o.order_status IN ('CLOSED','COMPLETE') AND MONTH(o.order_date)=1 AND YEAR(o.order_date)=2014 AND (c.category_name='Cardio Equipment' OR c.category_name='Strength Training')
	GROUP BY p.product_id, p.product_name, c.category_id,c.category_name
)
SELECT
	pa.category_id,
	pa.category_name,
	pa.product_id,
	pa.product_name,
	pa.revenue,
	pa.product_rank
FROM product_able pa
WHERE
	pa.product_rank<=3
ORDER BY pa.category_id ASC, pa.revenue DESC


--DDL exercises
--1
SELECT MAX(p.product_id) AS max_product_id
FROM products p --repeat this for the next 6 tables

--I do not know what it means to 'Alter the script to create the primary key column with the correct value to insert new data.'

--2
SELECT o.*
FROM orders o
LEFT JOIN customers c ON o.order_customer_id = c.customer_id -- repeat this to every table
WHERE c.customer_id IS NULL;

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (order_customer_id) REFERENCES customers(customer_id);
UPDATE orders
SET orders.order_customer_id = NULL
WHERE orders.order_customer_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM customers WHERE customers.customer_id = orders.order_customer_id
);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_item_order_id) REFERENCES orders(order_id);
UPDATE order_items
SET order_items.order_item_order_id = NULL
WHERE order_items.order_item_order_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM orders WHERE orders.order_id = order_items.order_item_order_id
);


ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (order_item_product_id) REFERENCES products(product_id);
UPDATE order_items
SET order_items.order_item_product_id = NULL
WHERE order_items.order_item_product_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM products WHERE products.product_id = order_items.order_item_product_id
);


ALTER TABLE products
ADD CONSTRAINT fk_products_categories
FOREIGN KEY (product_category_id) REFERENCES categories(category_id);
UPDATE products
SET products.product_category_id = NULL
WHERE products.product_category_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM categories WHERE categories.category_id = products.product_category_id
);


ALTER TABLE categories
ADD CONSTRAINT fk_categories_departments
FOREIGN KEY (category_department_id) REFERENCES departments(department_id);
UPDATE categories
SET categories.category_department_id = NULL
WHERE categories.category_department_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM departments WHERE departments.department_id = categories.category_department_id
);


--3
INSERT INTO customers (customer_id, customer_name, customer_email)
VALUES (1, 'John Doe', 'john.doe@example.com');
INSERT INTO orders (order_id, order_customer_id, order_date)
VALUES (1, 1, '2024-06-30');

INSERT INTO orders (order_id, order_customer_id, order_date)
VALUES (2, 999, '2024-07-01');


--Partition Exercises
CREATE TABLE orders_part (
   order_id INT IDENTITY NOT NULL,
  order_date DATETIME NOT NULL,
  order_customer_id INT NOT NULL,
  order_status VARCHAR(45) NOT NULL,
  PRIMARY KEY (order_id)
);

CREATE PARTITION FUNCTION order_date_pf (DATE)
AS RANGE RIGHT FOR VALUES (
    '2014-02-01','2014-03-01' 
);

CREATE PARTITION SCHEME order_date_ps
AS PARTITION order_date_pf
ALL TO ('PRIMARY');

BULK INSERT dbo.orders_part FROM 'C:\Users\socia\OneDrive\Documents\2024\skillstorm\csv data\orders.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;

DROP INDEX IF EXISTS CL_OrderDatePartitioned ON orders_part;

CREATE CLUSTERED INDEX CL_OrderDatePartitioned
ON orders_part(order_date)
WITH (DROP_EXISTING = ON)
ON OrderDatePartitionScheme(order_date);

CREATE PARTITION FUNCTION myRangePF1 (datetime2(0))  
    AS RANGE RIGHT FOR VALUES ('2022-04-01', '2022-05-01', '2022-06-01') ;  
GO  

CREATE PARTITION SCHEME myRangePS1  
    AS PARTITION myRangePF1  
    ALL TO ('PRIMARY') ;  
GO  

CREATE TABLE dbo.PartitionTable (col1 datetime2(0) PRIMARY KEY, col2 char(10))  
    ON myRangePS1 (col1) ;  
GO

--Genuinely Cannot understand how to partition this table
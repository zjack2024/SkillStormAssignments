
--Exercise 1
CREATE TABLE courses (
    course_id INT IDENTITY PRIMARY KEY,
    course_name VARCHAR(60) NOT NULL,
    course_author VARCHAR(40) NOT NULL,
    course_status VARCHAR(9) NOT NULL,
    course_published_dt DATE
);

--Exercise 2
INSERT INTO courses
    (course_name, course_author, course_status, course_published_dt)
VALUES
    ('Programming using Python', 'Bob Dillon', 'published', '2020-09-30'),
    ('Data Engineering using Python', 'Bob Dillon', 'published', '2020-07-15'),
	('Programming using Scala', 'Elvis Presley', 'published', '2020-05-12'),
	('Programming using Java', 'Mike Jack', 'inactive', '	2020-08-10'),
	('Web Applications - Python Flask', 'Bob Dillon', 'inactive', '2020-07-20'),
	('Streaming Pipelines - Python', 'Bob Dillon', 'published', '2020-10-05'),
	('Web Applications - Scala Play', 'Elvis Presley', 'inactive', '2020-09-30'),
	('Web Applications - Python Django', 'Bob Dillon', 'published', '2020-06-23'),
    ('Server Automation - Ansible', 'Uncle Sam', 'published', '2020-07-05');

	INSERT INTO courses
    (course_name, course_author, course_status)
VALUES
	('Data Engineering using Scala', 'Elvis Presley', 'draft'),
	('Web Applications - Java Spring', 'Mike Jack', 'draft'),
	('Pipeline Orchestration - Python', 'Bob Dillon', 'draft');
	
SELECT * FROM courses;

UPDATE courses
SET course_published_dt = getdate(), course_status = 'published'
WHERE (course_name LIKE '%Python%' OR course_name LIKE '%Scala%') AND course_status = 'draft';

DELETE FROM courses WHERE course_status !='draft' AND course_status != 'published';

SELECT course_author, count(1) AS course_count
FROM courses
WHERE course_status= 'published'
GROUP BY course_author

DROP TABLE courses;


--BASIC SQL QUERIES EXERCISES
-- Postgres Table Creation Script
--

--
-- Table structure for table departments
--
CREATE DATABASE retail_db;
GO

USE retail_db;
GO

CREATE TABLE departments (
  department_id INT IDENTITY NOT NULL,
  department_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (department_id)
);

--
-- Table structure for table categories
--

CREATE TABLE categories (
  category_id INT IDENTITY NOT NULL,
  category_department_id INT NOT NULL,
  category_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (category_id)
); 

--
-- Table structure for table products
--

CREATE TABLE products (
  product_id INT IDENTITY NOT NULL,
  product_category_id INT NOT NULL,
  product_name VARCHAR(45) NOT NULL,
  product_description VARCHAR(255) NOT NULL,
  product_price FLOAT NOT NULL,
  product_image VARCHAR(255) NOT NULL,
  PRIMARY KEY (product_id)
);

--
-- Table structure for table customers
--

CREATE TABLE customers (
  customer_id INT IDENTITY NOT NULL,
  customer_fname VARCHAR(45) NOT NULL,
  customer_lname VARCHAR(45) NOT NULL,
  customer_email VARCHAR(45) NOT NULL,
  customer_password VARCHAR(45) NOT NULL,
  customer_street VARCHAR(255) NOT NULL,
  customer_city VARCHAR(45) NOT NULL,
  customer_state VARCHAR(45) NOT NULL,
  customer_zipcode VARCHAR(45) NOT NULL,
  PRIMARY KEY (customer_id)
); 

--
-- Table structure for table orders
--

CREATE TABLE orders (
  order_id INT IDENTITY NOT NULL,
  order_date DATETIME NOT NULL,
  order_customer_id INT NOT NULL,
  order_status VARCHAR(45) NOT NULL,
  PRIMARY KEY (order_id)
);

--
-- Table structure for table order_items
--

CREATE TABLE order_items (
  order_item_id INT IDENTITY NOT NULL,
  order_item_order_id INT NOT NULL,
  order_item_product_id INT NOT NULL,
  order_item_quantity INT NOT NULL,
  order_item_subtotal FLOAT NOT NULL,
  order_item_product_price FLOAT NOT NULL,
  PRIMARY KEY (order_item_id)
);

BULK INSERT dbo.categories FROM 'C:\Users\socia\OneDrive\Documents\2024\skillstorm\csv data\categories.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.customers FROM 'C:\Users\socia\OneDrive\Documents\2024\skillstorm\csv data\customers.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.departments FROM 'C:\Users\socia\OneDrive\Documents\2024\skillstorm\csv data\departments.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.order_items FROM 'C:\Users\socia\OneDrive\Documents\2024\skillstorm\csv data\order_items.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.orders FROM 'C:\Users\socia\OneDrive\Documents\2024\skillstorm\csv data\orders.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.products FROM 'C:\Users\socia\OneDrive\Documents\2024\skillstorm\csv data\products.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;

SELECT * FROM products

drop table categories,customers,departments,order_items,orders,products

--Exercise 1
SELECT customers.customer_id, customers.customer_fname, customers.customer_lname, COUNT(order_id) AS customer_order_count FROM customers, orders 
WHERE customers.customer_id=orders.order_customer_id
GROUP BY customers.customer_id,customers.customer_fname, customers.customer_lname ORDER BY customers.customer_id;


--Exercise 2
SELECT customers.* FROM customers,orders 
WHERE customers.customer_id=orders.order_customer_id AND MONTH(orders.order_date)=1 AND YEAR(orders.order_date)=2014
ORDER BY customers.customer_id ASC;

--Exercise 3

SELECT customers.customer_id, customers.customer_fname, customers.customer_lname, COALESCE(SUM(order_items.order_item_product_price),0) AS customer_revenue
FROM order_items
RIGHT JOIN orders
ON orders.order_id=order_items.order_item_order_id
LEFT JOIN customers
ON customers.customer_id=orders.order_customer_id
WHERE orders.order_status IN ('CLOSED','COMPLETE') AND MONTH(orders.order_date)=1 AND YEAR(orders.order_date)=2014
GROUP BY customers.customer_id, customers.customer_fname, customers.customer_lname
ORDER BY customer_revenue DESC

--Exercise 4
SELECT categories.*, COALESCE(SUM(order_items.order_item_product_price),0) AS category_revenue
FROM orders,products
LEFT JOIN categories
ON categories.category_id=products.product_category_id
RIGHT JOIN order_items
ON products.product_id=order_items.order_item_product_id
WHERE (orders.order_status='CLOSED' OR orders.order_status='COMPLETE') AND orders.order_id=order_items.order_item_order_id
GROUP BY categories.category_id, categories.category_department_id, categories.category_name
ORDER BY categories.category_id ASC;

--Exercise 5

SELECT departments.*, COALESCE(COUNT(products.product_id),0) AS product_count 
FROM products, categories
LEFT JOIN departments
ON departments.department_id= categories.category_department_id
WHERE categories.category_id=products.product_category_id
GROUP BY departments.department_id, departments.department_name
ORDER BY departments.department_id ASC

SELECT * FROM categories
SELECT * from departments
DROP TABLE departments,categories,order_items,orders,customers,products

--Part 6
CREATE TABLE users (
    user_id int PRIMARY KEY IDENTITY,
    user_first_name VARCHAR(30),
    user_last_name VARCHAR(30),
    user_email_id VARCHAR(50),
    user_gender VARCHAR(1),
    user_unique_id VARCHAR(15),
    user_phone_no VARCHAR(20),
    user_dob DATE,
    created_ts DATETIME
);
GO


insert into users (
    user_first_name, user_last_name, user_email_id, user_gender, 
    user_unique_id, user_phone_no, user_dob, created_ts
) VALUES
    ('Giuseppe', 'Bode', 'gbode0@imgur.com', 'M', '88833-8759', 
     '+86 (764) 443-1967', '1973-05-31', '2018-04-15 12:13:38'),
    ('Lexy', 'Gisbey', 'lgisbey1@mail.ru', 'N', '262501-029', 
     '+86 (751) 160-3742', '2003-05-31', '2020-12-29 06:44:09'),
    ('Karel', 'Claringbold', 'kclaringbold2@yale.edu', 'F', '391-33-2823', 
     '+62 (445) 471-2682', '1985-11-28', '2018-11-19 00:04:08'),
    ('Marv', 'Tanswill', 'mtanswill3@dedecms.com', 'F', '1195413-80', 
     '+62 (497) 736-6802', '1998-05-24', '2018-11-19 16:29:43'),
    ('Gertie', 'Espinoza', 'gespinoza4@nationalgeographic.com', 'M', '471-24-6869', 
     '+249 (687) 506-2960', '1997-10-30', '2020-01-25 21:31:10'),
    ('Saleem', 'Danneil', 'sdanneil5@guardian.co.uk', 'F', '192374-933', 
     '+63 (810) 321-0331', '1992-03-08', '2020-11-07 19:01:14'),
    ('Rickert', 'O''Shiels', 'roshiels6@wikispaces.com', 'M', '749-27-47-52', 
     '+86 (184) 759-3933', '1972-11-01', '2018-03-20 10:53:24'),
    ('Cybil', 'Lissimore', 'clissimore7@pinterest.com', 'M', '461-75-4198', 
     '+54 (613) 939-6976', '1978-03-03', '2019-12-09 14:08:30'),
    ('Melita', 'Rimington', 'mrimington8@mozilla.org', 'F', '892-36-676-2', 
     '+48 (322) 829-8638', '1995-12-15', '2018-04-03 04:21:33'),
    ('Benetta', 'Nana', 'bnana9@google.com', 'N', '197-54-1646', 
     '+420 (934) 611-0020', '1971-12-07', '2018-10-17 21:02:51'),
    ('Gregorius', 'Gullane', 'ggullanea@prnewswire.com', 'F', '232-55-52-58', 
     '+62 (780) 859-1578', '1973-09-18', '2020-01-14 23:38:53'),
    ('Una', 'Glayzer', 'uglayzerb@pinterest.com', 'M', '898-84-336-6', 
     '+380 (840) 437-3981', '1983-05-26', '2019-09-17 03:24:21'),
    ('Jamie', 'Vosper', 'jvosperc@umich.edu', 'M', '247-95-68-44', 
     '+81 (205) 723-1942', '1972-03-18', '2020-07-23 16:39:33'),
    ('Calley', 'Tilson', 'ctilsond@issuu.com', 'F', '415-48-894-3', 
     '+229 (698) 777-4904', '1987-06-12', '2020-06-05 12:10:50'),
    ('Peadar', 'Gregorowicz', 'pgregorowicze@omniture.com', 'M', '403-39-5-869', 
     '+7 (267) 853-3262', '1996-09-21', '2018-05-29 23:51:31'),
    ('Jeanie', 'Webling', 'jweblingf@booking.com', 'F', '399-83-05-03', 
     '+351 (684) 413-0550', '1994-12-27', '2018-02-09 01:31:11'),
    ('Yankee', 'Jelf', 'yjelfg@wufoo.com', 'F', '607-99-0411', 
     '+1 (864) 112-7432', '1988-11-13', '2019-09-16 16:09:12'),
    ('Blair', 'Aumerle', 'baumerleh@toplist.cz', 'F', '430-01-578-5', 
     '+7 (393) 232-1860', '1979-11-09', '2018-10-28 19:25:35'),
    ('Pavlov', 'Steljes', 'psteljesi@macromedia.com', 'F', '571-09-6181', 
     '+598 (877) 881-3236', '1991-06-24', '2020-09-18 05:34:31'),
    ('Darn', 'Hadeke', 'dhadekej@last.fm', 'M', '478-32-02-87', 
     '+370 (347) 110-4270', '1984-09-04', '2018-02-10 12:56:00'),
    ('Wendell', 'Spanton', 'wspantonk@de.vu', 'F', null, 
     '+84 (301) 762-1316', '1973-07-24', '2018-01-30 01:20:11'),
    ('Carlo', 'Yearby', 'cyearbyl@comcast.net', 'F', null, 
     '+55 (288) 623-4067', '1974-11-11', '2018-06-24 03:18:40'),
    ('Sheila', 'Evitts', 'sevittsm@webmd.com', null, '830-40-5287',
     null, '1977-03-01', '2020-07-20 09:59:41'),
    ('Sianna', 'Lowdham', 'slowdhamn@stanford.edu', null, '778-0845', 
     null, '1985-12-23', '2018-06-29 02:42:49'),
    ('Phylys', 'Aslie', 'paslieo@qq.com', 'M', '368-44-4478', 
     '+86 (765) 152-8654', '1984-03-22', '2019-10-01 01:34:28')

--Exercise 1
SELECT YEAR(users.created_ts) AS created_year, COUNT(users.user_id) AS user_count
FROM users
GROUP BY YEAR(users.created_ts)
ORDER BY created_year ASC

--Exercise 2
SELECT users.user_id,users.user_dob, users.user_email_id, DATENAME(weekday,users.user_dob) AS user_day_of_birth
FROM users
WHERE MONTH(users.user_dob)=5

--Exercise 3
SELECT UPPER(CONCAT(users.user_first_name,' ',users.user_last_name)) AS user_name,users.user_email_id, users.created_ts, CAST(YEAR(created_ts) AS DECIMAL(7,1)) AS user_day_of_birth
FROM users
WHERE YEAR(created_ts) =2019
ORDER BY user_name

--Exercise 4
SELECT
CASE WHEN users.user_gender='M' THEN 'Male'
WHEN users.user_gender='F' THEN 'Female'
WHEN users.user_gender='N' THEN 'Non-Binary'
WHEN users.user_gender IS NULL THEN 'Not Specified'
END, COUNT(users.user_id) AS user_count
FROM users
GROUP BY users.user_gender
ORDER BY user_count DESC

--Exercise 5
SELECT users.user_id, users.user_unique_id,
CASE WHEN LEN(REPLACE(users.user_unique_id,'-',''))<9 THEN 'Invalid Unique Id'
WHEN users.user_gender IS NULL THEN 'Not Specified'
WHEN users.user_gender IS NOT NULL THEN RIGHT(REPLACE(users.user_unique_id,'-',''),4)
END AS user_unique_id_last4
FROM users

--Exercise 6
SELECT
	LEFT(REPLACE(users.user_phone_no,'+',''),CHARINDEX(' ',REPLACE(users.user_phone_no,'+','')+' ')-1) AS country_code,
	COUNT(users.user_id) AS user_count
FROM 
	users
WHERE 
	users.user_phone_no IS NOT NULL
GROUP BY LEFT(REPLACE(users.user_phone_no,'+',''),CHARINDEX(' ',REPLACE(users.user_phone_no,'+','')+' ')-1)
ORDER BY CAST(LEFT(REPLACE(users.user_phone_no,'+',''),CHARINDEX(' ',REPLACE(users.user_phone_no,'+','')+' ')-1) AS INT) ASC

select * from order_items
--Exercise 7
SELECT COUNT(order_items.order_item_subtotal) AS count
FROM order_items
WHERE ROUND(order_items.order_item_quantity*order_items.order_item_product_price,2) <> ROUND(order_items.order_item_subtotal,2)

--Exercise 8
SELECT 
	CASE
		WHEN DATENAME(w,orders.order_date)='Saturday' OR DATENAME(w,orders.order_date)='Sunday' THEN 'Weekend Days'
		ELSE 'Week days'
	END AS day_type,
	COUNT(orders.order_id) AS order_count
FROM orders
WHERE MONTH(orders.order_date)=1 AND YEAR(orders.order_date)=2014
GROUP BY
	CASE
		WHEN DATENAME(w,orders.order_date)='Saturday' OR DATENAME(w,orders.order_date)='Sunday' THEN 'Weekend Days'
		ELSE 'Week days'
	END
ORDER BY day_type DESC


--Part 7
--Exercise 1
SELECT c.category_name
FROM categories c
WHERE c.category_id in (
	SELECT p.product_category_id
	FROM products p
	GROUP BY p.product_category_id
	HAVING COUNT(*)>5
);

--Exercise 2
SELECT o.*
FROM orders o
WHERE o.order_customer_id in (
	SELECT o.order_customer_id
	FROM orders o
	GROUP BY o.order_customer_id
	HAVING COUNT(*)>10
)

--Exercise 3
SELECT p.product_name, (
	SELECT ROUND(AVG(p.product_price),2)
	FROM orders o,products p
	LEFT JOIN order_items oi
	ON oi.order_item_product_id=p.product_id
	WHERE  MONTH(o.order_date)=10 AND YEAR(o.order_date)=2013 AND o.order_id = oi.order_item_order_id) as average_price
FROM products p

--Exercise 4
SELECT *
FROM orders o
WHERE o.order_id in(
	SELECT oi.order_item_order_id
	FROM order_items oi
	GROUP BY oi.order_item_order_id
	HAVING AVG(oi.order_item_subtotal)<SUM(oi.order_item_quantity*oi.order_item_product_price)
);

--Exercise 5
WITH category_product_count AS (
	SELECT
		c.category_id,
		c.category_name,
		COUNT(p.product_id) AS product_count
	FROM
		categories c
	LEFT JOIN
		products p ON c.category_id=p.product_category_id
	GROUP BY
		c.category_id,
		c.category_name
)
SELECT TOP 3 *
FROM category_product_count cpc
ORDER BY cpc.product_count DESC

--Exercise 6
WITH order_totals AS (
	SELECT o.order_customer_id,oi.order_item_subtotal,oi.order_item_quantity,oi.order_item_product_price
	FROM order_items oi
	LEFT JOIN orders o
	ON o.order_id=oi.order_item_order_id
	WHERE MONTH(o.order_date)=12
	), customer_with_orders AS(
	SELECT c.*
	FROM customers c
	RIGHT JOIN orders o
	ON o.order_customer_id=c.customer_id
	WHERE MONTH(o.order_date)=12)
SELECT co.customer_id, co.customer_fname, co.customer_lname
FROM customer_with_orders co
LEFT JOIN order_totals ot
ON co.customer_id=ot.order_customer_id
GROUP BY co.customer_id, co.customer_fname, co.customer_lname
HAVING AVG(ot.order_item_subtotal)<SUM(ot.order_item_quantity*ot.order_item_product_price)



--Analytical Queries Exercise
--Exercise 1


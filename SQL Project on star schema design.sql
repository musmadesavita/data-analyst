show databases;
use bepec1;
show tables;
desc customer;
select * from customer;

ALTER TABLE customer
ADD INDEX idx_Customer_ID (Customer_ID);

CREATE TABLE FactOrders (
    Order_ID varchar(15) not null primary key,
    Order_Date DATE,
    Ship_Date DATE,
    Discount float,
    Profit float,
    Quantity INT,
    Sales float,
    Customer_ID int,
    Location_ID int,
    Manufacturer_ID int,
    Product_ID int,
    Segment_ID int,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) on delete cascade on update cascade, 
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID) on delete cascade on update cascade, 
    FOREIGN KEY (Manufacturer_ID) REFERENCES Manufacturer(Manufacturer_ID) on delete cascade on update cascade, 
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID) on delete cascade on update cascade, 
    FOREIGN KEY (Segment_ID) REFERENCES Segment(Segment_ID) on delete cascade on update cascade 
);

ALTER TABLE location
ADD INDEX idx_Location_ID (Location_ID);

ALTER TABLE product
ADD INDEX idx_product_ID (product_ID);

ALTER TABLE segment
ADD INDEX idx_segment_ID (segment_ID);

ALTER TABLE manufacturer
ADD INDEX idx_manufacturer_ID (manufacturer_ID);

create table manufacturer(
manufacturer_id int,
maunfacturer_name varchar(20));

insert into manufacturer values(1, 'Bush'),(2, 'Hon'), (3, 'Universal'), (4, 'Bretford'), (5, 'Eldon'),
 (6, 'Chromcraft'), (7, 'Newell'), (8, 'Mitel'), (9, 'DXL'), (10, 'Belkin');
 
 select * from manufacturer;

insert into factorders values('CA-2020-105816', '2020-11-12', '2020-11-11', 0,	41.9136, 2, 261.96, 1, 1, 1, 1, 1);
insert into factorders values('CA-2019-115742', '2019-04-18', '2020-06-16', 0, 6.8714,	2, 14.62, 2, 2, 2, 2, 1);
insert into factorders values('CA-2019-115743', '2019-04-18', '2019-10-18', 0.45, -383.031,	5, 957.5775, 3, 3, 3, 3, 2);
insert into factorders values('CA-2019-115747', '2019-04-18', '2019-06-14', 0, 14.1694, 7, 48.86, 4, 4, 4, 4, 1);
insert into factorders values('CA-2020-101343', '2020-07-17', '2021-04-20', 0.2, 5.4432, 3, 15.552, 5, 5, 5, 5, 1);
insert into factorders values('CA-2021-120999', '2019-09-10', '2020-12-10', 0.2, 132.5922, 3, 407.976, 6, 6, 6, 6, 1);
insert into factorders values('CA-2019-117415', '2019-12-27', '2019-11-26', 0.8, -123.858, 5, 68.81, 7, 7, 7, 7, 3);
insert into factorders values('CA-2019-117417', '2019-12-27', '2018-11-18', 0, 13.3176, 6, 665.88, 8, 8, 8, 8, 1);
insert into factorders values('CA-2019-117418', '2019-12-27', '2018-05-15', 0, 9.99, 2, 55.5, 9, 9, 9, 9, 1);
insert into factorders values('US-2019-150630', '2019-09-17', '2020-12-13', 0, 5.0596, 7, 19.46, 10, 10, 10, 10, 2);

select * from factorders;

# 1)Top 5 Customers based on Sales

SELECT Customer_ID, SUM(Sales) AS TotalSales
FROM FactOrders
GROUP BY Customer_ID
ORDER BY TotalSales DESC
LIMIT 5;

# 2)Bottom 8 Customers based on Profits.

SELECT c.customer_id, c.customer_name, SUM(o.profit) AS total_profit
FROM customer c
JOIN factorders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_profit ASC
LIMIT 8;

# 3) Running Sum of Sales of Corporate Segment from Past Three-Month Range

SELECT
    f.ship_date,
    SUM(f.sales) AS daily_sales,
    (
        SELECT SUM(f2.sales)
        FROM factorders f2
        JOIN segment s2 ON f2.segment_id = s2.segment_id
        WHERE
            s2.segment_name = 'Corporate' AND
            f2.ship_date BETWEEN DATE_SUB(f.ship_date, INTERVAL 3 MONTH) AND f.ship_date
    ) AS running_sum_sales
FROM
    factorders f
JOIN
    segment s ON f.segment_id = s.segment_id
WHERE
    s.segment_name = 'Corporate'
GROUP BY
    f.ship_date
ORDER BY
    f.ship_date;


# 4) Moving Average of December Month from central Region

SELECT
    f.ship_date,
    f.sales,
    AVG(f.sales) OVER (
        ORDER BY f.ship_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_average_sales
FROM
    factorders f
JOIN
    location l ON f.location_id = l.location_id
WHERE
    l.region = 'central' 
    AND EXTRACT(MONTH FROM f.ship_date) = 12
ORDER BY
    f.ship_date;

# 5)Retrieve the Data of Customers whose sales are greater than 10 and who are from California.

SELECT
    c.customer_name,
    l.state,
    SUM(f.sales) AS total_sales
FROM
    customer c
JOIN
    factorders f ON c.customer_id = f.customer_id
JOIN
    location l ON f.location_id = l.location_id
WHERE
    l.state = 'California'
GROUP BY
    c.customer_name, l.state
HAVING
    total_sales > 10
LIMIT 1000;

 # 6) Top 5 Products based on Profits with City of the Customers.

SELECT
    p.product_name,
    l.city,
    SUM(f.profit) AS total_profit
FROM
    factorders f
JOIN
    product p ON f.product_id = p.product_id
JOIN
    location l ON f.location_id = l.location_id
GROUP BY
    p.product_name, l.city
ORDER BY
    total_profit DESC
LIMIT 5;

# 7) Retrieve the SUM of sales of each Product and Arrange the Sales in DESC Order

SELECT
    c.customer_name,
    SUM(f.profit) AS total_profit
FROM
    factorders f
JOIN
    customer c ON f.customer_id = c.customer_id
GROUP BY
    c.customer_name
ORDER BY
    total_profit DESC;

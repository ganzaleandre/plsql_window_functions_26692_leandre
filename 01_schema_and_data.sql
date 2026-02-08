-- =====================================================
-- E-COMMERCE SALES ANALYTICS DATABASE SCHEMA
-- =====================================================

-- Create Regions Table
CREATE TABLE regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- Create Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    region_id INT,
    join_date DATE NOT NULL,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- Create Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL
);

-- Create Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- Insert Regions
INSERT INTO regions VALUES (1, 'North America', 'USA');
INSERT INTO regions VALUES (2, 'Europe', 'UK');
INSERT INTO regions VALUES (3, 'Asia Pacific', 'Singapore');
INSERT INTO regions VALUES (4, 'Latin America', 'Brazil');

-- Insert Customers
INSERT INTO customers VALUES (1, 'John Smith', 'john@email.com', 1, '2024-01-15');
INSERT INTO customers VALUES (2, 'Emma Wilson', 'emma@email.com', 1, '2024-02-20');
INSERT INTO customers VALUES (3, 'Li Wei', 'liwei@email.com', 3, '2024-01-10');
INSERT INTO customers VALUES (4, 'Maria Garcia', 'maria@email.com', 4, '2024-03-05');
INSERT INTO customers VALUES (5, 'James Brown', 'james@email.com', 2, '2024-01-25');
INSERT INTO customers VALUES (6, 'Sarah Johnson', 'sarah@email.com', 1, '2024-04-10');
INSERT INTO customers VALUES (7, 'Ahmed Hassan', 'ahmed@email.com', NULL, '2024-05-01');

-- Insert Products
INSERT INTO products VALUES (1, 'Laptop Pro', 'Electronics', 1200.00);
INSERT INTO products VALUES (2, 'Wireless Mouse', 'Electronics', 25.00);
INSERT INTO products VALUES (3, 'Office Chair', 'Furniture', 350.00);
INSERT INTO products VALUES (4, 'Desk Lamp', 'Furniture', 45.00);
INSERT INTO products VALUES (5, 'USB Cable', 'Accessories', 10.00);
INSERT INTO products VALUES (6, 'Monitor 27inch', 'Electronics', 400.00);
INSERT INTO products VALUES (7, 'Keyboard Mechanical', 'Electronics', 150.00);

-- Insert Orders
INSERT INTO orders VALUES (1, 1, 1, '2024-06-01', 1, 1200.00);
INSERT INTO orders VALUES (2, 1, 2, '2024-06-02', 2, 50.00);
INSERT INTO orders VALUES (3, 2, 3, '2024-06-05', 1, 350.00);
INSERT INTO orders VALUES (4, 3, 1, '2024-06-10', 1, 1200.00);
INSERT INTO orders VALUES (5, 3, 5, '2024-06-11', 5, 50.00);
INSERT INTO orders VALUES (6, 4, 4, '2024-07-01', 2, 90.00);
INSERT INTO orders VALUES (7, 5, 6, '2024-07-05', 1, 400.00);
INSERT INTO orders VALUES (8, 1, 7, '2024-07-10', 1, 150.00);
INSERT INTO orders VALUES (9, 2, 1, '2024-08-01', 1, 1200.00);
INSERT INTO orders VALUES (10, 3, 2, '2024-08-05', 3, 75.00);
INSERT INTO orders VALUES (11, 5, 3, '2024-08-10', 1, 350.00);
INSERT INTO orders VALUES (12, 1, 5, '2024-09-01', 10, 100.00);

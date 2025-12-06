CREATE DATABASE vetty_sql_test;
USE vetty_sql_test;

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT,
    purchase_time DATETIME,
    refund_time DATETIME,
    store_id VARCHAR(5),
    item_id VARCHAR(5),
    gross_transaction_value DECIMAL(10,2)
);
CREATE TABLE items (
    store_id VARCHAR(5),
    item_id VARCHAR(5) PRIMARY KEY,
    item_category VARCHAR(50),
    item_name VARCHAR(100)
);
INSERT INTO transactions 
(buyer_id, purchase_time, refund_time, store_id, item_id, gross_transaction_value)
VALUES
(3, '2019-09-19 21:19:06.544', NULL, 'a', 'a1', 58),
(12, '2019-12-10 20:10:14.324', '2019-12-15 23:19:06.544', 'b', 'b2', 475),
(3, '2020-09-01 23:59:46.561', '2020-09-02 21:22:06.331', 'f', 'f9', 33),
(2, '2020-04-30 21:19:06.544', NULL, 'd', 'd3', 250),
(1, '2020-10-22 22:20:06.531', NULL, 'f', 'f2', 91),
(8, '2020-04-16 21:10:22.214', NULL, 'e', 'e7', 24),
(5, '2019-09-23 12:09:35.542', '2019-09-27 02:55:02.114', 'g', 'g6', 61);

INSERT INTO items (store_id, item_id, item_category, item_name) VALUES
('a', 'a1', 'pants', 'denim pants'),
('a', 'a2', 'tops', 'blouse'),
('f', 'f1', 'table', 'coffee table'),
('f', 'f5', 'chair', 'lounge chair'),
('f', 'f6', 'chair', 'armchair'),
('d', 'd2', 'jewelry', 'bracelet'),
('b', 'b4', 'earphone', 'airpods');


SELECT 
    DATE_FORMAT(purchase_time, '%Y-%m') AS month,
    COUNT(*) AS purchase_count
FROM transactions
WHERE refund_time IS NULL
GROUP BY DATE_FORMAT(purchase_time, '%Y-%m')
ORDER BY month;


SELECT 
    store_id,
    COUNT(*) AS order_count
FROM transactions
WHERE purchase_time BETWEEN '2020-10-01' AND '2020-10-31 23:59:59'
GROUP BY store_id
HAVING COUNT(*) >= 5;


SELECT 
    store_id,
    MIN(TIMESTAMPDIFF(MINUTE, purchase_time, refund_time)) AS shortest_refund_minutes
FROM transactions
WHERE refund_time IS NOT NULL
GROUP BY store_id;


WITH first_order AS (
    SELECT 
        store_id,
        gross_transaction_value,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time) AS rn
    FROM transactions
)
SELECT store_id, gross_transaction_value
FROM first_order
WHERE rn = 1;


WITH first_purchase AS (
    SELECT
        buyer_id,
        transaction_id,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time) AS rn
    FROM transactions
)
SELECT 
    it.item_name,
    COUNT(*) AS order_count
FROM items it
JOIN first_purchase fp 
    ON it.item_id = (SELECT item_id FROM transactions WHERE transaction_id = fp.transaction_id)
WHERE fp.rn = 1
GROUP BY it.item_name
ORDER BY order_count DESC
LIMIT 1;


SELECT
    *,
    CASE 
        WHEN refund_time IS NOT NULL 
            AND TIMESTAMPDIFF(HOUR, purchase_time, refund_time) <= 72
        THEN 'REFUND_ALLOWED'
        ELSE 'REFUND_NOT_ALLOWED'
    END AS refund_flag
FROM transactions;


WITH ranked AS (
    SELECT
        transaction_id,
        buyer_id,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time) AS rn
    FROM transactions
    WHERE refund_time IS NULL   -- ignoring refunds
)
SELECT *
FROM ranked
WHERE rn = 2;

WITH ordered AS (
    SELECT 
        buyer_id,
        transaction_id,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time) AS rn
    FROM transactions
)
SELECT buyer_id, transaction_id, purchase_time
FROM ordered
WHERE rn = 2;










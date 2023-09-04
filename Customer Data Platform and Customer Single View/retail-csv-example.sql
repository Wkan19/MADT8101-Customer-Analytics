WITH RFM AS (
    SELECT
        o.user_id AS CUST_CODE,
        MAX(o.created_at) AS LAST_PURCHASE_DATE,
        COUNT(DISTINCT o.id) AS TOTAL_PURCHASES,
        SUM(o.total) AS TOTAL_SPEND
    FROM
        orders o
    WHERE
        o.user_id IS NOT NULL
    GROUP BY
        o.user_id
),
TimeBetweenPurchases AS (
    SELECT
        user_id,
        AVG(julianday(created_at) - julianday(prev_created_at)) AS MEAN_TIME_BETWEEN_PURCHASES
    FROM (
        SELECT
            user_id,
            created_at,
            LAG(created_at) OVER (PARTITION BY user_id ORDER BY created_at) AS prev_created_at
        FROM
            orders
    ) t
    GROUP BY
        user_id
),
CustomerSingleView AS (
    SELECT
        r.CUST_CODE AS cust_code,
        u.name AS name,
        u.address AS address,
        u.email AS email,
        u.birth_date AS birth_date,
        r.LAST_PURCHASE_DATE,
        r.TOTAL_PURCHASES,
        r.TOTAL_SPEND,
        tbp.MEAN_TIME_BETWEEN_PURCHASES
    FROM
        RFM r
    LEFT JOIN
        TimeBetweenPurchases tbp ON r.CUST_CODE = tbp.user_id
    LEFT JOIN
        users u ON r.CUST_CODE = u.id
)
SELECT
    cust_code,
    name,
    address,
    email,
    birth_date,
    LAST_PURCHASE_DATE,
    TOTAL_PURCHASES,
    TOTAL_SPEND,
    MEAN_TIME_BETWEEN_PURCHASES
FROM
    CustomerSingleView;

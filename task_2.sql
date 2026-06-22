-- january cohort
WITH users_cte AS (
    SELECT
        user_id,
        installed_at
    FROM users
    WHERE   installed_at >= '2023-01-01'::date
      AND installed_at < '2023-02-01'::date
),
-- revenue by pay.month
grouped_cte AS (
       SELECT
        date_trunc('MONTH', p.payment_at) AS month_payment,
        SUM(p.amount) AS month_amount
    FROM payments p
    JOIN users_cte u ON u.user_id = p.user_id
    GROUP BY month_payment
),
-- number of users
cohort_cte AS (
    SELECT
        COUNT(*) AS user_size
    FROM users_cte
)
-- cumulative ARPU
SELECT
       TO_CHAR(month_payment, 'MM-YYYY') AS month_payment,
       ROUND(
              SUM(month_amount) OVER (ORDER BY month_payment)::numeric
              / NULLIF(c.user_size, 0),
        2) AS cum_arpu
FROM grouped_cte
CROSS JOIN cohort_cte c

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
),month_cte AS (
    SELECT generate_series(
        '2023-01-01'::date,
        '2023-12-01'::date,
        interval '1 month'
    ) AS month_start
)
-- cumulative ARPU
SELECT
       TO_CHAR(month_start, 'MM-YYYY') AS month_payment,
       ROUND(
              SUM(COALESCE(month_amount, 0)) OVER (ORDER BY month_payment)::numeric
              / NULLIF(c.user_size, 0),
        2) AS cum_arpu
FROM month_cte m
LEFT JOIN grouped_cte ON m.month_start = month_payment
CROSS JOIN cohort_cte c

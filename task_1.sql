-- filter data and calculate label counts
WITH labels_cte AS  (
    SELECT
        ul.UserID,
        COUNT(DISTINCT ul.LabelID) AS label_counts
    FROM UserLabels ul
    WHERE ul.LabelName ILIKE '%bot%' AND ul.CreatedAt >= '2024-09-01'::date
    GROUP BY ul.UserID
)
SELECT
    u.Name,
    l.label_counts
FROM labels_cte l
JOIN Users u
    ON u.ID = l.UserID -- join aggregated results with user information
ORDER BY l.label_counts DESC;


 
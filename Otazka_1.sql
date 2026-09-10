-- Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- Vytvoření pohledu
CREATE OR REPLACE VIEW v_wage_diff as
SELECT 
	category,
	YEAR,
	value,
	LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
	value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Wage_diff
FROM t_jana_hrabkova_project_sql_primary_final
WHERE metric_type = 'wage'
AND category != 'Celá ekonomika';

SELECT 
	category,
	count (*) FILTER (WHERE Wage_diff < 0) AS Wage_decreased,
	count (*) FILTER (WHERE Wage_diff > 0) AS Wage_increased
FROM v_Wage_diff
GROUP BY category
ORDER BY category;

-- zobrazení view
SELECT * FROM v_Wage_diff;

-- Existují kategorie, kde mzdy pouze rostou (ano, jsou celkem 3)
SELECT 
	category,
	count (*) FILTER (WHERE Wage_diff < 0) AS Wage_decreased,
	count (*) FILTER (WHERE Wage_diff > 0) AS Wage_increased
FROM v_Wage_diff
GROUP BY category
Having count (*) FILTER (WHERE Wage_diff < 0) = 0
ORDER BY category;

-- Existují kategorie, kde mzdy pouze klesají (ne)
SELECT 
	category,
	count (*) FILTER (WHERE Wage_diff < 0) AS Wage_decreased,
	count (*) FILTER (WHERE Wage_diff > 0) AS Wage_increased
FROM v_Wage_diff
GROUP BY category
Having count (*) FILTER (WHERE Wage_diff > 0) = 0
ORDER BY category;

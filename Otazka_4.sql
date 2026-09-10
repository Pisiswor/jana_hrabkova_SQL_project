-- Otázka č. 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

-- a) Průměrná meziroční % změna cen potravin, po letech
SELECT 
	year,
	round(avg(percentage_diff)::NUMERIC,2) AS avg_price_diff
FROM v_price_diff
GROUP BY year
ORDER BY YEAR;

-- b) Meziroční % změna mezd, po letech, za celou ekonomiku
WITH Wage_diff AS (
	SELECT 
		YEAR,
		category,
		value,
		LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
		value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Difference,
		round(((value - LAG(value) OVER (PARTITION BY category ORDER BY Year))/NULLIF(LAG(value) OVER (PARTITION BY category ORDER BY Year),0)*100)::NUMERIC,2) AS Wage_percentage_diff
	FROM t_jana_hrabkova_project_sql_primary_final
	WHERE metric_type = 'wage'
	AND category = 'Celá ekonomika'
	)	
SELECT
	*
FROM Wage_diff
ORDER BY YEAR;

-- c) Spojení a) a b) ... Varianta A: rozdíl v procentních bodech
WITH 
Wage_diff AS (
	SELECT 
		YEAR,
		category,
		value,
		LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
		value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Difference,
		round(((value - LAG(value) OVER (PARTITION BY category ORDER BY Year))/NULLIF(LAG(value) OVER (PARTITION BY category ORDER BY Year),0)*100)::NUMERIC,2) AS Wage_percentage_diff
	FROM t_jana_hrabkova_project_sql_primary_final
	WHERE metric_type = 'wage'
	AND category = 'Celá ekonomika'
	),
Price_diff AS (
	SELECT 
		year,
		round(avg(percentage_diff)::NUMERIC,2) AS avg_price_diff
	FROM v_price_diff
	GROUP BY year
	)
SELECT
	Wage_diff.YEAR,
	Wage_percentage_diff,
	avg_price_diff,
	(avg_price_diff - Wage_percentage_diff) AS Price_wage_gap 
FROM Wage_diff 
JOIN Price_diff ON Wage_diff.YEAR = Price_diff.YEAR
--WHERE (avg_price_diff - Wage_percentage_diff) > 10
ORDER BY Wage_diff.year;

-- c) spojení a) a b) - Varianta B: relativní poměr
WITH
Wage_diff AS (
	SELECT
		Year,
		category,
		value,
		LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
		value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Difference,
		round(((value - LAG(value) OVER (PARTITION BY category ORDER BY Year))/NULLIF(LAG(value) OVER (PARTITION BY category ORDER BY Year),0)*100)::NUMERIC,2) AS Wage_percentage_diff
	FROM t_jana_hrabkova_project_sql_primary_final
	WHERE metric_type = 'wage'
	AND category = 'Celá ekonomika'
),
Price_diff AS (
	SELECT
		year,
		round(avg(percentage_diff)::NUMERIC,2) AS avg_price_diff
	FROM v_price_diff
	GROUP BY year
)
SELECT
	Wage_diff.Year,
	Wage_percentage_diff,
	avg_price_diff
FROM Wage_diff
JOIN Price_diff ON Wage_diff.Year = Price_diff.Year
WHERE avg_price_diff > Wage_percentage_diff * 1.10
-- WHERE Wage_diff.Year = 2013  -- rychlá kontrola roku 2013; zakomentovat předchozí where
ORDER BY Wage_diff.Year;

-- kroky a) a b) - pokus přes CASE - mírně odlišná čísla kvůli pořadí agregace
WITH yearly_summary AS (
	SELECT
		Year,
		MAX(CASE WHEN Metric_type = 'wage' THEN Value END) AS Wage,
		round(AVG(CASE WHEN Metric_type = 'price' THEN Value END)::NUMERIC,2) AS Avg_price
	FROM t_jana_hrabkova_project_sql_primary_final
	WHERE (Metric_type = 'wage' AND Category = 'Celá ekonomika')
	   OR (Metric_type = 'price')
	GROUP BY Year
)
SELECT
	Year,
	Wage,
	Avg_price,
	round(((Wage - LAG(Wage) OVER (ORDER BY Year)) / NULLIF(LAG(Wage) OVER (ORDER BY Year), 0) * 100)::NUMERIC,2) AS Wage_pct_diff,
	round(((Avg_price - LAG(Avg_price) OVER (ORDER BY Year)) / NULLIF(LAG(Avg_price) OVER (ORDER BY Year), 0) * 100)::NUMERIC,2) AS Price_pct_diff
FROM yearly_summary
ORDER BY Year;
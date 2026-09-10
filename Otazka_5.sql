-- Otázka č. 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějsším růstem?

-- tabulka % změn, stejný rok
WITH 
GDP_diff AS (
SELECT 	
	country,
	year,
	gdp,
	LAG(gdp) OVER (ORDER BY year) AS GDP_previous_year,
	gdp - LAG(gdp) OVER (ORDER BY year) AS GDP_diff,
	round(((gdp - LAG(gdp) OVER (ORDER BY year))/NULLIF(LAG(gdp) OVER (ORDER BY year),0)*100)::NUMERIC,2) AS GDP_percentage_diff
FROM t_jana_hrabkova_project_sql_secondary_final
WHERE country ilike 'Czech Republic'
-- ORDER BY YEAR
),
Wage_diff AS (
	SELECT 
		YEAR,
		category,
		value,
		LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
		value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Difference,
		round((((value - LAG(value) OVER (PARTITION BY category ORDER BY Year))/NULLIF(LAG(value) OVER (PARTITION BY category ORDER BY Year),0)*100))::NUMERIC,2) AS Wage_percentage_diff
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
	GDP_diff.YEAR,
	GDP_percentage_diff,
	Wage_percentage_diff,
	avg_price_diff
FROM GDP_diff
JOIN Price_diff ON GDP_diff.YEAR = Price_diff.YEAR
JOIN Wage_diff ON GDP_diff.YEAR = Wage_diff.YEAR
ORDER BY GDP_diff.YEAR;

-- tabulka % změn, posunutý rok
WITH 
GDP_diff AS (
SELECT 	
	country,
	year,
	gdp,
	LAG(gdp) OVER (ORDER BY year) AS GDP_previous_year,
	gdp - LAG(gdp) OVER (ORDER BY year) AS GDP_diff,
	round(((gdp - LAG(gdp) OVER (ORDER BY year))/NULLIF(LAG(gdp) OVER (ORDER BY year),0)*100)::NUMERIC,2) AS GDP_percentage_diff
FROM t_jana_hrabkova_project_sql_secondary_final
WHERE country ilike 'Czech Republic'
-- ORDER BY YEAR
),
Wage_diff AS (
	SELECT 
		YEAR,
		category,
		value,
		LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
		value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Difference,
		round((((value - LAG(value) OVER (PARTITION BY category ORDER BY Year))/NULLIF(LAG(value) OVER (PARTITION BY category ORDER BY Year),0)*100))::NUMERIC,2) AS Wage_percentage_diff
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
	GDP_diff.YEAR AS GDP_year,
	GDP_percentage_diff,
	Wage_diff.YEAR AS Wage_year,
	Wage_percentage_diff,
	Price_diff.YEAR AS Price_year,
	avg_price_diff
FROM GDP_diff
JOIN Price_diff ON GDP_diff.YEAR = Price_diff.YEAR - 1
JOIN Wage_diff ON GDP_diff.YEAR = Wage_diff.YEAR - 1
-- JOIN Price_diff ON GDP_diff.YEAR + 1 = Price_diff.YEAR
-- JOIN Wage_diff ON GDP_diff.YEAR + 1 = Wage_diff.YEAR
ORDER BY GDP_diff.YEAR;


-- zjištění statistické korelace pro stejný rok
SELECT
	round(CORR(GDP_percentage_diff, Wage_percentage_diff)::NUMERIC,4) AS Corr_gdp_wage,
	round(CORR(GDP_percentage_diff, avg_price_diff)::NUMERIC,4) AS Corr_gdp_price
From(
WITH 
GDP_diff AS (
SELECT 	
	country,
	year,
	gdp,
	LAG(gdp) OVER (ORDER BY year) AS GDP_previous_year,
	gdp - LAG(gdp) OVER (ORDER BY year) AS GDP_diff,
	(gdp - LAG(gdp) OVER (ORDER BY year))/NULLIF(LAG(gdp) OVER (ORDER BY year),0)*100 AS GDP_percentage_diff
FROM t_jana_hrabkova_project_sql_secondary_final
WHERE country ilike 'Czech Republic'
-- ORDER BY YEAR
),
Wage_diff AS (
	SELECT 
		YEAR,
		category,
		value,
		LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
		value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Difference,
		((value - LAG(value) OVER (PARTITION BY category ORDER BY Year))/NULLIF(LAG(value) OVER (PARTITION BY category ORDER BY Year),0)*100) AS Wage_percentage_diff
	FROM t_jana_hrabkova_project_sql_primary_final
	WHERE metric_type = 'wage'
	AND category = 'Celá ekonomika'
	),
Price_diff AS (
	SELECT 
		year,
		avg(percentage_diff) AS avg_price_diff
	FROM v_price_diff
	GROUP BY year
	)
SELECT
	GDP_diff.YEAR,
	GDP_percentage_diff,
	Wage_percentage_diff,
	avg_price_diff
FROM GDP_diff
JOIN Price_diff ON GDP_diff.YEAR = Price_diff.YEAR
JOIN Wage_diff ON GDP_diff.YEAR = Wage_diff.YEAR
ORDER BY GDP_diff.year
) sub

-- zjištění statistické korelace pro posunutý rok
SELECT
	round(CORR(GDP_percentage_diff, Wage_percentage_diff)::NUMERIC,4) AS Corr_gdp_wage_next_year,
	round(CORR(GDP_percentage_diff, avg_price_diff)::NUMERIC,4) AS Corr_gdp_price_next_year
FROM (
WITH 
GDP_diff AS (
SELECT 	
	country,
	year,
	gdp,
	LAG(gdp) OVER (ORDER BY year) AS GDP_previous_year,
	gdp - LAG(gdp) OVER (ORDER BY year) AS GDP_diff,
	(gdp - LAG(gdp) OVER (ORDER BY year))/NULLIF(LAG(gdp) OVER (ORDER BY year),0)*100 AS GDP_percentage_diff
FROM t_jana_hrabkova_project_sql_secondary_final
WHERE country ilike 'Czech Republic'
-- ORDER BY YEAR
),
Wage_diff AS (
	SELECT 
		YEAR,
		category,
		value,
		LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
		value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Difference,
		((value - LAG(value) OVER (PARTITION BY category ORDER BY Year))/NULLIF(LAG(value) OVER (PARTITION BY category ORDER BY Year),0)*100) AS Wage_percentage_diff
	FROM t_jana_hrabkova_project_sql_primary_final
	WHERE metric_type = 'wage'
	AND category = 'Celá ekonomika'
	),
Price_diff AS (
	SELECT 
		year,
		avg(percentage_diff) AS avg_price_diff
	FROM v_price_diff
	GROUP BY year
	)
SELECT
	GDP_diff.YEAR AS GDP_year,
	GDP_percentage_diff,
	Wage_diff.YEAR AS Wage_year,
	Wage_percentage_diff,
	Price_diff.YEAR AS Price_year,
	avg_price_diff
FROM GDP_diff
JOIN Price_diff ON GDP_diff.YEAR = Price_diff.YEAR - 1
JOIN Wage_diff ON GDP_diff.YEAR = Wage_diff.YEAR - 1
-- JOIN Price_diff ON GDP_diff.YEAR + 1 = Price_diff.YEAR  -- jen ověření, že i touto cestou dostanu stejné výsledky
-- JOIN Wage_diff ON GDP_diff.YEAR + 1 = Wage_diff.YEAR    -- jen ověření, že i touto cestou dostanu stejné výsledky
ORDER BY GDP_diff.YEAR
) sub;
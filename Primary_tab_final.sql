CREATE TABLE t_jana_hrabkova_project_SQL_primary_final AS
-- mzdy
SELECT 
	p.Payroll_year AS YEAR,
	'wage' AS Metric_type,
	COALESCE(b.name, 'Celá ekonomika') AS Category,
	AVG(p.Value) AS Value,
	'Kč' AS Unit
FROM czechia_payroll p
LEFT JOIN czechia_payroll_industry_branch b ON p.industry_branch_code = b.code
	WHERE p.Value_type_code = '5958' 
	AND p.Calculation_code = '200'
	AND p.Payroll_year BETWEEN 2006 AND 2018
GROUP BY p.Payroll_Year, b.name

UNION ALL

-- potraviny
SELECT
	extract(YEAR FROM Date_from) AS Year,
	'price' AS Metric_type,
	c.name AS Category,
	avg(pr.Value) AS Value,
	'Kč' AS Unit
FROM czechia_price pr
JOIN czechia_price_category c ON pr.category_code = c.code
WHERE pr.region_code IS NULL
AND extract(YEAR FROM pr.Date_from) BETWEEN 2006 AND 2018 -- v aktuálním zadání nadbytečné, ale přidávám pro jistotu, kdyby se rozsah dat změnil
GROUP BY c.name, Year
;


-- kontrola na počty řádků a zobrazené roky
SELECT Metric_type, COUNT(*), MIN(Year), MAX(Year)
FROM t_jana_hrabkova_project_SQL_primary_final
GROUP BY Metric_type;
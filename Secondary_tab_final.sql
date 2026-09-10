-- DROP TABLE t_jana_hrabkova_project_sql_secondary_final cascade; 

CREATE TABLE t_jana_hrabkova_project_sql_secondary_final AS
SELECT
	c.country,
	e.YEAR,
	e.gdp,
	e.gini,
	e.population
FROM economies e
INNER JOIN countries c ON c.country = e.country
WHERE trim(c.continent) ILIKE '%Europe%' -- asi zbytečně volné pravidlo, ale přemýšlela jsem nad "ukliknutím se" ve velikosti písmenka nebo nad prázdnými znaky na začátku; na druhou stranu se do výběru mohou dostat výsledky, které značí i něco jiného
AND e.YEAR BETWEEN 2006 AND 2018;


--kontrola na počty řádků a zobrazené roky
SELECT 
	COUNT(DISTINCT country),
	MIN(year), 
	MAX(year) 
FROM t_jana_hrabkova_project_sql_secondary_final;


-- Otázka 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

-- Vytvoření pohledu
CREATE OR REPLACE VIEW v_price_diff as
SELECT 
	category,
	YEAR,
	value,
	LAG(value) OVER (PARTITION BY category ORDER BY Year) AS Previous_year_value,
	value - LAG(value) OVER (PARTITION BY category ORDER BY Year) AS price_diff,
	((value - LAG(value) OVER (PARTITION BY category ORDER BY Year))/NULLIF(LAG(value) OVER (PARTITION BY category ORDER BY Year),0)*100) AS percentage_diff --NULLIF by mi mělo ošetřit "dělení nulou" a to tak, že vrátí "NULL" a neskončí chybou
FROM t_jana_hrabkova_project_sql_primary_final
WHERE metric_type = 'price'
ORDER BY category, year;

-- zobrazení pohledu
SELECT * FROM v_price_diff;

-- výběr kategorie na základě průměru meziročních změn = průměrná rychlost meziročního růstu/poklesu
-- může vyjít i kategorie, která je cenově nestabilní (střídá se růst a pokles cen)
-- zde nejnižší hodnota značí vlastně pokles
SELECT 
	category,
	round(avg(percentage_diff)::NUMERIC,2) AS avg_price_diff
FROM v_price_diff
GROUP BY category
ORDER BY avg_price_diff
LIMIT 1;

-- volím pouze hodnoty kladné, tedy růst
SELECT 
	category,
	round(avg(percentage_diff)::NUMERIC,2) AS avg_price_diff
FROM v_price_diff
GROUP BY category
Having avg(percentage_diff) >0
ORDER BY avg_price_diff
LIMIT 1;

-- kontrola výsledných kategorií - jde skutečně o trend zdražování/zlevňování nebo o rozkolísání cen oběma směry, kdy je tím ovlivněna průměrná hodnota?
SELECT
	category,
	Year,
	value,
	round(percentage_diff::numeric,2) AS percentage_diff
FROM v_price_diff
WHERE category = 'Cukr krystalový'
--WHERE category = 'Banány žluté'
ORDER BY Year;
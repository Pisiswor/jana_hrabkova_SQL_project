-- Otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

/* 
První období je 2006, poslední období je 2018
111301 = Chléb konzumní kmínový
114201 = Mléko polotučné pasterované 
*/

-- Co potřebuji
SELECT
	*
FROM t_jana_hrabkova_project_sql_primary_final
WHERE YEAR IN (2006,2018) 
AND category IN ('Celá ekonomika','Chléb konzumní kmínový','Mléko polotučné pasterované');

-- Pro každý rok chci tři sloupce místo tří řádků
SELECT 
	YEAR,
max(CASE WHEN category = 'Celá ekonomika' THEN value END) AS wage,
max(CASE WHEN category = 'Chléb konzumní kmínový' THEN value END) AS Price_of_chléb,
max(CASE WHEN category = 'Mléko polotučné pasterované' THEN value END) AS Price_of_mléko
FROM t_jana_hrabkova_project_sql_primary_final
WHERE YEAR IN (2006,2018) 
AND category IN ('Celá ekonomika','Chléb konzumní kmínový','Mléko polotučné pasterované')
group BY YEAR
ORDER BY YEAR;

-- Výsledný výpočet, hodnoty zaokrouhlené na 2 des. místa
SELECT 
	YEAR,
	wage,
	round(Price_of_Chléb:: numeric,2) AS Price_of_chléb,
	round(Price_of_Mléko:: numeric,2) AS Price_of_mléko,
	round((wage/Price_of_chléb):: numeric,2) AS Kg_chléb_affordable,
	round((wage/Price_of_mléko):: numeric,2) AS L_mléko_affordable
FROM (
	SELECT
		YEAR,
		max(CASE WHEN category = 'Celá ekonomika' THEN value END) AS Wage,
		max(CASE WHEN category = 'Chléb konzumní kmínový' THEN value END) AS Price_of_Chléb,
		max(CASE WHEN category = 'Mléko polotučné pasterované' THEN value END) AS Price_of_Mléko
	FROM t_jana_hrabkova_project_sql_primary_final
	WHERE YEAR IN (2006,2018) 
	AND category IN ('Celá ekonomika','Chléb konzumní kmínový','Mléko polotučné pasterované')
group BY YEAR
	) sub
ORDER BY YEAR;

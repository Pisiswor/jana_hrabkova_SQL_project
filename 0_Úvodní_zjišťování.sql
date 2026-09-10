SELECT * FROM czechia_payroll
/* hodnoty čtvrtletně 
 Id, Value, Value_type_code, Unit_code, Calculation_code, Industry_branch_code, Payroll_year, Payroll_quarter */

SELECT 
Min (payroll_year), /* 2000 */
Max (payroll_year)  /* 2021 */
FROM czechia_payroll

SELECT * FROM czechia_payroll_value_type
/* 316 = Průměrný počet zaměstnaných osob
  5958 = Průměrná hrubá mzda na zaměstnance
 */

SELECT * FROM czechia_payroll_unit
/* 200 = tis. osob (tis. os.)
 80403 = Kč
 */

SELECT * FROM czechia_payroll_calculation
/* 100 = fyzický
   200 = přepočtený
 */

SELECT * FROM czechia_payroll_industry_branch

-- Snaha ověřit, zda tabulka czechia_payroll obsahuje data za celou republiku?
-- např. na roce 2010 - hodnoty konzistentně blízké, industry_brand_code is null interpretuji jako celostátní průměr 
SELECT Payroll_quarter, AVG(Value) AS Avg_over_branches
FROM czechia_payroll
WHERE industry_branch_code IS NOT NULL
AND Value_type_code = '5958'
AND Calculation_code = '200'
AND Payroll_year = 2010
GROUP BY Payroll_quarter
ORDER BY Payroll_quarter;

SELECT Payroll_quarter, Value
FROM czechia_payroll
WHERE industry_branch_code IS NULL
AND Value_type_code = '5958'
AND Calculation_code = '200'
AND Payroll_year = 2010
ORDER BY Payroll_quarter;

SELECT * FROM czechia_price 
/* hodnoty po týdnech, po krajích + za celou ČR
 Id, Value, Category_code, Date_from, Date_to, Region_code */
-- WHERE region_code is NULL

SELECT 
Min (date_from), /* 2006-01-02 */
Max (date_from),  /* 2018-12-10 */
Min (date_to), /* 2006-01-08 */
Max (date_to)  /* 2018-12-16 */
FROM czechia_price
WHERE region_code IS null

SELECT * FROM czechia_price_category
/* 111301 = Chléb konzumní kmínový
 *114201 = Mléko polotučné pasterované */

SELECT * FROM czechia_region

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
SELECT * FROM countries

-- Continent = Europe

SELECT DISTINCT * FROM economies
WHERE country ILIKE '%europe%'
-- country, year, gdp, population gini, taxes, fertility, mortaliy_under5
--country = Europe & Central Asia (), European Union, Central Europe and the Baltics, Europe & Central Asia, Europe & Central Asia ()

-- vyberou se mi pouze "klasické" státy Evropy? ano
SELECT DISTINCT e.country
FROM economies e
JOIN countries c ON e.country = c.country
WHERE c.continent ilike '% Europe%'
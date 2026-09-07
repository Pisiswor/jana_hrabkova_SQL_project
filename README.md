**Dostupnost základních potravin ve vztahu ke mzdám v ČR**

Projekt zpracovaný pro analytické oddělení – SQL analýza dat o mzdách, cenách potravin a makroekonomických ukazatelích.

**1. Úvod a cíl projektu**

Cílem projektu je připravit datové podklady pro tiskové oddělení, které porovnávají dostupnost základních potravin (chléb, mléko) na základě průměrných příjmů v České republice za období, kdy jsou k dispozici srovnatelná data o mzdách i cenách. Jako doplňkový materiál je připravena tabulka s HDP, GINI koeficientem a populací evropských států za stejné období.

Výstupem projektu jsou dvě databázové tabulky (t_jana_hrabkova_project_SQL_primary_final, t_jana_hrabkova_project_sql_secondary_final) a sada SQL dotazů odpovídajících na pět výzkumných otázek.

**2. Zdrojová data**
Pomocí skriptu (0_Úvodní_zjišťování.sql) jsem prostudovala postupně níže uvedené tabulky. Jednalo se tak o prvotní se seznámení s obsahem jednotlivých tabulek.

***2.1 Použité tabulky***
| Tabulka | Obsah |
|---|---|
| `czechia_payroll` | Mzdy podle odvětví, čtvrtletně, 2000–2021, za celou ČR |
| `czechia_payroll_calculation` | Číselník: fyzický (100) / přepočtený (200) počet |
| `czechia_payroll_industry_branch` | Číselník odvětví |
| `czechia_payroll_unit` | Číselník jednotek (viz zjištěná anomálie níže) |
| `czechia_payroll_value_type` | Číselník typů hodnot (316 = počet zaměstnanců, 5958 = průměrná hrubá mzda) |
| `czechia_price` | Ceny vybraných potravin, týdenně, po krajích i za ČR celkem |
| `czechia_price_category` | Číselník kategorií potravin |
| `countries` | Údaje o zemích světa (mj. kontinent) |
| `economies` | HDP, GINI, populace aj. podle státu a roku |

2.2 Určení srovnatelného období

2.3 Klíčová rozhodnutí o filtrování dat

2.4 Zjištěná datová anomálie

# Dostupnost základních potravin ve vztahu ke mzdám v ČR

Projekt zpracovaný pro analytické oddělení – SQL analýza dat o mzdách, cenách potravin a makroekonomických ukazatelích.


## 1. Úvod a cíl projektu

Cílem projektu je připravit datové podklady pro tiskové oddělení, které porovnávají dostupnost základních potravin (chléb, mléko) na základě průměrných příjmů v České republice za období, kdy jsou k dispozici srovnatelná data o mzdách i cenách. Jako doplňkový materiál je připravena tabulka s HDP, GINI koeficientem a populací evropských států za stejné období.

Výstupem projektu jsou dvě databázové tabulky (t_jana_hrabkova_project_SQL_primary_final, t_jana_hrabkova_project_sql_secondary_final) a sada SQL dotazů odpovídajících na pět výzkumných otázek.


## 2. Zdrojová data

Pomocí skriptu (0_Úvodní_zjišťování.sql) jsem prostudovala postupně níže uvedené tabulky. Jednalo se tak o prvotní se seznámení s obsahem jednotlivých tabulek.

### *2.1 Použité tabulky*
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

### *2.2 Určení srovnatelného období*

Tabulka `czechia_payroll` obsahuje data dostupná za roky 2000 až 2021. Hodnoty jsou čtvrtletní, z toho důvodu jsem agregovala na na roční průměr.
Tabulka `czechia_price` obsahuje data za celou ČR (považuji za tyto hodnoty výskyt `region_code IS NULL`) dostupná za roky 2006–2018. Hodnoty jsou uvedeny jako týdenní záznamy i zde jsem agregovala na roční průměr.
Do primární tabulky jsem použila **průnik obou datových sad, a tedy období 2006 až 2018.**

### *2.3 Klíčová rozhodnutí o filtrování dat*

U mezd jsem použila `value_type_code = 5958` (Průměrná hrubá mzda) a `calculation_code = 200` (přepočtený počet). Dle mého se jedná o standardní a nejběžněji používanou metriku.
U cen jsem použila pouze řádky s `region_code IS NULL`, tedy hodnoty za celou ČR – abych zachovala stejnou úroveň agregace jako u mezd (které jsou dostupné jen za celou ČR).
Vedle rozpadu mezd po jednotlivých odvětvích jsem do primární tabulky zahrnula i souhrnný řádek s `industry_branch_code IS NULL`, označený jako kategorie **„Celá ekonomika“** – ověřeno, že jde o (vážený) celostátní průměr mzdy, ne o chybějící/neplatná data (viz ověření v sekci 2.4). Tento řádek je nezbytný pro výzkumné otázky 2, 4 a 5, které pracují s celostátní mzdou, nikoli s mzdou po odvětvích.

### *2.4 Zjištěná datová anomálie*

V tabulce `czechia_payroll` je **`unit_code` u hodnot typu mzda (5958) a počet zaměstnanců (316) prohozený** oproti definici v číselníku `czechia_payroll_unit`:

Podle číselníku: `200` = tis. osob, `80403` = Kč

V datech: `value_type_code = 5958` (mzda) se pojí vždy s `unit_code = 200`; `value_type_code = 316` (počet zaměstnanců) se pojí vždy s `unit_code = 80403`.

Ověřeno porovnáním rozsahu skutečných hodnot (`Value`) – mzda vychází v řádu 6 700–66 000 (odpovídá Kč), počet zaměstnanců v řádu 19–4 230 (odpovídá tis. osob). 

Závěr: `unit_code` u zdrojových dat považuji za nespolehlivý. Pro finální tabulku jsem jednotku (Kč) přiřadila napevno na základě `value_type_code`, nepřebírala jsem ji z `unit_code`.

V tabulce `economies` je překlep v názvu sloupce pro vyjádření **mortality (`mortaliy_under5`)**. Do aktuálně zpracovávaného projektu tento sloupeček není využit, takže jsem problém nebyla nucena řešit. Pokud bych jej měla použít, řešila bych buď "zapamatováním si názvu sloupce tak, jak je v databázi uveden" nebo bych požádala o opravu názvu sloupce ve zdrojové databázi. 


## 3. Finální tabulky

### *3.1 `t_jana_hrabkova_project_sql_primary_final`*

Struktura (dlouhý formát):
| Sloupec | Popis |
|---|---|
| `year` | Rok (2006–2018) |
| `metric_type` | `'wage'` (mzda) nebo `'price'` (cena potraviny) |
| `category` | Název odvětví (u mezd) nebo potraviny (u cen); `'Celá ekonomika'` pro celostátní mzdu |
| `value` | Roční průměrná hodnota (Kč) |
| `unit` | Jednotka (Kč), přiřazena napevno – viz 2.4 |

Tabulku jsem vytvořila spojením agregovaných mezd (roční průměr ze 4 čtvrtletí, `LEFT JOIN` na číselník odvětví s `COALESCE` pro souhrnný řádek) a agregovaných cen potravin (roční průměr z týdenních dat, `JOIN` na číselník kategorií) přes `UNION ALL`.

Poznámka: Tabulka obsahuje čitelné názvy kategorií (ne číselné kódy) pro přímou použitelnost výstupu tiskovým oddělením. Číselné kódy jsem do tabulky nezahrnula – jednalo se o vědomé rozhodnutí ve prospěch čitelnosti. Nicméně pro vyvarování se případných jazykových mutací by bylo vhodnější číselné kódy uvést a ve filtrování používat raději ty.

### *3.2 `t_jana_hrabkova_project_sql_secondary_final`*

Struktura (široký formát):
| Sloupec | Popis |
|---|---|
| `country` | Název evropského státu |
| `year` | Rok (2006–2018) |
| `gdp` | HDP |
| `gini` | GINI koeficient |
| `population` | Populace |

Tabulku jsem vytvořila spojením tabulek `economies` a `countries` (filtr `continent = 'Europe'`), čímž byly zároveň automaticky odfiltrovány souhrnné/regionální položky přítomné v `economies.country` (např. „European Union“, „Europe & Central Asia“), které nemají odpovídající záznam v `countries`.

## 4. Odpovědi na výzkumné otázky

*Poznámka:* Meziroční procentuální změny jsem se snažila ve všech otázkách počítat pomocí okenní funkce `LAG()`, vzorcem `(aktuální − předchozí) / předchozí × 100`. Dělení nulou jsem ošetřila pomocí `NULLIF`.


### *Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*

**Postup:** Pro každé odvětví jsem spočítala meziroční změnu mzdy za všechny dostupné roky (2006–2018); dále jsem zjišťovala, ve kterých odvětvích se vyskytl alespoň jeden rok s meziročním poklesem.

**Výsledek:** Velice zjednodušeně lze říci, že ve všech odvětvích mzdy meziročně spíše rostly. Říkám spíše, neboť se ve většině odvětví vyskytl alespoň jeden rok, kdy mzdy naopak mírně poklesly oproti předchozímu období. Čistě meziroční růst jsem ve sledovaném období zaznamenala pouze u tří odvětví: Ostatní činnosti, Zdravotní a sociální péče, Zpracovatelský průmysl. Odvětví, ve kterém by mzda pouze klesala jsem naštěstí nezaznamenala žádné. 

**Závěr:** Lze říci, že mzdy ve všech odvětvích v průběhu let rostou. Výkyvy v určitých letech, kdy mzdy naopak meziročně klesly by bylo zajímavé prozkoumat z širšího pohledu - co se ten rok u nás/ve světě dělo (hospodářská krize, válka, volby, ....). 


### *Otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?*

**Postup:** Porovnávala jsem roky 2006 a 2018, které byly společné pro ceny i mzdy jako krajní hodnoty. Celostátní průměrnou mzdu (kategorie „Celá ekonomika“) jsem vydělila cenou chleba (Chléb konzumní kmínový) a cenou mléka (Mléko polotučné pasterované) za daný rok.

**Výsledek:**
| Rok | Mzda (Kč) | Cena chleba (Kč) | Cena mléka (Kč) | Kg chleba za mzdu | L mléka za mzdu |
|---|---|---|---|---|---|
| 2006 | 19536| 16,12 | 14,44 | 1211,66 | 1353,10 |
| 2018 | 32043 | 24,24 | 19,82 | 1322,00 | 1616,77 |

**Závěr:** Z tabulky je zřejmé, že v roce 2018 jsme si mohli koupit o 110,34 kg více chleba (přibližně o 9 %) a o 263,67 l více mléka (přibližně o 19 %) než v roce 2006, přestože cena obou komodit vzrostla. Nárůst ceny potravin byl v porovnání s růstem mezd nižší. Mzda vzrostla o přibližně 64 %, zatímco cena chleba o 50 % a cena mléka o 37 %.  


### *Otázka 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*

**Postup:** Pro každou kategorii potravin jsem spočítala průměr meziročních procentuálních změn ceny přes celé období 2006–2018.

**Poznámka:** Kategorie s nejnižším průměrem meziroční změny obsahovala jak roky s růstem, tak s poklesem ceny (cena do r. 2010 klesala, 2011–2013 rostla, 2014–2016 klesala, 2017 vzrostla, 2018 klesla) – jde tedy o kolísavý, nikoli stabilně pomalu rostoucí cenový vývoj. Vzhledem k doslovnému znění otázky („nejnižší nárůst“) jsem zvažovala omezení výběru jen na kategorie s kladným průměrem meziroční změny (tj. skutečně zdražující kategorie), aby nevyhrála kategorie, která ve výsledku spíše zlevňuje.

**Výsledek (všechny kategorie):** Pokud vybírám kategorii s nejpomaleji rostoucí cenou bez jakéhokoliv dalšího omezení, výsledkem je "Cukr krystalový", kdy percentuální meziroční nárůst je ve skutečnosti pokles. 

**Výsledek (pouze kategorie s kladným průměrným meziročním nárůstem):** Výsledkem při omezení se pouze na kategorie s kladným průměrným meziročním nárůstem cen je kategorie "Banány žluté". 

**Závěr:** U obou výsledných kategorií jsem dále zkoumala směr vývoje cen v jednotlivých letech. Z mého pohledu není možné striktně hovořit o trendu zdražování/zlevňování. Ve sledovaném období jsou ceny rozkolísané oběma směry což ovlivňuje průměrnou hodnotu. Výsledné kategorie jsou dle mého názoru výstupem čistě matematickým. Pro přesnější výsledek by bylo vhodné porovnávat trend v čase.


### *Otázka 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*

**Postup:** Vzhledem k tomu, že jsem v průběhu práce narazila na skutečnost, že si danou otázku umím vyložit více způsoby, spočítala jsem dvě varianty:

- **Varianta A: absolutní rozdíl v procentních bodech:** `průměrná meziroční % změna cen − meziroční % změna mzdy > 10`
- **Varianta B: relativní poměr:** `průměrná meziroční % změna cen > meziroční % změna mzdy × 1,10`

**Výsledek**

– Varianta A: V žádném roce 2006–2018 rozdíl nepřesáhl 10 procentních bodů. Nejblíže byl rok 2007 (ceny +9,26 %, mzdy +7,22 %, rozdíl cca 2 p. b.).

– Varianta B: Podmínku splnily roky 2007, 2008, 2011, 2012, 2013.

**Poznámka k roku 2013:** V tomto roce mzdy meziročně mírně klesly (−0,13 %), zatímco ceny potravin vzrostly o 6,01 %. Vzhledem k tomu, že násobení záporné hodnoty koeficientem 1,10 podmínku Varianty B splní i při relativně mírném růstu cen, interpretovala bych tento rok s touto výhradou (v absolutním vyjádření – Variantě A – činí rozdíl 6,14 p. b., tedy pod stanovenou hranicí).

**Závěr:** Odpověď na otázku závisí na zvoleném postupu. Při striktním výkladu „o 10 procentních bodů vyšší“ (Varianta A) hypotéza neplatí pro žádný rok sledovaného období. Při výkladu „o 10 % relativně vyšší“ (Varianta B) hypotéza platí pro roky 2007, 2008, 2011, 2012 a s výhradou 2013.

**Poznámka ke skriptu:** Ve skriptu pro otázku 4 jsem si na konci zkusila provést výpočet přes CASE. Výsledek je ve své podstatě stejný, jen vypočtená čísla se mírně liší. Dle mého by toto mohlo být způsobeno pořadím agregace. 


### *Otázka č. 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?*

**Postup:** Spočítala jsem meziroční % změnu HDP ČR (`LAG` na datech ze sekundární tabulky), a porovnala jsem ji s meziroční % změnou mezd a cen potravin. Výpočet, resp. porovnání jsem provedla jednak ve stejném roce, jednak s ročním zpožděním (HDP rok X vs. mzdy/ceny rok X+1). Sílu vztahu jsem zkusila ověřit pomocí funkce korelace (`CORR`) - tuším, že by se mělo jednat o Pearsonův korelační koeficient.

**Výsledek:**
| Vztah | Stejný rok | Následující rok |
|---|---|---|
| HDP → mzdy | 0,49 | 0,70 |
| HDP → ceny potravin | 0,43 | 0,05 |

**Interpretace:**
- Vztah mezi **růstem HDP a růstem mezd** je silnější s ročním zpožděním – naznačuje to, že se vývoj HDP promítá do mezd spíše s odstupem jednoho roku (např. v důsledku každoročního přehodnocování mezd na základě předchozích výsledků).
- Vztah mezi **HDP a cenami potravin** je naopak silnější ve stejném roce; s ročním zpožděním prakticky mizí.

**Poznámka:** Při analýze vycházím pouze ze 12–13 ročních pozorování, což je pro spolehlivý statistický závěr málo. Korelační koeficienty je třeba chápat jako orientační náznak, nikoli jako průkazný důkaz příčinné souvislosti.

**Závěr:** Data naznačují mírnou až středně silnou souvislost mezi HDP a mzdami (silnější s ročním zpožděním) a slabší, méně jednoznačnou souvislost mezi HDP a cenami potravin (silnější bez zpoždění). Vzhledem k malému vzorku dat doporučujeme závěr prezentovat s touto výhradou.

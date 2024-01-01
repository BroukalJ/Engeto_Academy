-- Výmaz tabulky s evropskými státy a jejich dalšími údaji
-- =======================================================
DROP TABLE IF EXISTS t_Jiri_Broukal_project_SQL_secondary_final;

-- Založení nové tabulky
-- =====================
CREATE TABLE IF NOT EXISTS t_Jiri_Broukal_project_SQL_secondary_final (
	id INT NOT NULL AUTO_INCREMENT,
	dataset VARCHAR (11) NOT NULL,
	country TEXT,
	abbreviation TEXT,
	avg_height DOUBLE,
	calling_code DOUBLE,
	capital_city TEXT,
	continent TEXT,
	currency_name TEXT,
	religion TEXT,
	currency_code TEXT,
	domain_tld TEXT,
	elevation DOUBLE,
	north DOUBLE,
	south DOUBLE,
	west DOUBLE,
	east DOUBLE,
	government_type TEXT,
	independence_date DOUBLE,
	iso_numeric DOUBLE,
	landlocked DOUBLE,
	life_expectancy DOUBLE,
	national_symbol TEXT,
	national_dish TEXT,
	population_density DOUBLE,
	population DOUBLE,
	region_in_world TEXT,
	surface_area DOUBLE,
	yearly_average_temperature DOUBLE,
	median_age_2018 DOUBLE,
	iso2 TEXT,
	iso3 TEXT,
	data_year INT(11) ,
	GDP DOUBLE,
	population_eco DOUBLE,
	gini DOUBLE,
	taxes DOUBLE,
	fertility DOUBLE,
	mortaliy_under5 DOUBLE,
	PRIMARY KEY (id),
	KEY (dataset)
);

-- Naplnění tabulky daty z tabulky countries
-- =========================================
INSERT INTO t_Jiri_Broukal_project_SQL_secondary_final
	(
	dataset,
	country ,
	abbreviation ,
	avg_height ,
	calling_code ,
	capital_city ,
	continent ,
	currency_name ,
	religion ,
	currency_code ,
	domain_tld ,
	elevation ,
	north ,
	south ,
	west ,
	east ,
	government_type ,
	independence_date ,
	iso_numeric ,
	landlocked ,
	life_expectancy ,
	national_symbol ,
	national_dish ,
	population_density ,
	population ,
	region_in_world ,
	surface_area ,
	yearly_average_temperature ,
	median_age_2018 , 
	iso2 ,
	iso3 
	)		
SELECT
	'country',
	country ,
	abbreviation ,
	avg_height ,
	calling_code ,
	capital_city ,
	continent ,
	currency_name ,
	religion ,
	currency_code ,
	domain_tld ,
	elevation ,
	north ,
	south ,
	west ,
	east ,
	government_type ,
	independence_date ,
	iso_numeric ,
	landlocked ,
	life_expectancy ,
	national_symbol ,
	national_dish ,
	population_density ,
	population ,
	region_in_world ,
	surface_area ,
	yearly_average_temperature ,
	median_age_2018 ,
	iso2 ,
	iso3
FROM countries c 
WHERE 1=1
	AND continent = 'Europe'
;

-- Naplnění tabulky daty jednotlivých států z tabulky economies
-- ============================================================
INSERT INTO t_Jiri_Broukal_project_SQL_secondary_final
	(
	dataset,
	country ,
	data_year ,
	GDP ,
	population_eco ,
	gini ,
	taxes ,
	fertility ,
	mortaliy_under5 
	)
SELECT
	'country_eco',
	e.country,
	e.year ,
	e.GDP ,
	e.population ,
	e.gini ,
	e.taxes ,
	e.fertility ,
	e.mortaliy_under5 
FROM economies e
INNER JOIN countries c 
	ON c.country = e.country 
WHERE c.continent = 'Europe'
;

-- Naplnění tabulky daty oblastí (které se týkají Evropy či její části) z tabulky economies
-- ========================================================================================
INSERT INTO t_Jiri_Broukal_project_SQL_secondary_final
	(
	dataset,
	country ,
	data_year ,
	GDP ,
	population_eco ,
	gini ,
	taxes ,
	fertility ,
	mortaliy_under5 
	)
SELECT
	'area',
	e.country,
	e.year ,
	e.GDP ,
	e.population ,
	e.gini ,
	e.taxes ,
	e.fertility ,
	e.mortaliy_under5 
FROM economies e
WHERE 
	INSTR (country, 'Euro') > 0	
;
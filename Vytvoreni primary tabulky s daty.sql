-- Výmaz tabulky mezd a cen
-- ========================
DROP TABLE IF EXISTS t_Jiri_Broukal_project_SQL_primary_final;

-- Založení nové tabulky mezd a cen
-- ================================
CREATE TABLE IF NOT EXISTS t_Jiri_Broukal_project_SQL_primary_final (
	id INT NOT NULL AUTO_INCREMENT,
	dataset VARCHAR (10) NOT NULL,
	payroll DOUBLE,
	employees DOUBLE,
	payroll_industry_branch_code VARCHAR (1),
	industry_branch VARCHAR (255),
	data_year SMALLINT,
	price DOUBLE,
	price_category INT,
	price_cat_name VARCHAR (50),
	price_cat_unit VARCHAR (10),
	PRIMARY KEY (id),
	KEY (dataset)
);

-- Naplnění tabulky daty mezd
-- ==========================
INSERT INTO t_Jiri_Broukal_project_SQL_primary_final
	(
	dataset,
	payroll,
	payroll_industry_branch_code,
	industry_branch,
	data_year
	)		
SELECT
	'payrolls',
	ROUND(AVG(cpa.value),0),
	IF (cpa.industry_branch_code IS NULL, "-", cpa.industry_branch_code) ,
	IF (cpib.name IS NULL, "-", cpib.name) AS branch_name,
	cpa.payroll_year
FROM czechia_payroll cpa 
LEFT OUTER JOIN czechia_payroll_industry_branch cpib
	ON cpa.industry_branch_code = cpib.code 
WHERE 1=1
	AND cpa.value_type_code = 5958
	AND cpa.unit_code = 200
	AND cpa.calculation_code = 200
GROUP BY cpa.industry_branch_code, cpa.payroll_year 
;

-- Naplnění tabulky daty o počtu osob
-- ==================================
INSERT INTO t_Jiri_Broukal_project_SQL_primary_final
	(
	dataset,
	employees,
	payroll_industry_branch_code,
	industry_branch,
	data_year
	)		
SELECT
	'empl',
	ROUND(AVG(cpa.value),0),
	IF (cpa.industry_branch_code IS NULL, "-", cpa.industry_branch_code) ,
	IF (cpib.name IS NULL, "-", cpib.name) AS branch_name,
	cpa.payroll_year
FROM czechia_payroll cpa 
LEFT OUTER JOIN czechia_payroll_industry_branch cpib
	ON cpa.industry_branch_code = cpib.code 
WHERE 1=1
		AND value_type_code = 316
		AND calculation_code = 200
		AND unit_code = 80403
GROUP BY cpa.industry_branch_code, cpa.payroll_year 
;

-- Naplnění tabulky daty cen
-- =========================
INSERT INTO t_Jiri_Broukal_project_SQL_primary_final
	(
	dataset,
	price,
	price_category,
	price_cat_name,
	price_cat_unit,
	data_year
	)	
SELECT
	'prices',
	ROUND(AVG(cpr.value),2),
	cpr.category_code,
	cprc.name,
	CONCAT (cprc.price_value,' ',cprc.price_unit),
	YEAR (cpr.date_from) AS price_year
FROM czechia_price cpr
INNER JOIN czechia_price_category cprc
	ON cpr.category_code = cprc.code 
WHERE 1=1
GROUP BY cpr.category_code, price_year

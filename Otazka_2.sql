-- Data pro otázku: 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
WITH tjb2 AS (
	SELECT
		payroll_industry_branch_code ,
		data_year,
		employees 
	FROM t_Jiri_Broukal_project_SQL_primary_final
	WHERE 1=1
		AND dataset = "empl"
	ORDER BY payroll_industry_branch_code, data_year	
),
	tjb_mlk AS (
	SELECT
		tjb.price ,
		tjb.price_cat_name ,
		tjb.data_year 
	FROM t_Jiri_Broukal_project_SQL_primary_final tjb
	WHERE 1=1
		AND dataset = "prices"
		AND (tjb.price_category = 114201)
),
	tjb_brd AS (
	SELECT
		tjb.price ,
		tjb.price_cat_name ,
		tjb.data_year 
	FROM t_Jiri_Broukal_project_SQL_primary_final tjb
	WHERE 1=1
		AND dataset = "prices"
		AND (tjb.price_category = 111301)
)
SELECT
	tjb.data_year ,
	tjb.payroll,
	tjb_mlk.price_cat_name AS name_1,
	tjb_mlk.price AS price_of_milk,
	ROUND (tjb.payroll / tjb_mlk.price, 0) AS l_of_milk,
	tjb_brd.price_cat_name AS name_2,
	tjb_brd.price AS price_of_bread,
	-- tjb_brd.data_year AS year_of_bread ,
	ROUND (tjb.payroll / tjb_brd.price, 0) AS kg_of_bread
FROM t_Jiri_Broukal_project_SQL_primary_final tjb
LEFT OUTER JOIN tjb2
	ON tjb.payroll_industry_branch_code = tjb2.payroll_industry_branch_code
	AND tjb.data_year = tjb2.data_year
LEFT OUTER JOIN tjb_mlk
	ON tjb.data_year = tjb_mlk.data_year
LEFT OUTER JOIN tjb_brd
	ON tjb.data_year = tjb_brd.data_year
WHERE 1=1
	AND tjb.dataset = "payrolls"
	AND tjb.industry_branch = "-"
	AND (tjb.data_year = 2006 OR tjb.data_year = 2018)

-- Data pro otázku: 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
WITH base_avg_prices AS (
	SELECT 
		tjb.data_year,
		ROUND (AVG(price),2) AS avg_price
	FROM t_jiri_broukal_project_sql_primary_final tjb
	WHERE 1=1
		AND tjb.dataset = "prices"
	GROUP BY tjb.data_year 
	ORDER BY tjb.data_year
),
avg_prices AS (
	SELECT 
		data_year,
		LAG(avg_price) OVER (ORDER BY data_year) AS lag_avg_price,
		avg_price
	FROM base_avg_prices
),
base_payrolls AS (
	SELECT 
		payroll_industry_branch_code,
		industry_branch,
		data_year,
		payroll
	FROM t_jiri_broukal_project_sql_primary_final tjb
	WHERE 1=1
		AND dataset = 'payrolls'
	GROUP BY industry_branch , data_year 
),
lagged_payrolls AS (
	SELECT
		*,
		IF (STRCMP(LAG(payroll_industry_branch_code) OVER (ORDER BY payroll_industry_branch_code, data_year), payroll_industry_branch_code) = 0,
			LAG(payroll) OVER (ORDER BY payroll_industry_branch_code, data_year),
			NULL
			) AS lag_payroll
	FROM base_payrolls
),
grow_payrolls AS (
	SELECT
		data_year,
		payroll,
		lag_payroll,
		ROUND((payroll/lag_payroll-1)*100,1) AS grow_payroll_perc
	FROM lagged_payrolls
	WHERE 1=1
		AND industry_branch = "-"
),
base AS (
	SELECT 
		gp.data_year,
		gp.lag_payroll,
		gp.payroll,
		gp.grow_payroll_perc,
		avg_prices.lag_avg_price AS lag_avg_price,
		avg_prices.avg_price AS avg_price,
		ROUND((avg_prices.avg_price/avg_prices.lag_avg_price-1)*100,1) AS grow_price_perc
	FROM grow_payrolls gp
	INNER JOIN avg_prices
		ON avg_prices.data_year = gp.data_year
),
base_pay_price AS (
	SELECT 
		data_year,
		lag_payroll,
		payroll,
		grow_payroll_perc,
		lag_avg_price,
		avg_price,
		grow_price_perc
	FROM base
	ORDER BY data_year
),
base_GDP AS (
	SELECT 
		country ,
		data_year ,
		GDP,
		LAG(GDP) OVER (ORDER BY data_year) AS lag_GDP
	FROM t_jiri_broukal_project_sql_secondary_final tjb_sec
	WHERE 1=1
		AND dataset = 'country_eco'
		AND country = 'Czech Republic'
	ORDER BY data_year
),
base_fin1 AS (
	SELECT 
		bpp.data_year,
		lag_payroll,
		payroll,
		grow_payroll_perc,
		lag_avg_price,
		avg_price,
		grow_price_perc,
		ROUND((GDP/lag_GDP-1)*100,1) AS grow_GDP_perc
	FROM base_pay_price bpp
	LEFT JOIN base_GDP gdp
		ON bpp.data_year = gdp.DATA_year
	ORDER BY bpp.data_year
),
base_fin2 AS (
	SELECT 
		data_year,
		grow_GDP_perc,
		grow_payroll_perc,
		LEAD(grow_payroll_perc) OVER (ORDER BY data_year) AS lead_payroll_perc ,
		grow_price_perc,
		LEAD(grow_price_perc) OVER (ORDER BY data_year) AS lead_price_perc 
	FROM base_fin1 bf1
	ORDER BY data_year
)
SELECT
	*
FROM base_fin2 bf2
WHERE 1=1
	AND grow_price_perc IS NOT NULL
ORDER BY bf2.data_year ASC

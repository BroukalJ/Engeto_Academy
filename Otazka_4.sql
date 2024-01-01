-- Data pro otázku: 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
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
		avg_prices.lag_avg_price,
		avg_prices.avg_price,
		ROUND((avg_prices.avg_price/avg_prices.lag_avg_price-1)*100,1) AS grow_price_perc
	FROM grow_payrolls gp
	INNER JOIN avg_prices
		ON avg_prices.data_year = gp.data_year
)
SELECT 
	*,
	grow_price_perc - grow_payroll_perc AS diff_grow_price_grow_payroll
FROM base
WHERE 1=1
	AND lag_payroll IS NOT NULL
	AND lag_avg_price IS NOT NULL 
	AND avg_price IS NOT NULL 
ORDER BY data_year
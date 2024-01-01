-- Data pro otázku: 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
WITH base_payrolls AS (
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
)
SELECT
	*,
	ROUND((payroll/lag_payroll-1)*100,1) AS grow_payroll_perc
FROM lagged_payrolls
-- Data pro otázku: 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
WITH base_prices AS (
	SELECT 
		tjb.data_year,
		tjb.price_category ,
		tjb.price_cat_name,
		tjb.price 
	FROM t_jiri_broukal_project_sql_primary_final tjb
	WHERE 1=1
		AND tjb.dataset = "prices"
		AND (tjb.data_year = 2006 OR tjb.data_year = 2018)
	ORDER BY tjb.price_category, tjb.data_year 
),
lagged_prices AS (
	SELECT 
		*,
		IF (LAG(price_category) OVER (ORDER BY price_category, data_year) = price_category, 
			LAG(data_year) OVER (ORDER BY price_category, data_year),
			NULL 
			) AS lag_year,
		IF (LAG(price_category) OVER (ORDER BY price_category, data_year) = price_category, 
			LAG(price) OVER (ORDER BY price_category, data_year),
			NULL 
			) AS lag_price
	FROM base_prices
)
SELECT
	price_cat_name AS Category,
	lag_year AS 1st_year,
	lag_price AS 1st_price,
	data_year AS last_year,
	price AS last_price,	
	ROUND((price/lag_price-1)*100/(data_year-lag_year),1) AS grow_price_perc
FROM lagged_prices
WHERE 1=1
	AND lag_price IS NOT NULL
ORDER BY grow_price_perc
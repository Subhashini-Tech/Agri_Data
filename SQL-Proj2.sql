# 1.Year-wise Trend of Rice Production Across States (Top 3)
SELECT 
    a.year,
    a.state_name,
    SUM(a.rice_production) AS total_rice_production
FROM 
    agri.agri_data a
JOIN (
    -- Top 3 states by total rice production
    SELECT state_name
    FROM agri.agri_data
    GROUP BY state_name
    ORDER BY SUM(rice_production) DESC
    LIMIT 3
) top_states ON a.state_name = top_states.state_name
GROUP BY a.year, a.state_name
ORDER BY a.year ASC, SUM(a.rice_production) DESC;
# 2.Top 5 Districts by Wheat Yield Increase Over the Last 5 Years
SELECT dist_name, state_name, MAX(wheat_yield)-MIN(wheat_yield) AS yield_increase
FROM agri.agri_data
WHERE year >= (SELECT MAX(year)-4 FROM agri.agri_data)
GROUP BY state_name, dist_name
ORDER BY yield_increase DESC
LIMIT 5;
# 3.States with the Highest Growth in Oilseed Production (5-Year Growth Rate)
SELECT state_name, (MAX(oilseeds_production)-MIN(oilseeds_production))/MIN(oilseeds_production)*100 AS growth_rate
FROM agri.agri_data
WHERE year >= (SELECT MAX(year)-4 FROM agri.agri_data)
GROUP BY state_name
ORDER BY growth_rate DESC
LIMIT 5;
# 4.District-wise Correlation Between Area and Production for Major Crops (Rice, Wheat, and Maize)
SELECT 
    state_name,
    dist_name,
    (
        (AVG(rice_area * rice_production) - AVG(rice_area) * AVG(rice_production)) /
        (SQRT( (AVG(rice_area * rice_area) - POW(AVG(rice_area), 2)) *
               (AVG(rice_production * rice_production) - POW(AVG(rice_production), 2)) ))
    ) AS rice_corr,
    (
        (AVG(wheat_area * wheat_production) - AVG(wheat_area) * AVG(wheat_production)) /
        (SQRT( (AVG(wheat_area * wheat_area) - POW(AVG(wheat_area), 2)) *
               (AVG(wheat_production * wheat_production) - POW(AVG(wheat_production), 2)) ))
    ) AS wheat_corr,
    (
        (AVG(maize_area * maize_production) - AVG(maize_area) * AVG(maize_production)) /
        (SQRT( (AVG(maize_area * maize_area) - POW(AVG(maize_area), 2)) *
               (AVG(maize_production * maize_production) - POW(AVG(maize_production), 2)) ))
    ) AS maize_corr
FROM agri.agri_data
GROUP BY state_name, dist_name;
# 5.Yearly Production Growth of Cotton in Top 5 Cotton Producing States
SELECT 
    year,
    state_name,
    SUM(cotton_production) AS total_cotton_production
FROM agri.agri_data
WHERE state_name IN (
    SELECT state_name
    FROM (
        SELECT state_name, SUM(cotton_production) AS total_prod
        FROM agri.agri_data
        GROUP BY state_name
        ORDER BY total_prod DESC
        LIMIT 5
    ) AS top_states
)
GROUP BY year, state_name
ORDER BY year ASC, total_cotton_production DESC;
# 6.Districts with the Highest Groundnut Production in 2020
SELECT dist_name, state_name, groundnut_production, year
FROM agri.agri_data
WHERE year = 2020
ORDER BY groundnut_production DESC, year desc
LIMIT 5;
# 7.Annual Average Maize Yield Across All States
SELECT year, AVG(maize_yield) AS avg_maize_yield
FROM agri.agri_data
GROUP BY year
ORDER BY year;
# 8.Total Area Cultivated for Oilseeds in Each State
SELECT state_name, SUM(oilseeds_area) AS total_oilseeds_area
FROM agri.agri_data
GROUP BY state_name
ORDER BY total_oilseeds_area DESC;
# 9.Districts with the Highest Rice Yield
SELECT year,
       state_name,
       dist_name,
       avg_yield,
       yield_rank
FROM (
    SELECT year,
           state_name,
           dist_name,
           AVG(rice_yield) AS avg_yield,
           DENSE_RANK() OVER (
               PARTITION BY year, state_name
               ORDER BY AVG(rice_yield) DESC
           ) AS yield_rank
    FROM agri.agri_data
    GROUP BY year, state_name, dist_name
) ranked
WHERE yield_rank = 1
ORDER BY year DESC, state_name, dist_name;
# 10.Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years
SELECT year,
       state_name,
       SUM(rice_production) AS rice_production,
       SUM(wheat_production) AS wheat_production
FROM (
    SELECT year,
           state_name,
           rice_production,
           wheat_production,
           DENSE_RANK() OVER (
               PARTITION BY year
               ORDER BY (rice_production + wheat_production) DESC
           ) AS prod_rank
    FROM (
        SELECT year,
               state_name,
               SUM(rice_production) AS rice_production,
               SUM(wheat_production) AS wheat_production
        FROM agri.agri_data
        GROUP BY year, state_name
    ) yearly_state
) ranked
WHERE prod_rank <= 5
  AND year >= (SELECT MAX(year) - 9 FROM agri.agri_data)   -- last 10 years
GROUP BY year, state_name
ORDER BY year DESC, (rice_production + wheat_production) DESC;
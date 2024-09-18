select * from eco_productivity;
select * from sector_income;

alter table eco_productivity
change column ï»¿City city text;

alter table eco_productivity
CHANGE COLUMN `ICT Sector Employment (%)` `ict_sector_emp`double;

select * from eco_productivity
where rd_expenditure is null;

select * from sector_income
where gdp_billion is null;

-- insights : so there is not null values in both columns.

-- 1. Calculate the Average Unemployment Rate Across All Cities for a  Year 2022
select city,`year`,avg(unemployment_rate) as avg_unemployment_rate
from eco_productivity
where `year` = 2023
group by city,`year`;

-- 2.Identify the Top 5 Cities with the Highest Patents per Million Inhabitants Growth Rate 
-- Between Two Specific Years
select city, 
Round((max(patents_per_million) - min(patents_per_million)) / min(patents_per_million) * 100,2)
as patents_growth_rate
from eco_productivity
where `year` in (2019,2024)
group by city
order by patents_growth_rate desc
limit 5;

-- 3.Compare the Average Unemployment Rate Across All Cities to the Youth Unemployment Rate for Each Year

select `year`,
round(avg(unemployment_rate),2) as avg_uemployment_rate,
round(avg(youth_unemployment_rate),2) as avg_youth_unemployment_rate
from eco_productivity
group by `year`;

-- Retrieve Cities with R&D Expenditure Above a Certain Threshold in a Specific Year `eco_productivity`.``
select * from eco_productivity;
select city, rd_expenditure 
from eco_productivity
where rd_expenditure > 1.05 and year = 2023;

-- 3 List Cities Where the ICT Sector Employs More Than 10% of the Total Workforce
SELECT 
    city,
    (ict_sector_emp) / (ict_sector_emp + sme_employment + toursim_sector_emp) * 100 AS ict_sector_employment
FROM
    eco_productivity
WHERE
    (ict_sector_emp) / (ict_sector_emp + sme_employment + toursim_sector_emp) * 100 > 10;

-- 4. Calculate the Compound Annual Growth Rate (CAGR) of GDP for Each City
select city,
(pow(max(gdp_billion) / min(gdp_billion),1.0 / (max(`Year`) - min(`Year`))) -1) * 100 as cagr
from sector_income
group by city;

-- 5 Determine the Contribution of Each Sector to the Total GDP for Each City

SELECT 
    city,
    `year`,
    ROUND(SUM(agriculture) / SUM(gdp_billion) * 100,
            3) AS agriculture_percentage,
    ROUND(SUM(industry) / SUM(gdp_billion) * 100,
            3) AS industry_percentage,
    ROUND(SUM(services) / SUM(gdp_billion) * 100,
            3) AS services_percentage,
    ROUND(SUM(technology) / SUM(gdp_billion) * 100,
            3) AS technology_percentage
FROM
    sector_income
GROUP BY city , `year`
LIMIT 0 , 1000;

-- 6.Find Cities with the Largest Increase in SME Employment Between Two Specific Years
SELECT 
    city,
    ROUND(MAX(sme_employment) - MIN(sme_employment),
            2) AS sme_emp_increase
FROM
    eco_productivity
WHERE
    year IN (2021 , 2024)
GROUP BY city
ORDER BY sme_emp_increase DESC
LIMIT 5;

-- 8.Analyze the Correlation Between R&D Expenditure and GDP Growth

select a.city,a.year,a.rd_expenditure,b.gdp_billion,
(b.gdp_billion- lag(b.gdp_billion) over(partition by a.city order by a.year)) / 
lag(b.gdp_billion) over(partition by a.city order by a.year) * 100 as gdp_growth
from eco_productivity a

join sector_income b

on a.city =b.city and a.year = b.year
where rd_expenditure  is not null and b.gdp_billion is not null;

-- Identify the Top 3 Cities with the Highest Technology Sector Contribution to GDP in 2024
select city,technology / gdp_billion *100 as highest_tech_contribution
from sector_income
where year = 2024
order by highest_tech_contribution desc limit 3; 

-- 7. Calculate the Year-on-Year Growth in GDP for Each City
SELECT 
    s1.city,
    s1.year,
    s1.gdp_billion AS current_gdp,
    s2.gdp_billion AS previous_gdp,
    ((s1.gdp_billion - s2.gdp_billion) / s2.gdp_billion) * 100 AS growth_gdp_perc
FROM
    sector_income s1
        JOIN
    sector_income s2 ON s1.city = s2.city
        AND s1.year = s2.year + 1
ORDER BY s1.city , s1.year;

-- 8. Identify Cities with High R&D Expenditure and High Patent Rates
select city,year,rd_expenditure,patents_per_million
from eco_productivity
where rd_expenditure > (select avg(rd_expenditure) from eco_productivity)
and patents_per_million > (select avg(patents_per_million) from eco_productivity)	
order by  rd_expenditure desc,patents_per_million desc;

-- 3. Correlate GDP Growth with Unemployment Rates
SELECT 
    s.city,
    s.year,
    s.gdp_billion,
    e.unemployment_rate,
    e.youth_unemployment_rate,
    (e.unemployment_rate + e.youth_unemployment_rate) / 2 AS total_unemployment_rate
FROM
    sector_income s
        JOIN
    eco_productivity e ON s.city = e.city AND s.year = e.year
ORDER BY s.city , s.year;

-- 4. Rank Cities by Technology Sector Income and Employment
select s.city,s.year,s.technology,e.ict_sector_emp,
rank() over(order by s.technology desc) as rank_by_tech,
rank() over(order by e.ict_sector_emp desc) as rank_by_ict
from sector_income s
join eco_productivity e
on s.city = e.city and s.year = e.year
order by rank_by_tech,rank_by_ict;

-- 5. Analyze the Impact of SME Employment on GDP
select s.city,s.year,s.gdp_billion,e.sme_employment
from sector_income s
join eco_productivity e
on s.city = e.city and s.year = e.year
order by s.city,s.year;

-- 6. Compare the Economic Productivity of Cities in Different Years
select s.city,s.year,e.rd_expenditure,e.patents_per_million,s.gdp_billion,
(e.rd_expenditure + s.gdp_billion) / e.patents_per_million as eco_productivity
from sector_income s
join eco_productivity e
on s.city = e.city and s.year = e.year
order by s.city,s.year desc limit 10;

select * from eco_productivity;
select * from sector_income;

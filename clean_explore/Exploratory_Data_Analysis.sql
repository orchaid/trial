-- Exploratory Data Analysis

SELECT MAX(total_laid_off) AS total_laid_off, company
FROM layoffs1
where total_laid_off IS NOT NULL
GROUP BY company
ORDER BY total_laid_off DESC;     --Google has the highest number of layoffs in one go


SELECT SUM(total_laid_off) AS total_laid_off, company, SUBSTR(date,1,4) AS year
FROM
    layoffs1
WHERE total_laid_off IS NOT NULL
GROUP BY company, year
ORDER BY total_laid_off DESC;       


SELECT SUM(total_laid_off), company, SUBSTR(date,1,4) AS year,DENSE_RANK() OVER ( ORDER BY SUBSTR(date,1,4) DESC) AS rank
FROM
    layoffs1
WHERE total_laid_off IS NOT NULL
GROUP BY company, year
ORDER BY 1 DESC;            



SELECT country, SUM(total_laid_off) AS total_laid_off
FROM
    layoffs1
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC;            --United States has the highest number of layoffs out of all the countries



SELECT company, SUM(total_laid_off) AS total_laid_off
FROM
    layoffs1
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC;            --Over all Amazon has the highest number of layoffs out of all the companies


SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM
    layoffs1
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;             --Consumer has the highest number of layoffs out of all the industries    


SELECT SUBSTRING(date,1,4) AS year, SUM(total_laid_off) AS total_laid_off
FROM
    layoffs1
WHERE total_laid_off IS NOT NULL
GROUP BY year
ORDER BY 2 DESC;            --2022 has the highest number of layoffs out of all the years but 2023 is not over yet so it is not a fair comparison and looking at the data for 2023, the layoffs are increasing


SELECT  MIN(date), MAX(date)
FROM layoffs1;            --The data is from 2020 to 2023

--Top 5 companies with the highest layoffs in each year
WITH cte (total_laid,company,year )AS
( 
SELECT SUM(total_laid_off) AS total_laid_off, company, SUBSTR(date,1,4) AS year
FROM
    layoffs1
WHERE total_laid_off IS NOT NULL
GROUP BY company, year
ORDER BY total_laid_off DESC 
), cte2 AS
(
SELECT total_laid,company,year, DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid DESC) AS rank
FROM cte
)
SELECT *
FROM cte2
WHERE rank <= 5;            --Uber has the highest layoffs in 2020, Bytedance has the highest layoffs in 2021, Meta has the highest layoffs in 2022, Google has the highest layoffs in 2023.


--Rolling Total over the months
          
SELECT SUBSTRING(date,1,7) AS month, SUM(total_laid_off) AS total_off
FROM
    layoffs1
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY month
ORDER BY month;  


WITH Rolling_Total AS
(
SELECT 
    SUBSTRING(date,1,7) AS month, SUM(total_laid_off) AS total_off
FROM
    layoffs1
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY month
ORDER BY month           
)
SELECT month, total_off, SUM(total_off) OVER (ORDER BY month) AS rolling_total
FROM Rolling_Total;            --The layoffs doubled the last 6 months

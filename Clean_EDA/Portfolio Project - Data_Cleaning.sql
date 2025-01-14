SELECT *
FROM layoffs

/*
1- Remove duplicates
2- Standardise the data
3- Null values or blank values
4- remove unneccessairy column or row */



---- working in a copy of the database 

CREATE TABLE layoffs2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off DECIMAL DEFAULT NULL,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT DEFAULT NULL
  );

INSERT INTO layoffs2 (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)
SELECT 
    layoffs.company, 
    layoffs.location,
    layoffs.industry, 
    CASE 
        WHEN layoffs.total_laid_off IS NULL THEN NULL 
        ELSE CAST(layoffs.total_laid_off AS INT) 
    END,
    CASE 
        WHEN layoffs.percentage_laid_off IS NULL THEN NULL 
        ELSE CAST(layoffs.percentage_laid_off AS DECIMAL(10, 2)) 
    END,
    layoffs.date,
    layoffs.stage,
    layoffs.country,
    CASE 
        WHEN layoffs.funds_raised_millions IS NULL THEN NULL 
        ELSE CAST(layoffs.funds_raised_millions AS DECIMAL(10, 2)) 
    END
FROM layoffs;


--1- Remove duplicates

SELECT * , ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions ORDER BY company) AS row_num
FROM layoffs2
WHERE row_num > 1;



WITH cte_duplicates AS( 
    SELECT * , 
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions ORDER BY company) AS row_num
    FROM layoffs2
) 
SELECT *
FROM cte_duplicates 
WHERE row_num > 1;   


SELECT * FROM layoffs2
WHERE company = 'Casper'; -- CHECKING DUPLICATES

WITH cte_duplicates AS( 
    SELECT * , ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions ORDER BY company) AS row_num
    FROM layoffs2
) 
DELETE FROM cte_duplicates WHERE row_num > 1; -- COULD NOT DELETE FROM cte_duplicates, so I created a new table with the new column that i wanted based on.


CREATE TABLE layoffs1(
company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off DECIMAL DEFAULT NULL,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions DECIMAL DEFAULT NULL,
    row_num INT 
  );
INSERT INTO layoffs1 
SELECT *, ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)
FROM layoffs2;

DELETE  FROM layoffs1
WHERE row_num > 1; -- DELETING DUPLICATES

SELECT DISTINCT company FROM layoffs1 WHERE company = 'Casper'; -- CHECKING IF DUPLICATES ARE DELETED -- IT IS DELETED


--2- Standardise the data

SELECT company,
    TRIM(company) AS trimmed_company
FROM layoffs1
WHERE company <> TRIM(company) ; -- CHECKING FOR WHITESPACES in company

UPDATE layoffs1
SET company = TRIM(company); -- REMOVING WHITESPACES

SELECT DISTINCT industry
FROM layoffs1  -- Crypto repeated in different typos
where industry LIKE 'Crypto%'; 

UPDATE layoffs1
SET industry = 'Crypto' -- STANDARDISING THE INDUSTRY NAME
WHERE industry  LIKE 'Crypto%';

SELECT company, industry  -- looking for null values and figuring out if i can find them 
FROM layoffs1
WHERE industry IS NULL OR industry = ''; -- looking for null values and blanks and figuring out if i can find them


SELECT company, industry  -- looking for null values and figuring out if i can find them 
FROM layoffs1
where company IN ('Airbnb', 'Carvana','Juul') OR company LIKE 'Bally%';

--- two ways to fill the null values that i know their correct industry 

--the first way is by updating each missing value using case for multible values
UPDATE layoffs1
SET 
    industry = CASE 
        WHEN company = 'Airbnb' THEN 'Travel'
        WHEN company = 'Carvana' THEN 'Transportation'
        WHEN company = 'Juul' THEN 'Consumer'
        ELSE industry 
    END;

--the second way is by joining the table on itself to compare the nulls and their supposed values by filtering to nulls and then updating it 

SELECT l1.company, l1.industry,l2.company ,l2.industry
FROM layoffs1 AS l1
JOIN layoffs1 AS l2 
    ON l1.company = l2.company
WHERE l1.industry IS NULL AND l2.industry IS NOT NULL; -- checking the join

/* this is better for larger data
    UPDATE layoffs1 AS l1
    JOIN layoffs1 AS l2 
        ON l1.company = l2.company
    SET l1.industry = l2.industry
    WHERE l1.industry IS NULL 
        AND l2.industry IS NOT NULL; */    -- i used the first way to update the null values because the second one didn't work for me, it was giving me an error

SELECT 
    DISTINCT country 
FROM layoffs1 
ORDER BY 1; -- checking for countries that are repeated in different typos

SELECT
     DISTINCT country,TRIM (TRAILING '.' FROM country)  FROM  layoffs1 


UPDATE layoffs1
SET country = TRIM (TRAILING '.' FROM country); -- removing the dot from the end of the country name



-- NULL values and standerising the date column

SELECT 
    date,
    TO_DATE(date, 'MM/DD/YYYY') AS formatted_date
FROM   
    layoffs1; -- the date didn't change at first because i found a null value that was text not NULL


SELECT * 
FROM layoffs1
WHERE date LIKE '%NU%';

UPDATE layoffs1
SET date = NULL
WHERE date ='NULL';

UPDATE layoffs1 
SET
    date = TO_DATE(date, 'MM/DD/YYYY');
    

--3- Null values or blank values      I should done all at once for all the table but i forgot and did it for each column individually



--4- remove unneccessairy column or row 

SELECT * 
FROM layoffs1 
WHERE percentage_laid_off IS NULL 
    AND total_laid_off IS NULL;

-- the rows that doesn't have any value for percentage_laid_off and total_laid_off are propably not helpful in exploratory studying as it's arguably the most important, so i will delete their rows
DELETE 
FROM 
    layoffs1
WHERE percentage_laid_off IS NULL 
    AND total_laid_off IS NULL; 

ALTER TABLE layoffs1
DROP COLUMN row_num; -- removing the row_num column as it is achieved it's pupose

SELECT *
FROM layoffs1; -- checking the final table, good enough for exploratory data analysis





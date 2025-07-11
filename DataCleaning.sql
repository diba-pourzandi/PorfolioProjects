-- Data Cleaning 

-- 1. Remove Duplicates
-- 2. Standardize the Data 
-- 3. Null Values or blank values
-- 4. Remove any unnecessary columns or rows

USE world_layoffs;
SELECT *
FROM layoffs
WHERE company = 'Casper';

-- Duplication for "Version Control" 
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- 1. Remove Duplicates in layoffs_staging 

WITH duplicates_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
) AS row_num -- group/partition by (...) and order the group from 1 on
FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;

-- Create new table (with row_num) where will delete duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
) AS row_num 
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE company = 'Buy / Rakuten';

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standardizing the Data 

-- standardizing company 
-- taking off white space
UPDATE layoffs_staging2
SET company = TRIM(company);

-- standardize industry names 
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- standardize countries
-- take of trailing period 
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States' -- could also do TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- standardizing date format from text to MM-DD-YYYY date
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 


-- 3. Null Values or blank values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Change blanks to nulls
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Join two identitcal tables 
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company -- compare where tables have same company and location
    AND t1.location = t2.location
WHERE t1.industry IS NULL -- but different industry (null vs not null) 
AND (t2.industry IS NOT NULL);

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


-- 4. Remove any unnecessary columns or rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



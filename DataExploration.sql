-- Exploratory Data Analysis 

SELECT *
FROM layoffs_staging2;

-- Which companies went bankrupt ? 
SELECT *
FROM layoffs_staging2
WHERE   percentage_laid_off = 1
ORDER BY total_laid_off DESC; -- and laid off the most people 

-- Which companies for hit the hardest?
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; -- order by 2nd column (=sum)

-- Which industries got hit the hardest?
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC; -- order by 2nd column / the sum of total laid off

-- What time period was this during? 
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- answer: COVID (2020-2023)

-- Which country got hit the hardest? 
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- How many people were laid off per year? 
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- At which stage were the companies that let go the most people ? 
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- How many layoffs happened each month per year?
SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Rolling total of layoffs each month through the years 
WITH rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER (ORDER BY `MONTH`)
FROM rolling_total;

-- Which company laid off the most people at once ?
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Which companies laid off most people per year ?
WITH company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
company_ranking AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_ranking
WHERE ranking <= 5 ;

-- Which top five industries were hit per year? 
WITH industry_year (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
),
industry_ranking AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM industry_year
WHERE years IS NOT NULL
)
SELECT *
FROM industry_ranking
WHERE ranking <= 5 ;

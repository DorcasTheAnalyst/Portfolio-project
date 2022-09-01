SELECT *
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


SELECT *
FROM PORTFOLIO_PROJECT.dbo.CovidVaccinations
ORDER BY 3, 4

-- The step above is to check and know if i have the correct and needed data imported correctly

-- SELECT THE DATA WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths
ORDER BY 1,2



--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--THIS SHOWS THE POSSIBILITY OF A PERSON DYING IF HE/SHE CONTRACTS COVID 19 IN NIGERIA

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS percentage_of_death
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths 
WHERE location like '%Nigeria%'
ORDER BY 1,2


---LOOKING AT TOTAL CASES VS POPULATION
--THIS SHOWS THE PERCENTAGE OF POPULATION OF THE PEOPLE THAT HAS CONTRACTED COVID 19

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS percentage_of_population
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths 
--WHERE location like '%Nigeria%'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED WITH POPULATION

SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population)) * 100 AS percentage_of_population
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths 
--WHERE location like '%Nigeria%'
GROUP BY location, population
ORDER BY percentage_of_population DESC



--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION


SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths 
--WHERE location like '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC



--BY CONTINENT


SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths 
--WHERE location like '%Nigeria%'
WHERE continent IS  NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths 
--WHERE location like '%Nigeria%'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC


--GLOBAL NUMBERS PER DATE 


SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM (new_cases) * 100 AS Death_percentage
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths 
--WHERE location like '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--TOTAL GLOBAL NUMBER 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM (new_cases) * 100 AS Death_percentage
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths 
--WHERE location like '%Nigeria%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--PREVIEWING THE COVID VACCINATIONS TABLE

SELECT *
FROM PORTFOLIO_PROJECT.dbo.CovidVaccinations


--JOINING BOTH TABLES TOGETHER ON LOCATION AND DATE

SELECT *
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths deaths
JOIN PORTFOLIO_PROJECT.dbo.CovidVaccinations vaccinations
     ON deaths.location = vaccinations.location
	 AND deaths.date = vaccinations.date


--TOTAL POPULATION VS VACCINATIONS 


SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(BIGINT, vaccinations.new_vaccinations)) OVER ( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
--,(rolling_people_vaccinated/population) * 100
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths deaths
JOIN PORTFOLIO_PROJECT.dbo.CovidVaccinations vaccinations
     ON deaths.location = vaccinations.location
	 AND deaths.date = vaccinations.date
 WHERE deaths.continent IS NOT NULL
 ORDER BY 1,2,3


 --USE CTE


 WITH PopvsVac (continent, location, date, population,new_vaccinations, rolling_people_vaccinated)
 AS
 (
 SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(BIGINT, vaccinations.new_vaccinations)) OVER ( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
--,(rolling_people_vaccinated/population) * 100
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths deaths
JOIN PORTFOLIO_PROJECT.dbo.CovidVaccinations vaccinations
     ON deaths.location = vaccinations.location
	 AND deaths.date = vaccinations.date
 WHERE deaths.continent IS NOT NULL
 )
 SELECT *
 FROM PopvsVac 



 --GETTING THE PERCENTAGE OF ROLLING PEOPLE VACCINATED

 WITH PopvsVac (continent, location, date, population,new_vaccinations, rolling_people_vaccinated)
 AS
 (
 SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(BIGINT, vaccinations.new_vaccinations)) OVER ( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
--,(rolling_people_vaccinated/population) * 100
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths deaths
JOIN PORTFOLIO_PROJECT.dbo.CovidVaccinations vaccinations
     ON deaths.location = vaccinations.location
	 AND deaths.date = vaccinations.date
 WHERE deaths.continent IS NOT NULL
 )
 SELECT *, (rolling_people_vaccinated/population) * 1000
 FROM PopvsVac 





 ---CREATING A TEMPORARY TABLE



 DROP TABLE IF EXISTS #Percentage_of_people_vaccinated

 CREATE TABLE #Percentage_of_people_vaccinated
 (
 continent NVARCHAR(255),
 location NVARCHAR(255),
 date DATETIME,
 population NUMERIC,
 new_vaccinations NUMERIC,
 rolling_people_vaccinated NUMERIC,
 )
 INSERT INTO #Percentage_of_people_vaccinated

 SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(BIGINT, vaccinations.new_vaccinations)) OVER ( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
--,(rolling_people_vaccinated/population) * 100
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths deaths
JOIN PORTFOLIO_PROJECT.dbo.CovidVaccinations vaccinations
     ON deaths.location = vaccinations.location
	 AND deaths.date = vaccinations.date
 --WHERE deaths.continent IS NOT NULL

 SELECT *, (rolling_people_vaccinated/population) * 1000
 FROM #Percentage_of_people_vaccinated



 --CREATING VIEWS FOR VISUALIZATIONS LATER ON

 CREATE VIEW Percentage_of_people_vaccinated AS

 SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(BIGINT, vaccinations.new_vaccinations)) OVER ( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
--,(rolling_people_vaccinated/population) * 100
FROM PORTFOLIO_PROJECT.dbo.CovidDeaths deaths
JOIN PORTFOLIO_PROJECT.dbo.CovidVaccinations vaccinations
     ON deaths.location = vaccinations.location
	 AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL



SELECT*
FROM Percentage_of_people_vaccinated
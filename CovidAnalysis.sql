/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * FROM CovidVaccinations
ORDER BY 3,4

SELECT * FROM CovidVaccinations
ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths
FROM CovidDeaths
Where continent is not NULL
ORDER BY 1,2


--Total cases vs Total Deaths
--Likelyhood of dying among covid patients in India

--Convert to Float to avoid quotient rounding off to integer value 0
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float

Select location, Date, total_cases, total_deaths, 
			Total_deaths/total_cases*100 AS DeathRate
	FROM CovidDeaths
	WHERE location = 'India' AND continent IS NOT NULL
	ORDER BY 1,2

--Total cases vs Population

Select location, Date, population, total_cases, 
			Total_cases/population*100 AS Percentpopulationinfected
	FROM CovidDeaths
	WHERE location = 'India' AND continent IS NOT NULL
	ORDER BY 1,2


--Countries with highest infection rate vs population

Select TOP 10 location, Max(population) AS Population, MAX(total_cases) AS Infected,
		MAX(total_cases)/Max(Population)*100 AS Percentpopulationinfected
	FROM CovidDeaths
	Where continent is not NULL
	GROUP BY Location
	ORDER BY 4 DESC
	
--Countries with highest Death count per population

Select location, MAX(total_deaths) AS TotalDeathCount
	FROM CovidDeaths
	Where continent is not NULL
	GROUP BY Location
	ORDER BY 2 DESC


--Highest death count per continent

Select continent, MAX(total_deaths) AS TotalDeathCount
	FROM CovidDeaths
	Where continent is NOT NULL
	GROUP BY continent
	ORDER BY 2 DESC

--GLOBAL Deceased Percentage

Select SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


--Total population vs vaccination Rolling using CTE

WITH CTE_vac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated) AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM  PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
Select continent, location, date, population, new_vaccinations,RollingPeopleVaccinated/population*100 AS PercentVaccinated
FROM CTE_vac


--Total Population vaccinated by country using TEMP table

DROP TABLE IF EXISTS #CountriesPercentVaccinated
CREATE TABLE #CountriesPercentVaccinated
( locataion nvarchar(50),
population bigint,
vaccinatedpeople int)

INSERT INTO #CountriesPercentVaccinated
Select dea.location, MAX(dea.population), MAX(vac.people_fully_vaccinated)
FROM  CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
GROUP BY dea.location

Select * FROM #CountriesPercentVaccinated

Select #CountriesPercentVaccinated.locataion, population, vaccinatedpeople, 
		CAST(Vaccinatedpeople AS FLOAT)/population*100 AS Percentvaccinated
FROM #CountriesPercentVaccinated
ORDER BY 4 DESC


--Creating a View

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM  PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


Select * FROM PercentPopulationVaccinated

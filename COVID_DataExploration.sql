/*
Covid 19 Data Exploration 

Techniques applied: Joining data, Using Common Table Expressions (CTEs), Employing Temporary Tables, 
Utilizing Window Functions, Performing Aggregate Calculations, Creating Views, Converting Data Formats

*/

-- Select all data from the coviddeaths table where the continent is not null, ordered by the third and fourth columns
SELECT *
FROM luciana.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Initial selection of data with specified columns
SELECT 
    location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM luciana.coviddeaths
WHERE continent IS NOT NULL 
ORDER BY location, date;

-- Total Cases vs Total Deaths for Argentina
-- Shows the likelihood of dying if you contract COVID-19 in Argentina
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    -- Percentage of deaths among total cases
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM luciana.coviddeaths
WHERE location LIKE '%Argentina%'
AND continent IS NOT NULL 
ORDER BY location, date;

-- Total Cases vs Population for Argentina
-- Shows the percentage of the population that has been infected in Argentina
SELECT 
    location, 
    date, 
    population, 
    total_cases, 
    -- Percentage of population infected
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM luciana.coviddeaths
WHERE location LIKE '%Argentina%' 
AND continent IS NOT NULL
ORDER BY location, date;

-- Countries with the Highest Infection Rate compared to Population
-- Used for Tableau Dashboard
SELECT 
    location, 
    population, 
	-- Highest reported COVID-19 cases in any single day
	MAX(CAST(total_cases AS FLOAT)) AS HighestInfectionCount,  
    -- Percentage of population infected at peak
    (MAX(CAST(total_cases AS FLOAT)) / CAST(population AS FLOAT)) * 100 AS PercentPopulationInfected  
FROM luciana.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with the Highest Infection Rate compared to Population, by date
-- Used for Tableau Dashboard
SELECT 
    location, 
    population,
    date,
	-- Highest reported COVID-19 cases in any single day
	MAX(CAST(total_cases AS FLOAT)) AS HighestInfectionCount,  
    -- Percentage of population infected at peak
    (MAX(CAST(total_cases AS FLOAT)) / CAST(population AS FLOAT)) * 100 AS PercentPopulationInfected  
FROM luciana.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;

-- Countries with the Highest Death Count per Population
SELECT 
    location, 
    population, 
	-- Highest reported COVID-19 deaths in any single day
    MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount, 
    -- Percentage of population that has died at peak
    (MAX(CAST(total_deaths AS FLOAT)) / CAST(population AS FLOAT)) * 100 AS PercentTotalDeathCount  
FROM luciana.coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY PercentTotalDeathCount DESC;

-- Showing locations ordered by highest death count
SELECT 
    location, 
    -- Total COVID-19 deaths across all countries
    SUM(CAST(new_deaths AS FLOAT)) AS TotalDeathCount
FROM luciana.coviddeaths
WHERE continent IS NOT NULL 
AND location NOT IN ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income', 'Low income','Oceania','Europe','North America','Asia','South America')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking Down Data by Continent
-- Showing continents ordered by highest death count
-- Used for Tableau Dashboard
SELECT 
    continent, 
    -- Total COVID-19 deaths across all countries in the continent
    SUM(CAST(new_deaths AS FLOAT)) AS TotalDeathCount
FROM luciana.coviddeaths
WHERE continent IS NOT NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
-- Summarizing total cases, total deaths, and the global death percentage
-- Used for Tableau Dashboard
SELECT 
	-- Total reported COVID-19 cases worldwide
    SUM(new_cases) AS total_cases, 
    -- Total reported COVID-19 deaths worldwide
    SUM(CAST(new_deaths AS FLOAT)) AS total_deaths,
    -- Percentage of global deaths among total cases
    (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM luciana.coviddeaths
WHERE continent IS NOT NULL 
ORDER BY total_cases, total_deaths;

-- Total Population vs Vaccinations
-- Retrieve the total population and vaccinations data

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    dea.new_deaths, 
	-- Calculate cumulative deaths due to COVID-19 per location
    SUM(CAST(dea.new_deaths AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DeathsForCOVID,
    vac.new_vaccinations,
    -- Calculate cumulative vaccinations per location
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM 
    luciana.coviddeaths dea
JOIN 
    luciana.covidvaccines vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    2, 3;

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_deaths, DeathsForCOVID, new_vaccinations, PeopleVaccinated)
AS
(
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    dea.new_deaths, 
    SUM(CAST(dea.new_deaths AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DeathsForCOVID,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM 
    luciana.coviddeaths dea
JOIN 
    luciana.covidvaccines vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    2, 3
)
SELECT 
    *, 
    -- Calculate the percentage of deaths due to COVID-19 relative to the population
    (DeathsForCOVID/population)*100 AS DeathsForCOVIDPercentage, 
	-- Calculate the percentage of people vaccinated relative to the population
    (PeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM 
    PopvsVac;
    
-- Using Temp Table to perform Calculation on Partition By in previous query

-- Drop the temporary table if it exists to avoid conflicts
DROP TABLE IF EXISTS PercentPopulationVaccinated;

-- Create a temporary table to store the cumulative calculations
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population text,
new_deaths text,
DeathsForCOVID text,
new_vaccinations text,
PeopleVaccinated text
);

-- Insert data into the temporary table with cumulative calculations
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    dea.new_deaths, 
    SUM(CAST(dea.new_deaths AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DeathsForCOVID, 
    vac.new_vaccinations,
	 SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM 
    luciana.coviddeaths dea
JOIN 
    luciana.covidvaccines vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    2, 3;

-- Select all columns from the temporary table PercentPopulationVaccinated
-- Calculate the percentage of population affected by COVID-19 deaths and vaccinations
SELECT *, (DeathsForCOVID/population)*100 AS DeathsForCOVIDPercentage, (PeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM PercentPopulationVaccinated;

-- Creating a view to store aggregated COVID-19 deaths and vaccination data for later visualizations   
CREATE VIEW PercentPopulationVaccinated AS    
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    dea.new_deaths, 
    SUM(CAST(dea.new_deaths AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DeathsForCOVID, 
    vac.new_vaccinations,
	 SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM 
    luciana.coviddeaths dea
JOIN 
    luciana.covidvaccines vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL; 
    
CREATE VIEW GlobalNumbers as
SELECT 
	-- Total reported COVID-19 cases worldwide
    SUM(new_cases) AS total_cases, 
    -- Total reported COVID-19 deaths worldwide
    SUM(CAST(new_deaths AS FLOAT)) AS total_deaths,
    -- Percentage of global deaths among total cases
    (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM luciana.coviddeaths
WHERE continent IS NOT NULL 
ORDER BY total_cases, total_deaths;

CREATE VIEW PercentDeathsvsVaccination AS
SELECT *, (DeathsForCOVID/population)*100 AS DeathsForCOVIDPercentage, (PeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM PercentPopulationVaccinated;
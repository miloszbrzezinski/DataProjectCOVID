SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths / total_cases)*100 AS DeathPercentage
FROM CovidDeaths 
WHERE location like '%states%'
ORDER BY 1, 2


SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    (total_cases / population)*100 AS PercentPopulationInfected
FROM CovidDeaths 
WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at countires with highest infection rate compared to the population
SELECT 
    location, 
    population, 
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM CovidDeaths 
GROUP BY location, population
ORDER BY PercentPopulationInfected desc



-- Looking at countires with highest death count per population
SELECT 
    location, 
    population, 
    MAX(total_deaths) as TotalDeathCount,
    MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM CovidDeaths 
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- showing Countries with Highest Death Count per Population

SELECT 
    location, 
    MAX(total_deaths) AS TotalDeatCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeatCount DESC


-- Beaking things down by continents

SELECT 
    continent, 
    MAX(total_deaths) AS TotalDeatCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeatCount DESC

-- Showing continent with the highest death count per population

SELECT 
    continent, 
    MAX(total_deaths) AS TotalDeatCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeatCount DESC

-- GLOBAL NUMBERS

SELECT 
    date, 
    SUM(new_cases) AS TotalCases, 
    SUM(new_deaths) AS TotalDeaths,
    SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [date]
ORDER BY 1, 2


SELECT 
    SUM(new_cases) AS TotalCases, 
    SUM(new_deaths) AS TotalDeaths,
    SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
    death.continent,
    death.[location],
    death.[date],
    death.population,
    vaccs.new_vaccinations,
    SUM(vaccs.new_vaccinations) 
    OVER 
        (PARTITION BY 
            death.location 
        ORDER BY 
            death.location, 
            death.date)
        AS RollingPeopleVaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vaccs
    ON death.[location] = vaccs.[location]
    AND death.[date] = vaccs.[date]
WHERE death.continent IS NOT NULL
)
SELECT *, (CONVERT(float, RollingPeopleVaccinated)/population)*100 FROM POPvsVAC


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulatioVaccinated
CREATE TABLE #PercentPopulatioVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccination NUMERIC,
    rolling_people_vaccinated NUMERIC
)

INSERT INTO #PercentPopulatioVaccinated
SELECT 
    death.continent,
    death.[location],
    death.[date],
    death.population,
    vaccs.new_vaccinations,
    SUM(vaccs.new_vaccinations) 
    OVER 
        (PARTITION BY 
            death.location 
        ORDER BY 
            death.location, 
            death.date)
        AS RollingPeopleVaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vaccs
    ON death.[location] = vaccs.[location]
    AND death.[date] = vaccs.[date]
WHERE death.continent IS NOT NULL


SELECT * FROM #PercentPopulatioVaccinated


-- Creating view to store data for later visualistions

CREATE VIEW PercentPopulatioVaccinated AS
SELECT 
    death.continent,
    death.[location],
    death.[date],
    death.population,
    vaccs.new_vaccinations,
    SUM(vaccs.new_vaccinations) 
    OVER 
        (PARTITION BY 
            death.location 
        ORDER BY 
            death.location, 
            death.date)
        AS RollingPeopleVaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vaccs
    ON death.[location] = vaccs.[location]
    AND death.[date] = vaccs.[date]
WHERE death.continent IS NOT NULL
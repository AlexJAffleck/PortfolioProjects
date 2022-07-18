-- Total Cases vs total Deaths
-- shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE Location like 'United States'
ORDER BY 1,2


-- Total cases vs population
-- shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population) * 100 as InfectedPercentage
FROM CovidDeaths
WHERE Location like 'United States' 
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases)/population) * 100 as InfectedPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY population desc


-- Showing countries with highest death count per population
Select Location, population, MAX(cast(total_deaths as int)) as TotalDeaths, Max((total_deaths)/population) * 100 as DeathRate
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY TotalDeaths desc



-- Showing total deaths by continent CORRECTED
Select Location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeaths desc


-- Global Numbers
Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
-- CTE method
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_vaccination_total)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(int, cv.new_vaccinations)) OVER 
	(Partition by cd.location  Order BY cd.location, cd.date) as rolling_vaccination_total 
FROM CovidDeaths cd Join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
)
Select *, (rolling_vaccination_total/Population) * 100 as percent_vaccinated
From PopvsVac



-- Looking at Total Population vs Vaccinations
-- temp table method
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_vaccinated_total numeric
)

Insert into #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(int, cv.new_vaccinations)) OVER 
	(Partition by cd.location Order BY cd.location, cd.date) as rolling_vaccinated_total 
FROM CovidDeaths cd Join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date

SELECT *, (rolling_vaccinated_total/Population) * 100 as percent_vaccinated
FROM #PercentPopulationVaccinated
Where Continent is not null


-- Create View to store data for later
CREATE View PercentPopulationVaccinated as 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(int, cv.new_vaccinations)) OVER 
	(Partition by cd.location Order BY cd.location, cd.date) as rolling_vaccinated_total 
FROM CovidDeaths cd Join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null

Select * 
FROM PercentPopulationVaccinated


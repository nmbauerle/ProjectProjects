SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%United States%'
-- Order by 1,2

-- Look at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%United States%'
ORDER BY 1,2

-- Looking at Countries that have the Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%United States%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%United States%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%United States%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%United States%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%United States%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2

-- Looking at the Total Population vs Vaccinations -- I need to revisit this because not working

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100  USE CTE for this
FROM PortfolioProject..CovidDeaths dea
JOIN 
PortfolioProject..CovidVaccinations vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null and dea.location = 'Albania'
order by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeaths as dea
JOIN 
PortfolioProject..CovidVaccinations as vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 
order by 2,3

-- USE CTE - # of columns of CTE has to match # of columns in SELECT statement

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100  USE CTE for this
FROM PortfolioProject..CovidDeaths as dea
JOIN 
PortfolioProject..CovidVaccinations as vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 
-- order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE 
Drop Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100  USE CTE for this
FROM PortfolioProject..CovidDeaths as dea
JOIN 
PortfolioProject..CovidVaccinations as vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 
-- order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated

-- Create a View to store data for later visualizations

Create View PercentPopulationVaccinated1 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100  USE CTE for this
FROM PortfolioProject..CovidDeaths as dea
JOIN 
PortfolioProject..CovidVaccinations as vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3

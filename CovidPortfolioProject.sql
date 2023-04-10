/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


-- Select Data that we are going to be starting with
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2


-- Looking at the total deaths vs total cases. 
-- DeathPercentage shows the likelihood of death in case of infection in a spefic country.
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths / total_cases * 100,2) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Germany'
ORDER BY location, date


-- Looking at total cases vs. population
-- CasePercentage shows likelihood of infection in a specific country
SELECT location, date, total_cases, population, ROUND(total_cases / population * 100,2) as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Germany'
ORDER BY location, date



-- Looking at countries with the highest infection rate compared to the population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(ROUND(total_cases / population * 100,2)) as CasePercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY CasePercentage DESC




-- Showing Countries with the highest death rate compared to population
SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX(ROUND(total_deaths / population * 100,2)) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathPercentage DESC




-- Let's Break things down by continent

-- Showing Heighest Death Count and Death Percentage compared to the population
SELECT continent, MAX(total_deaths) as HighestDeathCount, MAX(ROUND(total_deaths / population * 100,2)) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathPercentage DESC




-- GLOBAL NUMBERS

-- NewCases and NewDeaths globally for each day
SELECT date, SUM(new_cases) as GlobalNewCases, SUM(new_deaths) as GlobalNewDeaths,  SUM(new_deaths) / SUM(new_cases) * 100 as GlobalDeathCaseRatio
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY GlobalDeathCaseRatio DESC




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
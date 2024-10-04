SELECT * 
FROM PortfolioProject..CovidDeaths
Where continent is not Null
Order By 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not Null
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' And continent is not Null
Order By 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
--Where location like '%hiop%'
Order By 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Group By Location, population
Order By InfectionPercentage desc


-- Showing Countries with Higest Death Count per Population

Select Location, population, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 as DeathPercentagePerPopulation
From PortfolioProject..CovidDeaths
Where continent is not Null
Group By Location, population
Order By TotalDeathCount desc


Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group By Location
Order By TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
-- Correct Query

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is Null
Group By location
Order By TotalDeathCount desc

--Showing the continent with the Highest death count, For project purpose

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group By continent
Order By TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' And 
where continent is not Null
Group By date
Order By 1,2

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' And 
where continent is not Null
Order By 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccintated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Group by dea.location
Order by 2, 3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccintated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Group by dea.location
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinted
CREATE TABLE #PercentPopulationVaccinted
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinted
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccintated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Group by dea.location
--Order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinted


-- creating view for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccintated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Group by dea.location
--Order by 2, 3


Select * 
From PercentPopulationVaccinated
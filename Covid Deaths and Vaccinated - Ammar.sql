SELECT * 
From PortofolioProject..CovidDeaths$
where continent is not null
order by 3,4

--SELECT * 
--From PortofolioProject..CovidVacs$
--order by 3,4

-- The data that would be used
Select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths$
where location like '%indonesia'
and continent is not null
order by 1,2

--Looking at total cases vs population
-- Shows what percentage population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
from PortofolioProject..CovidDeaths$
--where location like '%indonesia'
where continent is not null
order by 1,2

-- Looking at countries with Highest infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths$
Group by population, location
--where location like '%indonesia'
order by PercentPopulationInfected DESC

-- Showing countries with the highest death count Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortofolioProject..CovidDeaths$
where continent is not null
Group by location
--where location like '%indonesia'
order by TotalDeathsCount DESC



-- LET'S Break things down by continent

-- Showing continents with highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortofolioProject..CovidDeaths$
where continent is null
Group by location
--where location like '%indonesia'
order by TotalDeathsCount DESC

-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from PortofolioProject..CovidDeaths$
--where location like '%indonesia'
WHERE continent is not null
--GROUP BY date
order by 1,2


-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths$ dea
Join PortofolioProject..CovidVacs$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths$ dea
Join PortofolioProject..CovidVacs$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac


--- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths$ dea
Join PortofolioProject..CovidVacs$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths$ dea
Join PortofolioProject..CovidVacs$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

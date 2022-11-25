select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select
--	location,
--	date,
--	total_cases,
--	new_cases,
--	total_deaths,
--	population
--from PortfolioProject..CovidDeaths
--where continent is not null
--order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
	and location = 'Indonesia'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
	and location = 'Indonesia'
order by 1,2

-- Looking at Countries with Highest Infection Rate compare to Population

select
	location,
	population,
	max(total_cases) as HighestInfectionCount,
	max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Looking at Countries with Highest Infection Rate compared to Population
select
	location,
	population,
	max(total_cases) as HighestInfectionCount,
	max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location = 'Indonesia'
group by location, population
order by 4 desc

-- Showing Countries with Highest Death Count per Population
select
	location,
	MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location = 'Indonesia'
group by location
order by 2 desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
select
	continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- GLOBAL NUMBERS

select
	sum(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null

-- Looking at Total Population vs Vaccinations

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	--SUM(vac.new_vaccinations) over (partition by dea.location order by dea.date) as total_vaccinations
	SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select
	*,
	(RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	--SUM(vac.new_vaccinations) over (partition by dea.location order by dea.date) as total_vaccinations
	SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select
	*,
	(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to Store data for later visualizations

create view PercentPopulationVaccinated as
select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	--SUM(vac.new_vaccinations) over (partition by dea.location order by dea.date) as total_vaccinations
	SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated
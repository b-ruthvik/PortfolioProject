SELECT * FROM PortfolioProject.coviddeaths
where continent is not null
order by 3,4;

SELECT * FROM PortfolioProject.covidvaccinations
order by 3,4;

-- Select data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
order by 1,2;

-- Looking at total cases vs total deaths
-- shows the likelyhood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
where location like '%India%'
order by 1,2;

-- Looking at total cases VS population
-- shows what percentage of population got covid 
select Location, date, total_cases, population, (total_cases/population)*100 as PopInfected
FROM PortfolioProject.coviddeaths
-- where location like '%India%'
order by 1,2;


-- Looking at countries with highest infection rate compared to population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.coviddeaths
-- where location like '%India%'
Group by Location, population 
order by PercentPopulationInfected desc;



-- showing the countries with highest death count per population
select Location, MAX(cast(total_deaths as unsigned)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
where continent is not null
-- where location like '%India%'
Group by Location
order by TotalDeathCount desc;

-- showing continents with highest count per per population
select continent, MAX(cast(total_deaths as unsigned)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
where continent is not null
-- where location like '%India%'
Group by continent 
order by TotalDeathCount desc;

-- GLOBAL NUMMBERS
select SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
-- where location like '%India%'
where continent is not null
-- group by date 
order by 1,2;

select * from PortfolioProject.coviddeaths;
select * from PortfolioProject.covidvac;

-- Total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject.coviddeaths dea
join PortfolioProject.covidvac vac 
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3; 

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject.coviddeaths dea
join PortfolioProject.covidvac vac 
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3 
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac;

-- TEMP TABLE
Drop table if exists PortfolioProject.PercentPopulationVaccinated;
Create Table PortfolioProject.PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date text,
Population numeric,
new_Vaccinations text,
RollingPeopleVaccinated numeric
);


Insert into PortfolioProject.PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject.coviddeaths dea
join PortfolioProject.covidvac vac 
	on dea.location = vac.location
    and dea.date = vac.date;
-- where dea.continent is not null
-- order by 2,3 

Select *, (RollingPeopleVaccinated/population)*100
From PortfolioProject.PercentPopulationVaccinated;

-- creating view to store data for later visualization
create view PortfolioProject.PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject.coviddeaths dea
join PortfolioProject.covidvac vac 
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;
	



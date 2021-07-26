select * from [dbo].[CovidDeaths]
order by 3,4

--select * from [dbo].[CovidVaccinations]
--order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null 
order by 1,2


-- Looking at total cases vs population
-- shows what percentage of population has gotten covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From CovidPortfolioProject..CovidDeaths
--Where location like '%India%'
--and continent is not null 
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select Location, max(total_cases) as HighestCases, population, max((total_cases/population)*100) as CovidPercentage
From CovidPortfolioProject..CovidDeaths
--Where location like '%India%'
--and continent is not null 
group by location, population
order by CovidPercentage desc


-- Countries with highest death count per population

Select Location, max(total_cases) as HighestCases, max(cast(total_deaths as int)) as TotalDeaths, population, max((total_deaths/population)*100) as CovidDeaths
From CovidPortfolioProject..CovidDeaths
Where continent is not null
group by location, population
order by TotalDeaths desc


-- Let's break things by Continent
-- Continents with highest death count per population

Select continent, max(total_cases) as HighestCases, max(cast(total_deaths as int)) as TotalDeaths
From CovidPortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeaths desc


-- Global Numbers

select date, SUM([new_cases]) as NewCases, SUM(cast([new_deaths] as int)) as NewDeaths,
SUM(cast(new_deaths as int))/SUM((New_Cases))*100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent is not null 
group by date
order by date


-- Looking at total Population vs Vaccinations
use CovidPortfolioProject
go

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by dea.location, dea.date


-- Using CommonTableExpression to perform calculation

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by dea.location, dea.date
)
select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercent
from PopvsVac
order by 1,2


-- Using a Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations int,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 


Select *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedPercent
From #PercentPopulationVaccinated
order by 2,3


-- Creating a view for future visualizations

go 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
go 

select * from PercentPopulationVaccinated
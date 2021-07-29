/* Queries used for Tableau visualization */

-- 1. Check the worldwide death percentage 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- 2. Checking the total death count by Location i.e. Continent

Select location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
where continent is null 
and location not in ('World', 'European Union', 'International')
group by location
order by location 


-- 3. Checking max population infected

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases)/population*100 as PercentPopulationInfected
from CovidPortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc


-- 4. Checking max population infected by date and location

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 5. People Vaccinated by Continent, Location and Date 

Select dea.continent, dea.location, dea.date, dea.population, MAX(vac.total_vaccinations) as RollingPeopleVaccinated, 
MAX(vac.total_vaccinations)/dea.population*100 as PercentPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3
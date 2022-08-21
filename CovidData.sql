/*
CONCEPTS USED HERE
• The basics - SELECT. FROM, WHERE, ORDER BY. GROUP BY 
• CTE or Common Table Expression 
• Creating tables, Inserting into Tables, Droping Tables
• Creating Views
*/

-- Total Cases vs Total Deaths

select Location, date, convert(float, total_cases) as total_cases, convert(float, total_deaths) as total_deaths, convert(float, total_deaths)*100/nullif(convert(float, total_cases),0) as Death_Percent
from Covid_Data..CovidDeaths
--where location <> 'World' and location <> 'Upper middle income' and location <>'High income'
where location like '%india%'
order by 4 desc

--Total cases vs Population
select location, date, total_cases, Population, convert(float, total_cases)*100/nullif(convert(float, Population),0) as Percentage_of_affected
from Covid_Data..CovidDeaths
where location like '%states%'
order by 1,2

--Countires with highest Infection Rates compared to Population
select location, MAX(total_cases) as Highest_Infection_Count, Population, MAX(convert(float, total_cases)*100/nullif(convert(float, Population),0)) as Percentage_Population_infected
from Covid_Data..CovidDeaths
group by location, Population
order by 4 desc

--Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as Highest_death_Count
from Covid_Data..CovidDeaths
Where continent is not null 
group by location
order by 2 desc

--BY continent
select continent, MAX(cast(total_deaths as int)) as Highest_death_Count
from Covid_Data..CovidDeaths
--Where continent is not null 
group by continent
order by 2 desc



--looking at Total Population Vs Vaccinations

--Using CTE or common table expression
with PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid_Data..CovidDeaths dea
Join Covid_Data..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc
)
select *, RollingPeopleVaccinated/nullif(convert(bigint,population),0)*100
from PopvsVac
order by 2,3 desc

--Using TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population nvarchar(255),
new_vaccinations nvarchar(255),
rollingpeoplevaccinated nvarchar(255)
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid_Data..CovidDeaths dea
Join Covid_Data..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 desc

select *, rollingpeoplevaccinated/nullif(convert(bigint,population),0)*100
from #PercentPopulationVaccinated

--Creating a VIEW to store data for visualization

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid_Data..CovidDeaths dea
Join Covid_Data..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc

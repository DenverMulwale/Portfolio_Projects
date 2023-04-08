select * from CovidDeaths

--select * from CovidVaccinations

---Selecting Data That we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

---Total Cases Vs Death Cases, Death Percentage
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
--where location like '%Kenya%'
where continent is not null
order by 1,2

-- Total Cases Vs Population, PopulationPercentage

select location, date, Population, total_cases, (total_cases/population)*100 as Infected_Population_Percentage
from CovidDeaths
where location like '%Kenya%'
order by 1,2


--Countries with Highest Infection Rates compared to population

select location, Population, max(total_cases) HighestInfectionCount, max((total_cases/population))*100 as Infected_Population_Percentage
from CovidDeaths
--where location like '%Kenya%'
group by location,population
order by 4 desc

--Countries with Highest Death Count compared to population

	select location,  max(cast (total_deaths as int)) TotalDeathCount --cast changes/converts datatypes
	from CovidDeaths
	--where location like '%Kenya%'
	where continent is not null
	group by location
	order by 2 desc


---------Breaking Down To Continents

select location,  max(cast (total_deaths as int)) TotalDeathCount --cast changes/converts datatypes
from CovidDeaths
--where location like '%Kenya%'
where continent is null and location <> 'World'
group by location
order by 2 desc


---Global Numbers

select date, sum(new_cases) as Total_Cases, sum(convert (int,new_deaths)) as Total_Deaths, sum(convert (int,new_deaths))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths
--where location like '%Kenya%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) totalcases,sum(cast(new_deaths as int)) totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null



--Loking at Total Population Vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

order by 2,3


--USE CTE

with PopolationVsVaccinated (continent, Location, Date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from PopolationVsVaccinated


-- TEMP TABLE
drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(continent nvarchar (255),
Location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from #PercentagePopulationVaccinated

--Creating View to store data for later visualizations

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



select * from PercentagePopulationVaccinated

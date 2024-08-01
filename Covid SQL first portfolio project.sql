select *
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3, 4

select *
from [Portfolio Project]..CovidVacination
order by 3,4

--Total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'
and continent is not null
order by 1, 2


-- Total cases vs population
-- Shows what percentage of population got covid
select location, date, total_cases,  population, (total_cases/population)*100 as covidpercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'
and continent is not null
order by 1, 2


--Countries with the highest infection rate compared to population
select location,  population, max(total_cases) as maxinfectioncount, max((total_cases/population))*100 as covidpercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location, population
order by 4desc


--Countries with highest death count per population by location(country)
select location,  max(cast(total_deaths as int)) as maxdeathcount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by 2 desc


--Countries with highest death count per population by continent (wrong)
select continent,  max(cast(total_deaths as int)) as maxdeathcount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Countries with highest death count per population by continent (right)
select location,  max(cast(total_deaths as int)) as maxdeathcount
from [Portfolio Project]..CovidDeaths
where continent is null
group by location
order by 2 desc


-- death global numbers by date
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1, 2 desc


-- total death global numbers
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1, 2 desc


-- total number of vaccination in the total population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as running_total_of_newvaccinations
	  --(running_total_of_newvaccinations/dea.population)*100 as percent_totalvaccinated, use CTE instead
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacination vac
    on dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USING CTE

WITH popVSvac (continent, location, date, population, new_vaccinations, running_total_of_newvaccinations)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as running_total_of_newvaccinations
	  --(running_total_of_newvaccinations/dea.population)*100 as percent_totalvaccinated, use CTE instead
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacination vac
    on dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null)
--order by 2, 3 {can't use order by in cte}
select *, (running_total_of_newvaccinations/population)*100 as percentvaccinatedperpop
from popVSvac
order by 2, 3


--using TEMP TABLE

drop table if exists #popVSvacpercent 
create table #popVSvacpercent 
(continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric, 
new_vaccinations numeric,
running_total_of_newvaccinations numeric)

insert into #popVSvacpercent 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as running_total_of_newvaccinations
	  --(running_total_of_newvaccinations/dea.population)*100 as percent_totalvaccinated, use CTE or temptable instead
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacination vac
    on dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 can't be used in temp table 

select *, (running_total_of_newvaccinations/population)*100 as percentvaccinatedperpop
from #popVSvacpercent
order by 2, 3



--creating a view for visualization

create view popVSvacpercentage as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as running_total_of_newvaccinations
	  --(running_total_of_newvaccinations/dea.population)*100 as percent_totalvaccinated, use CTE or temptable instead
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacination vac
    on dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 can't be used in view 

select *
from popVSvacpercentage
order by 2, 3

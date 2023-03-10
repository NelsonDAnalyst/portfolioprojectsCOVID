select *
from CovidDeaths$

--select *
--from CovidVaccinations$


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

--looking at total cases vs total death
--shows the likelihood of dying if you had covid in NNigeria

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as deathPercentage
from CovidDeaths$
where location like 'Nigeria'
order by 1,2

--total cases vs the population
--shows total percentage of population has covid

select location, date, total_cases, population, (total_cases/population) * 100 AS populationInfected
from CovidDeaths$
where location like 'Nigeria'
order by 1,2

--countires with higest infection rate compared to population

select location, population, MAx(total_cases) as HighestInfectionCount, MAX (total_cases/population) * 100 as populationInfected
from CovidDeaths$
--where location like 'Nigeria'
group by location, population
order by populationInfected desc

--countries with the higest death count vs population
--percentage of  total population that died of covid

select location, population, MAX(cast(total_deaths as int)) as totalDeathCount, (MAX(cast(total_deaths as int)) /population) * 100 AS percentageDeathCount
from CovidDeaths$
--where location like 'Nigeria'
where continent is not NULL
group by location, population
order by totalDeathCount desc

-- Total deathCount by contintents
--showing continent with the highest deathCount

select continent, MAX(cast(total_deaths as int)) as totalDeathCount
from CovidDeaths$
--where location like 'Nigeria'
where continent is  not NULL
group by continent
order by totalDeathCount desc

--global numbers

select date, sum(new_cases) as total_casess, sum(cast(new_deaths as int)) as ALLDeaths,
sum(cast(new_deaths as int))/ sum(new_cases) * 100 as deathPercentage
from CovidDeaths$
--where location like 'Nigeria'
where continent is not null
group by date
order by 1,2

--total cases, total deaths across the world and trhe death percentage

select sum(new_cases) as total_casess, sum(cast(new_deaths as int)) as ALLDeaths,
sum(cast(new_deaths as int))/ sum(new_cases) * 100 as deathPercentage
from CovidDeaths$
--where location like 'Nigeria'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vacinnation

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by
dea.location, dea.date) as CumulativeCount
from CovidDeaths$ dea
join CovidVaccinations$ vac
  ON dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is  not NULL
  --and dea.location  like 'nigeria'
  order by 2,3

--using a CTE

with popvsvac (continent,location,date,population, new_vaccinations, cumulativeCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by
dea.location, dea.date) as CumulativeCount
from CovidDeaths$ dea
join CovidVaccinations$ vac
  ON dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is  not NULL
  --and dea.location  like 'nigeria'
 -- order by 2,3
  )
  select *, (cumulativeCount/population) * 100 percentage_of_populationVaccinated
  from popvsvac

  --using a TEMP TABLE
   DROP TABLE if exists #percentageVaccinated
  create table #percentageVaccinated
  (
  continent nvarchar(255),
  location nvarchar (255),
  date datetime,
  population int,
  new_vaccinations int,
  cumulativeCount int
  )
  insert into #percentageVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by
dea.location, dea.date) as CumulativeCount
from CovidDeaths$ dea
join CovidVaccinations$ vac
  ON dea.location = vac.location 
  and dea.date = vac.date
 where dea.continent is  not NULL
  --and dea.location  like 'nigeria'
 -- order by 2,3

 select *, (CumulativeCount/population)*100
 from #percentageVaccinated

 --create views for later visualization

 create view percentageVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by
dea.location, dea.date) as CumulativeCount
from CovidDeaths$ dea
join CovidVaccinations$ vac
  ON dea.location = vac.location 
  and dea.date = vac.date
 where dea.continent is  not NULL
  --and dea.location  like 'nigeria'
 -- order by 2,3

 select *
from percentageVaccinated
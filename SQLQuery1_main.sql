--SELECT * FROM [dbo].[CovidDeaths]
--ORDER BY 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
order by 1,2


--looking at total_cases vs total_deaths
--likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
from PortfolioProjects..CovidDeaths
where location like '%states'
order by 1,2


--shows what percentage of the population got covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentageDeaths
from PortfolioProjects..CovidDeaths
where location like '%states'
order by 1,2


--looking at countries highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
group by location, population
order by PercentPopulationInfected desc



--showing the countries with the Highest death count per population
select location, max(cast(total_deaths as int)) as HighestDeathCount /*max(total_deaths/population)*100 as PercentPopulationDied*/
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc



SELECT * FROM [dbo].[CovidDeaths]
where continent is not null
ORDER BY 3,4


--let's break things down by continent


select continent, max(cast(total_deaths as int)) as HighestDeathCount /*max(total_deaths/population)*100 as PercentPopulationDied*/
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc



--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from CovidDeaths
where continent is not null
--group by date
order by 1,2



--looking at total population vs vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as CumNewVacByCountry
from PortfolioProjects..CovidDeaths d
 join PortfolioProjects..CovidVaccinations v
 on d.location=v.location
 and d.date=v.date
 where d.continent is not null
 order by 2,3

 
 
 --use CTE

with CumNewVacVsPop (continent,location,date, population, new_vaccinations, CumNewVacByCountry)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as CumNewVacByCountry
--CumNewVacByCountry/population *100
from PortfolioProjects..CovidDeaths d
 join PortfolioProjects..CovidVaccinations v
 on d.location=v.location
 and d.date=v.date
 where d.continent is not null
-- order by 2,3
 )

select *, CumNewVacByCountry/population *100,
 max(CumNewVacByCountry/population *100) over (partition by location) as zzz
 from CumNewVacVsPop

 

 --Temp Table
 drop table if exists #PercentPopulationVac
 create table #PercentPopulationVac
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population int,
 new_vaccinations int,
 CumNewVacByCountry int
 )

 insert into #PercentPopulationVac

 select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as CumNewVacByCountry
--CumNewVacByCountry/population *100
from PortfolioProjects..CovidDeaths d
 join PortfolioProjects..CovidVaccinations v
 on d.location=v.location
 and d.date=v.date
 where d.continent is not null
-- order by 2,3

select *, CumNewVacByCountry/population *100,
 max(CumNewVacByCountry/population *100) over (partition by location) as zzz
 from #PercentPopulationVac



 --creating views for data visualizations 

 create view covidview1 as
 select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as CumNewVacByCountry
from PortfolioProjects..CovidDeaths d
 join PortfolioProjects..CovidVaccinations v
 on d.location=v.location
 and d.date=v.date
 where d.continent is not null
 --order by 2,3

 select * from covidview1











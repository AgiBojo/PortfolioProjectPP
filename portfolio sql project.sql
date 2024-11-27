select * from PortfolioProject..CovidDeaths order by 3,4
select * from PortfolioProject..CovidVaccinations order by 3,4
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths order by 1,2

--looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths where location like '%india%' order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location,date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths where location like '%states%' order by 1,2

--looking at countries with highest infected rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,
max((total_cases/population)*100 )as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
group by location,population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by location
order by HighestDeathCount desc

--let's breakdown things by continent
--showing continents with the highest death count per population
select continent,max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths 
where continent is not  null
group by continent
order by HighestDeathCount desc

--Global numbers
select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths ,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null

--looking at total population vs vaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over
(partition by cd.location order by cd.location,cd.date) as rollingpeoplevaccinated
from  PortfolioProject..CovidDeaths cd
join  PortfolioProject..CovidVaccinations cv 
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3

--use cte
with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over
(partition by cd.location order by cd.location,cd.date) as rollingpeoplevaccinated
from  PortfolioProject..CovidDeaths cd
join  PortfolioProject..CovidVaccinations cv 
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population) * 100 from popvsvac

--temp table
drop table if exists #percentpeoplevaccinated
create table #percentpeoplevaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #percentpeoplevaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over
(partition by cd.location order by cd.location,cd.date) as rollingpeoplevaccinated
from  PortfolioProject..CovidDeaths cd
join  PortfolioProject..CovidVaccinations cv 
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
--order by 2,3 

select *,(rollingpeoplevaccinated/population) * 100 from #percentpeoplevaccinated

--creating view to store data for later visualization

create view percentpeoplevaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over
(partition by cd.location order by cd.location,cd.date) as rollingpeoplevaccinated
from  PortfolioProject..CovidDeaths cd
join  PortfolioProject..CovidVaccinations cv 
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
--order by 2,3
select * from percentpeoplevaccinated









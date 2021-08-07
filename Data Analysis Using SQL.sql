select * from [Data Analytics using SQL]..CovidDeaths order by 3,4

select * from [Data Analytics using SQL]..CovidVaccination order by 3,4

select location,date,total_cases,new_cases,total_deaths from [Data Analytics using SQL]..CovidDeaths order by 1,2

-- Looking at the total cases Vs. Total deaths


select location,date,convert(decimal(30,3),total_cases),convert(decimal(30,3),total_deaths), convert(decimal(30,3),total_deaths)/convert(decimal(30,3),total_cases) from [Data Analytics using SQL]..CovidDeaths order by 1,2

--select isnumeric(total_cases), total_cases from [Data Analytics using SQL]..CovidDeaths
--where isnumeric(total_cases) = 0


update [Data Analytics using SQL]..CovidDeaths
set total_cases = null
where total_cases = 0

--select isnumeric(total_deaths), total_deaths from [Data Analytics using SQL]..CovidDeaths
--where isnumeric(total_deaths) = 0

update [Data Analytics using SQL]..CovidDeaths
set total_deaths = null
where total_deaths = 0


select location,date ,total_cases,total_deaths
from [Data Analytics using SQL]..CovidDeaths 
where location like '%india%' order by 1,2

 select convert(varchar,GETDATE(),23)

 select date from [Data Analytics using SQL]..CovidDeaths

 -- -- shows death percentage

select location,date ,total_cases,total_deaths ,convert(float,total_deaths)/total_cases *100 as DeathPercentage
from [Data Analytics using SQL]..CovidDeaths 
where location like '%india%' 

 -- shows the percentage of population got covid

select location,date ,total_cases,population ,(total_cases/convert(float,population))*100 as DeathPercentage
from [Data Analytics using SQL]..CovidDeaths 
where location like '%india%' 

 -- Looking at the countries with the highest infection rate 

 select location,population,MAX(total_cases) as Highestinfectioncount
 from [Data Analytics using SQL]..CovidDeaths
 group by location,population
 order by 2

 --Countries with highest deathcounts
 select location,MAX(cast(total_deaths as int)) as Deathcount
 from [Data Analytics using SQL]..CovidDeaths
 where continent is not null
 group by location
 order by Deathcount desc

 --Breaking things by continents

 select continent,MAX(cast(total_deaths as int)) as Totaldeathcount
 from [Data Analytics using SQL]..CovidDeaths
 where continent is not null
 group by continent
 order by Totaldeathcount desc

 select date,sum(cast(new_cases as int)) as new_cases,sum(cast(new_deaths as int)) as new_deaths
 from [Data Analytics using SQL]..CovidDeaths
 where continent is not null
 group by date
 order by 1,2

 -- Looking at total population Vs. Vaccination
-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From [Data Analytics using SQL]..CovidDeaths death
Join [Data Analytics using SQL]..CovidVaccination vaccine
On death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Analytics using SQL]..CovidDeaths dea
Join [Data Analytics using SQL]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

GO
Create View Percentvaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Data Analytics using SQL]..CovidDeaths dea
Join [Data Analytics using SQL]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


 

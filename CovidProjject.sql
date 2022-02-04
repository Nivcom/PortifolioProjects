select * from CovidProject..covidDeaths$ where continent is not null
order by 3,4;

--select * from CovidProject..covidVaccination$
--order by 3,4

--Selecting data that we are going to be using.

Select location, date, total_cases, new_cases, total_deaths, population from CovidProject..covidDeaths$ 
where continent is not null
order by 1,2

--************************** Looking at total cases vs Total deaths.**********************************
--Shows the likelihood of dying fromm covid if you contract it in the uk
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..covidDeaths$ where location like '%kingdom%' and continent is not null order by 1,2 ;

--*********************** Total cases vs population***************************************
Select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
from CovidProject..covidDeaths$ where location like '%uganda%' and continent is not null order by 1,2 ;

---**************************Countries with highest infection rate compared to population**************************
Select location, population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
as PercentagePopulationInfected from CovidProject..covidDeaths$ where continent is not null group by location, population 
order by PercentagePopulationInfected desc;

--*************************Countries with highest death count per population.****************************
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount from CovidProject..covidDeaths$ where continent is not null
group by location,population order by TotalDeathCount desc;

-- ****************************Continent break down**********************************************
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount from CovidProject..covidDeaths$ where continent is not  null
group by continent order by TotalDeathCount desc;

--******************************Global deaths***********************************************
Select SUM(new_cases) as Total_cases, SUM(Cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage from CovidProject..covidDeaths$
where continent is not null
--group by date 
order by 1,2

--*******************************Global deaths 2***************************************
Select date, SUM(new_cases) as Total_cases, SUM(Cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage from CovidProject..covidDeaths$
where continent is not null
group by date 
order by 1,2

Select * from CovidProject..covidVaccination$;

--***************************** Looking at total population vs vaccination************************************
SET ANSI_WARNINGS OFF
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated,
from CovidProject..covidDeaths$ dea
join CovidProject..covidVaccination$ vac
on dea.location =vac.location and dea.date = vac.date where dea.continent is not null order by 2,3


--******************************** Population Vaccinated************************************************
with PopvsVax (continent, location,Date,population, New_vaccinations,RollingPeopleVaccinated )
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidProject..covidDeaths$ dea
join CovidProject..covidVaccination$ vac
on dea.location =vac.location and dea.date = vac.date where dea.continent is not null --order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVax

--******************** Temp Table************************************************
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidProject..covidDeaths$ dea
join CovidProject..covidVaccination$ vac
on dea.location =vac.location and dea.date = vac.date --where dea.continent is not null --order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated

--***********************************Creating views For visualisation***********************************************

--********************Percentage Population Vaccinated View*********************************************************
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidProject..covidDeaths$ dea
join CovidProject..covidVaccination$ vac
on dea.location =vac.location and dea.date = vac.date where dea.continent is not null --order by 2,3

--****************************Countries with highest death rate view*********************************
Create View DeathRate as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount from CovidProject..covidDeaths$ where continent is not null
group by location,population --order by TotalDeathCount desc;

--****************************Infection Rate vs population********************************************
Create View InfectionRate as
Select location, population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
as PercentagePopulationInfected from CovidProject..covidDeaths$ where continent is not null group by location, population 
--order by PercentagePopulationInfected desc;
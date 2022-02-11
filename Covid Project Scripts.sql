
Select *
From PortfolioProject..[Covid Deaths]
Order by 3,4


--Select *
--From PortfolioProject..[Covid Vaccinations]
--Order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[Covid Deaths]
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[Covid Deaths]
where location like '%states%'
order by 1,2

--Total Cases vs Population
--Shows what percentage of population contracted covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..[Covid Deaths]
where location like '%states%'
order by 1,2

--Countries with Highest Infection Rated Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
PercentPopulationInfected
From PortfolioProject..[Covid Deaths]
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Countries with the Highest Death Count per Population

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid Deaths]
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--Breaking Down By Continent

--Continent by Highest Death Count per Population

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid Deaths]
--where location like '%states%'
where continent is null
Group by Location
order by TotalDeathCount desc

--Global Numbers 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM
(New_Cases)*100 as DeathPercentage 
From PortfolioProject..[Covid Deaths]
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location,dea.
Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject.. [Covid Deaths] dea
join PortfolioProject..[Covid Vaccinations] vac
    On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

with PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location,dea.
Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject.. [Covid Deaths] dea
join PortfolioProject..[Covid Vaccinations] vac
    On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac

--Temp Table

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location,dea.
Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject.. [Covid Deaths] dea
join PortfolioProject..[Covid Vaccinations] vac
    On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




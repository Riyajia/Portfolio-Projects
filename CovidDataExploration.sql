--Covid Death Dataset
Select *
From [PortfolioProject]..['coviddeaths']
Where continent is not null 
order by 3,4

Select location, date, total_cases, new_cases,total_deaths,population
From [PortfolioProject]..['coviddeaths']
Where continent is not null 
Order by 1,2

--Total Cases Vs. Total Death (Death %)
Select location, date,population, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From [PortfolioProject]..['coviddeaths']
Where location like 'Canada'
Order by 1,2

--Total cases vs Population (% infected)
Select location, date, population,  total_cases, (total_cases/population)*100 as population_infected
From [PortfolioProject]..['coviddeaths']
Where location like 'Canada' 
AND continent is not null 
Order by 1,2

--Coutries with highest infection
Select location, population, max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as max_infected_population
From [PortfolioProject]..['coviddeaths']
Where continent is not null 
Group by location, population
Order by max_infected_population desc

--Countries with highest Deaths
Select location, Max(cast(total_deaths as int)) as highest_infection_count
From [PortfolioProject]..['coviddeaths']
Where continent is not null 
Group by location, population
Order by highest_infection_count desc

--Cases grouped by Continents
Select location, Max(cast(total_deaths as int)) as highest_infection_count
From [PortfolioProject]..['coviddeaths']
Where continent is  null 
	and location like 'Asia' 
	or location like 'Africa'
	or location like 'North America' 
	or location like 'South America' 
	or location like 'Europe'
	or location like 'Oceania'
Group by location
Order by highest_infection_count desc

-- Global numbers 

--grouped by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [PortfolioProject]..['coviddeaths']
where continent is not null 
Group by date
order by 1,2

--Death Percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [PortfolioProject]..['coviddeaths']
where continent is not null 
order by 1,2

--total cases worldwide
Select location, sum(total_cases) as total_cases, sum(convert(bigint, total_deaths)) as total_deaths
From [PortfolioProject]..['coviddeaths']
where total_cases is not null OR total_deaths is not null and continent is not null
group by location 
order by 1


--Covid Vaccination Dataset
Select *
From [PortfolioProject]..['covidvaccinations']
Where continent is not null 
Order by 3,4

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location 
													Order by d.location, d.Date) as RollingPeopleVaccinated
From [PortfolioProject]..['coviddeaths'] d
Join [PortfolioProject]..['covidvaccinations'] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3

--CTE for population vs vaccinations done

With Pop_Vac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location 
													Order by d.location, d.Date) as RollingPeopleVaccinated
From [PortfolioProject]..['coviddeaths'] d
Join [PortfolioProject]..['covidvaccinations'] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
)
Select *, (RollingPeopleVaccinated/population) *100 as percentageVaccinatedRolling
From Pop_Vac
order by 2,3

--Temp Table for population vs vaccination done

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location 
													Order by d.location, d.Date) as RollingPeopleVaccinated
From [PortfolioProject]..['coviddeaths'] d
Join [PortfolioProject]..['covidvaccinations'] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location 
													Order by d.location, d.Date) as RollingPeopleVaccinated
From [PortfolioProject]..['coviddeaths'] d
Join [PortfolioProject]..['covidvaccinations'] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null

Create View dbo.totalCasesWorldwide as
Select location, sum(total_cases) as total_cases, sum(convert(bigint, total_deaths)) as total_deaths
From [PortfolioProject]..['coviddeaths']
where total_cases is not null OR total_deaths is not null and continent is not null
group by location 

select * from
PortifolioProject..CovidDeaths
order by 3,4

select * from
PortifolioProject..CovidVaccinations
order by 3,4


-- Total Cases x Total Deaths:
	-- Likelihood of dying in Brazil:
		select 
			location,
			date,
			total_cases,
			total_deaths,
			(total_deaths / total_cases) * 100 "Deaths Percentage"
		from PortifolioProject..CovidDeaths
		where location = 'Brazil'
		order by 1, 2 

-- Total Cases x Population:
	-- Percentage of population that got Covid in Brazil:
		select 
			location,
			date,
			population,
			total_cases,			
			(total_cases / population) * 100 "Got Covid Percentage"
		from PortifolioProject..CovidDeaths
		where location = 'Brazil'
		order by 1, 2 

	--Countries with highest infection rate compared to population:
		select 
			location,
			population,
			max(total_cases) "HighestInfectionCount",			
			max((total_cases / population) * 100) "Got Covid Percentage"
		from PortifolioProject..CovidDeaths
		where continent is not null
		group by 
			location,
			population
		order by 4 desc

--Total Deaths:
	--Countries with highest death count
		select 
			location,			
			max(total_deaths) "HighestDeathCount"
		from PortifolioProject..CovidDeaths
		where continent is not null
		group by 
			location
		order by 2 desc

	--Continents with highest:
		select 
			location,			
			max(total_deaths) "HighestDeathCount"
		from PortifolioProject..CovidDeaths
		where continent is null
		group by 
			location
		order by 2 desc

-- GLOBAL NUMBERS
		select
		--	date,
			sum(new_cases) "total_cases",
			sum(new_deaths) "total_deaths",
			sum(new_deaths)/sum(new_cases) * 100 "Death Percentage"

		from PortifolioProject..CovidDeaths
		where continent is not null
		
	--	group by date
	--	having sum(new_cases) > 0
		order by 1


-- Total Population x Vaccinations

	select 
		cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) "Rollng People Vaccinated"

	from PortifolioProject..CovidDeaths cd
	join PortifolioProject..CovidVaccinations cv
		on cd.location = cv.location
		and cd.date = cv.date
	where cd.continent is not null
	order by 2, 3


	--CTE
		with PopxVac (Continent, location, Date, Population, new_vaccinations, RollngPeopleVaccinated) 
		as(
			select 
				cd.continent,
				cd.location,
				cd.date,
				cd.population,
				cv.new_vaccinations,
				sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) "RollngPeopleVaccinated"

			from PortifolioProject..CovidDeaths cd
			join PortifolioProject..CovidVaccinations cv
				on cd.location = cv.location
				and cd.date = cv.date
			where cd.continent is not null

			)

			select 
				*,
				(RollngPeopleVaccinated/Population) * 100
			from PopxVac


-- TEMP TABLE

drop table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
	Continent nvarchar(255), 
	location nvarchar(255), 
	Date datetime, 
	Population numeric, 
	new_vaccinations numeric, 
	RollngPeopleVaccinated numeric
)
insert into #PercentPopVaccinated
select 
				cd.continent,
				cd.location,
				cd.date,
				cd.population,
				cv.new_vaccinations,
				sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) "RollngPeopleVaccinated"

			from PortifolioProject..CovidDeaths cd
			join PortifolioProject..CovidVaccinations cv
				on cd.location = cv.location
				and cd.date = cv.date
			where cd.continent is not null

			select 
				*,
				(RollngPeopleVaccinated/Population) * 100
			from #PercentPopVaccinated


--Creating View for later visualization
	create View PercentPopVaccinatedView as
	select 
				cd.continent,
				cd.location,
				cd.date,
				cd.population,
				cv.new_vaccinations,
				sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) "RollngPeopleVaccinated"

			from PortifolioProject..CovidDeaths cd
			join PortifolioProject..CovidVaccinations cv
				on cd.location = cv.location
				and cd.date = cv.date
			where cd.continent is not null


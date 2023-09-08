select * 
from Portfolio.dbo.covidDeaths
order by 3, 4

--select * 
--from Portfolio.dbo.covidVaccinations
--order by 3, 4

-- percentage of total cases based on the population
select location, date, population, total_cases, total_deaths, ROUND((total_cases/population)*100, 5) as CasePercentage
from Portfolio.dbo.covidDeaths
where continent is not null
order by 1, 2

-- percentage of total death based on the total cases
select location, date, population, total_cases, total_deaths, (cast(total_deaths as int)/ cast(total_cases as int))*100 as DeathPercentage
from Portfolio.dbo.covidDeaths
--where [total_cases] is not null
order by 1, 2


-- checking the highest infection rate based on population in different countries
SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/ population))*100 as 
InfectionPercentage
FROM Portfolio.dbo.covidDeaths
where continent is not null
GROUP BY location, population
order by InfectionPercentage desc


-- checking the highest death rate based on population in different countries
SELECT location, MAX(total_deaths) as TotalDeaths
FROM Portfolio.dbo.covidDeaths
where continent is not null
GROUP BY location
order by TotalDeaths desc


-- results by continent 

-- Infection rate for each continent
SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/ population))*100 as 
InfectionPercentage
FROM Portfolio.dbo.covidDeaths
where continent is null
GROUP BY location, population
order by InfectionPercentage desc


--SELECT location, MAX(total_deaths) as TotalDeaths
--FROM Portfolio.dbo.covidDeaths
--where continent is null
--GROUP BY location
--order by TotalDeaths desc


-- death rate for each continet
SELECT continent, MAX(total_deaths) as TotalDeaths
FROM Portfolio.dbo.covidDeaths
where continent is not null
GROUP BY continent
order by TotalDeaths desc


-- Global Numbers

-- cases per day
SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as deathPercentage
FROM Portfolio.dbo.covidDeaths
WHERE new_cases!= 0 and continent is not null
GROUP BY date
ORDER BY 1, 2

-- cases in total
SELECT SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as deathPercentage
FROM Portfolio.dbo.covidDeaths
WHERE new_cases!= 0 and continent is not null
GROUP BY date
ORDER BY 1, 2


-- Total population vs vaccionation
SELECT death.continent, death.location, death.date, death.population, vaccine.total_vaccinations
, SUM(CONVERt(int,vaccine.new_vaccinations)) OVER (Partition by death.location order by death.location, 
death.date) as CumVaccin
FROM Portfolio..covidDeaths death
JOIN Portfolio..covidVaccinations vaccine
     on death.date = vaccine.date
     and death.location = vaccine.location
WHERE death.continent is not null
ORDER BY 2, 3



-- applying CTE

WITH VaccPopulation (continent, location, date, population, total_vaccinations, cumVaccionation)
as
(SELECT death.continent, death.location, death.date, death.population, vaccine.total_vaccinations
, SUM(CONVERt(int,vaccine.new_vaccinations)) OVER (Partition by death.location order by death.location, 
death.date) as CumVaccin
FROM Portfolio..covidDeaths death
JOIN Portfolio..covidVaccinations vaccine
     on death.date = vaccine.date
     and death.location = vaccine.location
WHERE death.continent is not null
--ORDER BY 2, 1
)
SELECT * 
FROM VaccPopulation


-- creating temporary table
DROP TABLE if exists #PercentPopVaccin
Create table #PercentPopVaccin
(
Continet nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
NewVaccination numeric,
CumVaccinztion numeric
)
INSERT INTO #PercentPopVaccin
SELECT death.continent, death.location, death.date, death.population, vaccine.total_vaccinations
, SUM(CONVERt(int,vaccine.new_vaccinations)) OVER (Partition by death.location order by death.location, 
death.date) as CumVaccin
FROM Portfolio..covidDeaths death
JOIN Portfolio..covidVaccinations vaccine
     on death.date = vaccine.date
     and death.location = vaccine.location
--WHERE death.continent is not null


-- Store the data for visualization
Create view PercentPopVaccin as
SELECT death.continent, death.location, death.date, death.population, vaccine.total_vaccinations
, SUM(CONVERt(int,vaccine.new_vaccinations)) OVER (Partition by death.location order by death.location, 
death.date) as CumVaccin
FROM Portfolio..covidDeaths death
JOIN Portfolio..covidVaccinations vaccine
     on death.date = vaccine.date
     and death.location = vaccine.location
WHERE death.continent is not null



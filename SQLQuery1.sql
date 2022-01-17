SELECT * FROM PortfolioProject..['covid deaths']
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population FROM PortfolioProject..['covid deaths']
ORDER BY 1,2

--total cases vs total deaths
--probability of dying if you contactbthe virus in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage FROM PortfolioProject..['covid deaths']
WHERE location='India'
ORDER BY 1,2


--total cases vs population
-- percentage of population infected in a country

SELECT location,date,total_cases,population,(total_cases/population)*100 as infection_percentage FROM PortfolioProject..['covid deaths']
WHERE location='India'
ORDER BY 1,2
 

--locations with highest infection rate compared to population

SELECT location,population,MAX(total_cases) as highestinfectioncount,MAX(total_cases/population)*100 as highestpercentinfection FROM PortfolioProject..['covid deaths']
GROUP BY location,population ORDER BY 4 desc


--countries with highest death count


SELECT location,MAX(cast(total_deaths as int)) as highestdeathcount FROM PortfolioProject..['covid deaths']  WHERE continent is not null
GROUP BY location ORDER BY 2 DESC


--looking by continents 
--conitnents by highest death count


SELECT continent,MAX(cast(total_deaths as int)) as highestdeathcount FROM PortfolioProject..['covid deaths']  WHERE continent is not  null
GROUP BY continent ORDER BY 2 DESC
 

 --global numbers

 SELECT date,SUM(new_cases),SUM(cast(new_deaths as int)) as total deaths--(total_cases/population)*100 as infection_percentage
 FROM PortfolioProject..['covid deaths']
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--total population vs vaccination


SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
FROM PortfolioProject..['covid deaths'] dea JOIN PortfolioProject..['covid vaccinations'] vac
ON dea.location=vac.location and dea.date=vac.date WHERE dea.continent is not null
ORDER BY 2,3 



-- CTE


WITH Popvsvac (continent,location,date,population,new_vaccinations, Rollingpeoplevaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..['covid deaths'] dea  
JOIN PortfolioProject..['covid vaccinations'] vac
ON dea.location=vac.location and dea.date=vac.date WHERE dea.continent is not null
--ORDER BY 2,3) 
)
SELECT *, (Rollingpeoplevaccinated/population)*100 FROM Popvsvac



--same with temp table


DROP Table if exists #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
( continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric,
)
INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..['covid deaths'] dea  
JOIN PortfolioProject..['covid vaccinations'] vac
ON dea.location=vac.location and dea.date=vac.date WHERE dea.continent is not null
--ORDER BY 2,3) 
SELECT *,(Rollingpeoplevaccinated/population)*100 FROM #PERCENTPOPULATIONVACCINATED




CREATE VIEW PERCENTPOPULATIONVACCINATED AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..['covid deaths'] dea  
JOIN PortfolioProject..['covid vaccinations'] vac
ON dea.location=vac.location and dea.date=vac.date WHERE dea.continent is not null
--ORDER BY 2,3) 

SELECT * FROM PERCENTPOPULATIONVACCINATED
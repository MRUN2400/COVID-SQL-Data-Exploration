use protfolioproject;
select * from protfolioproject.covidvaccinations1;
select * from protfolioproject.covid_deaths1;
-- Death_percentage 
select iso_code, location ,  `date` , total_deaths , round((total_deaths/total_cases)*100,3) as Death_percentage 
 from protfolioproject.covid_deaths1
where location like 'india%' 
order by round((total_deaths/total_cases)*100,3) desc;
-- total death & total Death_percentage 
select sum(total_cases) as Total_Cases , sum(total_deaths) as Total_Deaths, (sum(total_deaths)/sum(total_cases))*100 as Total_Death_percentage 
from protfolioproject.covid_deaths1;
-- Highest infection rate
select iso_code, `date`, location , population, max(total_cases) as Highest_infection,   round((max(total_cases)/population)*100,2) as Infection_rate_per_population
from protfolioproject.covid_deaths1
group by iso_code, location, population , `date`
order by round((max(total_cases)/population)*100,2) desc ;

-- Highest death count
select  location , max(cast(total_deaths as signed)) as Highest_death_count 
from protfolioproject.covid_deaths1
where continent is not null
group by location 
order by Highest_death_count desc;

-- By continents 
select  continent, max(cast(total_deaths as signed)) as Highest_death_count 
from protfolioproject.covid_deaths1
where continent is not null 
 AND continent <>''
group by  continent
order by Highest_death_count desc;

-- By continents / counties 
select  continent, location , max(cast(total_deaths as signed)) as Highest_death_count 
from protfolioproject.covid_deaths1
where continent is not null 
 AND continent <>''
group by continent, location 
order by Highest_death_count desc;

-- Daily global death presentage 
select  location, `date` , sum(new_cases) as new_cases , sum(cast(new_deaths as signed)) as new_deaths,
round(sum(cast(new_deaths as signed))/sum(new_cases)*100,3) as Daily_Death_percentage 
from protfolioproject.covid_deaths1
where continent is not null 
 AND continent <>''
group by location, `date`
order by round(sum(cast(new_deaths as signed))/sum(new_cases)*100,3) desc;

-- vacination vs population
select d.location , d.date , d.population , v.total_vaccinations
from covid_deaths1 as d
join covidvaccinations1 as v
on d.location = v.location
order by 1,2,4 desc;

select d.continent,d.location , d.date , d.population , v.total_vaccinations, v.new_vaccinations,
sum(cast(v.new_vaccinations as signed)) over (partition by d.location order by d.location, d.date ) as rolling_total,
ROUND(
        (
            SUM(CAST(v.new_vaccinations AS SIGNED))
            OVER (
                PARTITION BY d.location
                ORDER BY d.date
            )
            /
            NULLIF(CAST(d.population AS SIGNED),0)
        ) * 100,
        2
    ) AS percentage_vaccinated
from covid_deaths1 as d
join covidvaccinations1 as v
on d.location = v.location
and d.date=v.date
where d.continent is not null 
 AND d.continent <>''
 order by d.population ,v.new_vaccinations, v.total_vaccinations desc;
 
create view precentagepopulation_vaccinated as 
select d.continent,d.location , d.date , d.population , v.total_vaccinations, v.new_vaccinations,
sum(cast(v.new_vaccinations as signed)) over (partition by d.location order by d.location, d.date ) as rolling_total,
ROUND(
        (
            SUM(CAST(v.new_vaccinations AS SIGNED))
            OVER (
                PARTITION BY d.location
                ORDER BY d.date
            )
            /
            NULLIF(CAST(d.population AS SIGNED),0)
        ) * 100,
        2
    ) AS percentage_vaccinated
from covid_deaths1 as d
join covidvaccinations1 as v
on d.location = v.location
and d.date=v.date
where d.continent is not null 
 AND d.continent <>'';
 -- order by d.population ,v.new_vaccinations, v.total_vaccinations desc;
 
with popvac 
as 
(select d.continent,d.location , d.date , d.population , v.total_vaccinations, v.new_vaccinations,
sum(cast(v.new_vaccinations as signed)) over (partition by d.location order by d.location, d.date ) as rolling_total,
ROUND(
        (
            SUM(CAST(v.new_vaccinations AS SIGNED))
            OVER (
                PARTITION BY d.location
                ORDER BY d.date
            )
            /
            NULLIF(CAST(d.population AS SIGNED),0)
        ) * 100,
        2
    ) AS percentage_vaccinated
from covid_deaths1 as d
join covidvaccinations1 as v
on d.location = v.location
and d.date=v.date
where d.continent is not null 
 AND d.continent <>''
 order by d.population ,v.new_vaccinations, v.total_vaccinations desc)

select * from popvac;

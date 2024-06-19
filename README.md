# COVID-19 Data Analysis Project

This repository contains the analysis and visualization of COVID-19 data. The original data file was downloaded from [Our World in Data](https://ourworldindata.org/covid-deaths).

1. [Repository Structure](#repository-structure)
2. [Data Preparation](#data-preparation)
3. [Data Exploration and Analysis](#data-exploration-and-analysis)
   - [Techniques Applied](#techniques-applied)
   - [Key SQL Queries](#key-sql-queries)
4. [Data Visualization](#data-visualization)
5. [Tableau Dashboard](#tableau-dashboard)

## Repository Structure

- **owid-covid-data-original.rar**: The original data file downloaded from Our World in Data.
- **covid-deaths.rar**: Contains the data on the number of infected people, population, daily and cumulative deaths, and other related metrics.
- **covid-vaccines.rar**: Contains the data on the number of vaccinated people per day, cumulative vaccinations, and other related metrics.
- **COVID_DataExploration.sql**: The SQL script used for data exploration and analysis.
- **COVID-19 Tableau Data.rar**: Contains the CSV files generated from selected SQL queries and the Tableau workbook.
- **COVID-19_2020-2024.twb**: The Tableau workbook file containing the visualizations and dashboard.

## Data Preparation

The original data was divided into two CSV files:
1. `covid-deaths.rar`: Includes columns such as date, continent, country, number of cases, number of deaths, population, etc.
2. `covid-vaccines.rar`: Includes columns such as date, continent, country, number of vaccinations per day, cumulative vaccinations, etc.

Both CSV files share common columns like date, continent, and country.

## Data Exploration and Analysis

### Techniques Applied

The data exploration and analysis were performed using MySQL Server. The following techniques were applied:

- **Joining Data**: Combining data from different tables.
- **Using Common Table Expressions (CTEs)**: Simplifying complex queries.
- **Employing Temporary Tables**: Storing intermediate results.
- **Utilizing Window Functions**: Performing calculations across a set of table rows related to the current row.
- **Performing Aggregate Calculations**: Summarizing data.
- **Creating Views**: Storing query results as virtual tables.
- **Converting Data Formats**: Changing data types as needed for analysis.

### Key SQL Queries

- Selecting all data where the continent is not null, ordered by specific columns.
- Analyzing total cases vs. total deaths for Argentina to show the likelihood of dying if infected with COVID-19.
- Calculating the percentage of the population infected in Argentina.
- Identifying countries with the highest infection rates compared to their population.
- Determining countries with the highest death counts per population.
- Breaking down data by continent and summarizing global numbers.
- Comparing total population vs. vaccinations.

### Data Visualization

Some of the SQL query results were exported as CSV files and used to create a dashboard in Tableau. The dashboard includes:

- A table showing total cases, total deaths, and mortality percentage.
- A histogram of deaths by continent.
- A map displaying total deaths by country.
- A time series of the average percentage of the population infected over time for selected countries.

### Tableau Dashboard

You can view the interactive Tableau dashboard [here](https://public.tableau.com/app/profile/luciana.valiente/viz/COVID-19_2020-2024/Dashboard1). Below is a snapshot of the dashboard:

![Tableau Dashboard](https://github.com/lucianagabrielavaliente/COVID-2019-Data-Exploration-And-Visualization/assets/54379062/4d4b5ab0-afd0-4da7-85b2-17cc12a085e0)

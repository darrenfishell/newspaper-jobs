# Statewide job trends from QCEW

This repository includes a `dlt` pipeline to process and ingest data from the [U.S. Bureau of Labor Statistic's Quarterly Census of Employment and Wages](https://www.bls.gov/cew/overview.htm).

The specific output of this project is a Tableau Public workbook that summarizes trends specifically about newpaper publishing jobs from 1990 through the latest available year, a subject I've reported on before, with an eye toward Maine. 

This pipeline demonstrates a useful stack for Tableau Public projects that follows data engineering and transformation best practices, using `dlt`, `dbt` and `duckdb` to prepare and document data for consumption locally in Tableau Public. This structure could easily co-exist with other analysis or workflows, given the ease in `dlt` of running pipelines to other database targets.

This project also includes the full statewide database of QCEW data which can be explored directly in read-only mode using [DuckDB over HTTPS](https://duckdb.org/docs/stable/guides/network_cloud_storage/duckdb_over_https_or_s3.html).

## Visualizations
Analyzing newspaper jobs is one narrow application of QCEW data, but demonstrates some restrictions and considerations specific to the QCEW data by industry. For one, NAICS codes evolve over time and newspaper publishing specifically moved in the 2021 NAICS categories, which is reflected in the associated dbt model.

### State trends
The visualization below shows the change in payroll newspaper publishing jobs from 1990 through 2024. Certainly, this captures more than just newsroom jobs, but it reflects a serious decline, especially as the data includes online-only publications as well.

The visualizations below allow exploration by state to see how newspaper publishing job trends compare with that of all jobs during the period, in raw job counts and in percent change over time.



### Pay trends
Generally, pay has not kept with all jobs, but there are a few outlier markets that we might be able to guess where newspaper publishing pay is higher than the average job. Those include: New York, New Jersey, and Virginia. For 2014, Georgia leads the pack, which I suspect is the result of a consolidation of news executives.

The trends highlight some of the trouble with the discourse about "media elites." One can see quite clearly that this inversion of pay relative to all jobs for newspaper publishing does not reflect that narrative in most areas of the country.


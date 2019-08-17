# dbt-codegen-sqlserver

A sqlserver-version of [dbt-codegen](https://github.com/fishtown-analytics/dbt-codegen)

Macros that generate dbt code, and log it to the command line.

# Macros
## generate_source ([source](macros/generate_source.sql))
This macro generates lightweight YAML for a [Source](https://docs.getdbt.com/docs/using-sources),
which you can then paste into a schema file.

### Arguments
* `schema_name` (required): The schema name that contains your source data
* `database_name` (optional, default=target.database): The database that your
source data is in.
* `generate_columns` (optional, default=False): Whether you want to add the
column names to your source definition.

### Usage:
1. Use the macro (in dbt Develop, in a scratch file, or in a run operation) like
  so:
```
{{ codegen.generate_source('SalesLT') }}
```
Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```
$ dbt run-operation generate_source --args 'schema_name: SalesLT'
```
or
```
# for multiple arguments, use the dict syntax
$ dbt run-operation generate_source_sqlserver --args "{schema_name: SalesLT, database_name: AdventureWorks, generate_columns: TRUE}"
```
2. The YAML for the source will be logged to the command line
```txt
version: 2

sources:
  - name: saleslt
    tables:
      - name: address
        columns:
          - name: addressid
          - name: addressline1
          - name: addressline2
          - name: city
          - name: stateprovince
          - name: countryregion
          - name: postalcode
          - name: rowguid
          - name: modifieddate

      - name: customer
        columns:
```
3. Paste the output in to a schema `.yml` file, and refactor as required.
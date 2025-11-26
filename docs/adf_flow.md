# ADF Flow – Company Activity

Daily master pipeline: `pl_company_activity_daily_master`

1. **pl_ingest_crm_csv_to_staging**
   - Copy CRM CSV from Blob → `stg_crm_company_daily`.

2. **pl_ingest_product_usage_api**
   - Get `run_date` (e.g. yesterday).
   - Call Azure Function / Python (see `src/product_usage_ingest.py`) to hit product API and write JSON to Blob.
   - Copy JSON → `stg_product_usage_daily`.

3. **pl_load_fact_company_activity_daily**
   - Run stored procedure that executes `03_load_fact_table.sql` for `@run_date`.

**Failure alerts**

- Configure Azure Monitor alert on failures of `pl_company_activity_daily_master`.
- Action group: email / Teams notification to data team.
# Company Activity Pipeline & Data Model

This repo describes how I would build a **Company Activity** dashboard using:

- Azure Blob (daily CRM CSV + product usage API raw data)
- Azure Data Factory (ADF) for orchestration
- Azure SQL / Synapse (staging + analytics-ready table)
- A Python-style function to call the product API

---

## 1. Target Analytics Table

**Grain:** one row per `company_id` per `activity_date`.

Main fields:

- Company: `company_id`, `company_name`, `country`, `industry_tag`
- CRM: `last_contact_at`, `days_since_last_contact`
- Usage: `daily_active_users`, `daily_events`
- Rolling: `active_users_7d`, `events_7d`
- Flags: `is_churn_risk`, `is_new_logo`
- Metadata: `source_crm_date`, `source_usage_date`, `ingested_at`

SQL definitions are in `sql/`.

---

## 2. SQL & Derived Metric

- `sql/01_create_staging_tables.sql`: staging tables for CRM CSV and product usage.
- `sql/02_create_fact_table.sql`: `analytics.fact_company_activity_daily`.
- `sql/03_load_fact_table.sql`: joins CRM + usage, calculates `active_users_7d` and `is_churn_risk`.

---

## 3. ADF Flow

Described in `docs/adf_flow.md`.  
One daily master pipeline:

1. Ingest CRM CSV → `stg_crm_company_daily`
2. Ingest product usage API → Blob → `stg_product_usage_daily`
3. Load `analytics.fact_company_activity_daily` via SQL / stored procedure

---

## 4. Product Usage API Ingestion

`src/product_usage_ingest.py` contains Python-style pseudocode that:

- Loops over a date range
- Calls the product usage API (with pagination)
- Writes raw JSON to Blob in a `date=YYYY-MM-DD/` structure

---

## 5. If I Only Have 30 Minutes

I would first implement **API → Blob → product usage staging** for yesterday, because:

- CRM ingest from CSV is simple.
- The API is the riskiest part (auth, paging).
- Without usage data, the dashboard is much less useful.

I would postpone:
- Historical backfill
- Extra metrics and refined churn logic
- Star schema refactor and advanced monitoring

-- Staging tables for CRM CSV and product usage API

CREATE TABLE stg_crm_company_daily (
    crm_extract_date      DATE,           -- date of the CRM file
    company_id            INT,
    name                  NVARCHAR(255),
    country               NVARCHAR(100),
    industry_tag          NVARCHAR(100),
    last_contact_at       DATETIME,       -- last CRM contact
    ingested_at           DATETIME DEFAULT GETUTCDATE()
);

CREATE TABLE stg_product_usage_daily (
    usage_date       DATE,               -- date of product usage
    company_id       INT,
    active_users     INT,
    events           BIGINT,
    ingested_at      DATETIME DEFAULT GETUTCDATE()
);
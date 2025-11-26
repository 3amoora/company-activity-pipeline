-- Analytics table: one row per company per day

CREATE SCHEMA IF NOT EXISTS analytics;  -- remove if not supported

CREATE TABLE analytics.fact_company_activity_daily (
    activity_date           DATE        NOT NULL,
    company_id              INT         NOT NULL,

    company_name            NVARCHAR(255),
    country                 NVARCHAR(100),
    industry_tag            NVARCHAR(100),
    last_contact_at         DATETIME,
    days_since_last_contact INT,

    daily_active_users      INT,
    daily_events            BIGINT,

    active_users_7d         INT,
    events_7d               BIGINT,
    is_churn_risk           BIT,
    is_new_logo             BIT,

    source_crm_date         DATE,
    source_usage_date       DATE,
    ingested_at             DATETIME DEFAULT GETUTCDATE(),

    CONSTRAINT PK_fact_company_activity_daily
        PRIMARY KEY (activity_date, company_id)
);
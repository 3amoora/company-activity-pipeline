-- Example load for one @run_date (e.g. yesterday)

DECLARE @run_date DATE = CAST(GETDATE() AS DATE);
-- In ADF, @run_date would be passed as a parameter.

WITH crm_ranked AS (
    SELECT
        c.*,
        ROW_NUMBER() OVER (
            PARTITION BY c.company_id
            ORDER BY c.crm_extract_date DESC
        ) AS rn
    FROM stg_crm_company_daily c
    WHERE c.crm_extract_date <= @run_date
),
crm_latest AS (
    SELECT *
    FROM crm_ranked
    WHERE rn = 1
),
usage_7d AS (
    SELECT
        u.company_id,
        u.usage_date                AS activity_date,
        u.active_users              AS daily_active_users,
        u.events                    AS daily_events,
        SUM(u2.active_users)        AS active_users_7d,
        SUM(u2.events)              AS events_7d
    FROM stg_product_usage_daily u
    JOIN stg_product_usage_daily u2
      ON u.company_id = u2.company_id
     AND u2.usage_date BETWEEN DATEADD(DAY, -6, u.usage_date) AND u.usage_date
    WHERE u.usage_date = @run_date
    GROUP BY u.company_id, u.usage_date, u.active_users, u.events
),
base AS (
    SELECT
        u.activity_date,
        u.company_id,
        c.name          AS company_name,
        c.country,
        c.industry_tag,
        c.last_contact_at,
        CASE
            WHEN c.last_contact_at IS NULL THEN NULL
            ELSE DATEDIFF(DAY, c.last_contact_at, u.activity_date)
        END            AS days_since_last_contact,
        u.daily_active_users,
        u.daily_events,
        u.active_users_7d,
        u.events_7d,
        c.crm_extract_date AS source_crm_date,
        u.activity_date    AS source_usage_date
    FROM usage_7d u
    LEFT JOIN crm_latest c
      ON u.company_id = c.company_id
),
src AS (
    SELECT
        b.*,
        CASE
            WHEN b.active_users_7d = 0
                 AND (
                     b.last_contact_at IS NULL
                     OR DATEDIFF(DAY, b.last_contact_at, b.activity_date) > 30
                 )
            THEN 1 ELSE 0
        END AS is_churn_risk
    FROM base b
)

MERGE analytics.fact_company_activity_daily AS tgt
USING src
   ON tgt.activity_date = src.activity_date
  AND tgt.company_id    = src.company_id

WHEN MATCHED THEN
    UPDATE SET
        tgt.company_name            = src.company_name,
        tgt.country                 = src.country,
        tgt.industry_tag            = src.industry_tag,
        tgt.last_contact_at         = src.last_contact_at,
        tgt.days_since_last_contact = src.days_since_last_contact,
        tgt.daily_active_users      = src.daily_active_users,
        tgt.daily_events            = src.daily_events,
        tgt.active_users_7d         = src.active_users_7d,
        tgt.events_7d               = src.events_7d,
        tgt.is_churn_risk           = src.is_churn_risk,
        tgt.source_crm_date         = src.source_crm_date,
        tgt.source_usage_date       = src.source_usage_date,
        tgt.ingested_at             = GETUTCDATE()

WHEN NOT MATCHED THEN
    INSERT (
        activity_date,
        company_id,
        company_name,
        country,
        industry_tag,
        last_contact_at,
        days_since_last_contact,
        daily_active_users,
        daily_events,
        active_users_7d,
        events_7d,
        is_churn_risk,
        is_new_logo,
        source_crm_date,
        source_usage_date,
        ingested_at
    )
    VALUES (
        src.activity_date,
        src.company_id,
        src.company_name,
        src.country,
        src.industry_tag,
        src.last_contact_at,
        src.days_since_last_contact,
        src.daily_active_users,
        src.daily_events,
        src.active_users_7d,
        src.events_7d,
        src.is_churn_risk,
        0,                 -- is_new_logo: can be derived later
        src.source_crm_date,
        src.source_usage_date,
        GETUTCDATE()
    );
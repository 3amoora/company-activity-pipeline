# Q2.2 – Risks or Flaws in the SQL Snippet

The SQL snippet is:

SELECT company_id, date, SUM(events) AS events  
FROM fact_events  
GROUP BY company_id, date;

Below are the key risks and how I would improve them.

---

## 1️⃣ Full-table scan (no date filter)

The query processes the entire fact_events table every day because it has no WHERE clause.

Risk: This becomes slower as the table grows and is a major contributor to the 3+ hour runtime.

Fix: Add a date filter so we only aggregate the required date range (for example, yesterday only).

---

## 2️⃣ Time-zone or date-boundary mismatches with the API

The “date” field may not match how the API defines a day (UTC vs local time, truncation method, different cut-off windows).

Risk: Analysts see differences between dashboard numbers and the API for the same company_id and date.

Fix: Align the date logic with the API and use a consistent method for deriving the date (for example, always using UTC).

---

## 3️⃣ Missing filters for test data, environments, or event types

The query aggregates all rows, including test companies, non-prod environments, or event types that should not appear in reporting.

Risk: Inflated or incorrect counts compared to the API.

Fix: Add filters such as environment = 'prod', is_test = 0, and event_type IN (allowed types), depending on business logic.

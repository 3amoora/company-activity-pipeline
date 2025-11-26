# Q2.3 – How I Would Investigate the Performance and Data Mismatch Issue

Below is the approach I would take to investigate the 3+ hour runtime and the mismatches between the dashboard and the raw API.

---

## 1️⃣ Validate the mismatch with a real example

I would first ask the analyst team for a specific company_id and date where the dashboard number does not match the API.

Then I would:
• Re-run the aggregation logic manually in SQL for that company_id and date.  
• Pull the API data for the same pair.  
• Compare the two side by side.

This confirms whether the mismatch is due to logic, filters, time zones, or data issues.

---

## 2️⃣ Check date logic, time zones, and filters

I would verify:
• How the API defines a “day” (UTC vs local).  
• Whether the SQL uses the same day boundary.  
• Whether the API excludes certain event types or test data.  
• Whether the pipeline or fact table includes rows the API ignores.

A mismatch in how “date” is calculated is one of the most common causes of discrepancies.

---

## 3️⃣ Review the SQL query plan and runtime profile

Using EXPLAIN or the warehouse query profiler, I would check:
• Whether the query is scanning the entire fact_events table.  
• If partitions on date are being used.  
• Whether the query is spilling to disk or performing large shuffles.  
• How many rows are scanned versus returned.

If the query reads millions of rows to produce one day of results, this indicates missing pruning and explains the long runtime.

---

## 4️⃣ Inspect raw event data for duplicates or late arrivals

For the problematic company_id and date, I would examine the underlying data:
• Are there duplicate event rows?  
• Are late-arriving events coming in after the scheduled daily run?  
• Do we have missing or inconsistent event types?

This identifies whether data quality issues contribute to the mismatch.

---

## 5️⃣ Identify the slowest pipeline step

In ADF or the warehouse monitoring UI, I would check:
• Which activity takes the largest portion of the 3+ hours.  
• Whether the slowdown is in ingestion, transformation, or aggregation.  
• Whether the job is blocked, queued, or under-provisioned.

This helps me prioritise exactly where to optimise first.


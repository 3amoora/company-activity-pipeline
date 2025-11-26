# Q2.1 – Three Optimisation Changes (Ranked 1–3)

## 1️⃣ Make the aggregation incremental (highest impact)

Add a date filter so we only process new days, not the entire history.

WHERE date BETWEEN @start_date AND @end_date

Store results in a daily summary table and only update yesterday’s partition.

Reason: Removes full-table scans → biggest and fastest performance improvement.

---

## 2️⃣ Add / fix partitioning or indexing on (date, company_id)

Ensure the table is physically optimised for this query pattern:

• Partition or cluster by date  
• Add an index or distribution key including company_id  

Reason: Helps the engine prune partitions and avoid scanning the entire table.

---

## 3️⃣ Pre-aggregate earlier in the pipeline

Adjust upstream ingestion so events are already batched (for example, one row per company per day instead of very granular event-level rows).

Reason: Reduces table size and speeds up daily aggregation, but requires upstream changes, so it’s ranked #3.
# Q2.4 – Slack-Style Update to Analytics Team

Below is the short, clear Slack-style message I would send to the analytics team.

---

**Company Activity – performance and data consistency update**

• I am updating the daily aggregation to make it date-incremental, so we stop scanning the entire fact_events table each run. This should reduce the 3+ hour runtime.  
• Historical backfill will still use the current approach for now, so the performance improvements apply mainly to new days going forward.  
• I am aligning the date logic and filtering rules with the API to minimise differences for specific company_id and date combinations.  
• If you see any large mismatches between the dashboard and the API, please share an example here so I can use it as a validation case.


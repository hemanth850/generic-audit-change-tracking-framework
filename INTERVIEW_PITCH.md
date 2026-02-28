# Interview Pitch

## 60-Second Summary
I built a metadata-driven PL/SQL audit framework that captures `INSERT`, `UPDATE`, and `DELETE` events for any table without rewriting trigger logic table by table.  
The system generates triggers from data dictionary metadata, supports column-level and row-level JSON auditing, and has a bulk mode using compound triggers + `FORALL` for better performance under high write volume.  
I also added operational controls for reproducibility: saved generation configs, generated-trigger metadata, migration scripts, demo scripts, and benchmark scripts.

## Problem Statement
Most Oracle audit implementations are hardcoded per table, hard to scale, and hard to maintain consistently across environments.

## What I Implemented
- Reusable trigger generator package (`pkg_audit_generator`)
- Core audit package (`audit_pkg`) for logging and bulk flush
- Runtime audit controls (`audit_config`)
- Persistent generation controls (`audit_generator_config`)
- Trigger generation metadata (`audit_generated_trigger`)
- JSON diff mode (`ROW_JSON` event in `audit_log.json_payload`)
- Performance knobs (bulk mode, include/exclude columns, datatype skip, LOB control)
- Scale scripts (indexes + partition-ready audit table)
- End-to-end demo + benchmark scripts

## Why This Is Reusable
- Works against any table with a primary key.
- Uses dictionary metadata rather than table-specific handwritten trigger code.
- Uses parameterized generation options and stored config to standardize behavior by environment.
- Regeneration is scriptable and repeatable.

## Key Tradeoffs
- One generated trigger per table:
  - Pro: native DB behavior and straightforward execution path.
  - Con: generated artifact management required.
- Audit log is append-heavy:
  - Pro: durable, queryable history.
  - Con: requires retention/index/partition strategy over time.
- JSON mode is additive:
  - Pro: keeps backward compatibility with column-level reports.
  - Con: more rows/storage when enabled.

## Expected Questions and Answers

### Q: How do you prevent performance degradation on mass updates?
A: Use `p_bulk_mode => 'Y'` to buffer row changes in compound trigger memory and flush once with `FORALL`. Also reduce compared columns via include/exclude and skip expensive datatypes/LOBs unless needed.

### Q: How do you make this production-safe across environments?
A: Use migration scripts, compile order in README/RUNBOOK, persistent generator config in `audit_generator_config`, and regeneration from config for deterministic behavior.

### Q: How is tamper resistance handled?
A: This implementation focuses on application-level DB auditing. For stronger tamper controls, combine with DB privileges hardening, separate audit schema, restricted DML on audit tables, and optional archival/export pipeline.

### Q: Why both column-level logs and JSON logs?
A: Column-level rows are easy for existing SQL reports and filters. JSON adds compact row-level diff context for API/analytics use cases. Both together cover operational and analytical needs.

### Q: What would you do next in production?
A:
1. Add retention/archival policy and purge job.
2. Add tests for generation edge cases and DML correctness.
3. Add CI pipeline to compile SQL objects in an Oracle test environment.
4. Add role-based access model for admin operations.


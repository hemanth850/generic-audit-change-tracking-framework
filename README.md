# generic-audit-change-tracking-framework
Creating a reusable auditing system that can track INSERT, UPDATE, DELETE changes on any table without rewriting logic every time.

## Dynamic Trigger Generator (Step 1)

This repo now includes `pkg_audit_generator` to create audit triggers for any table in the current schema.

### Files
- `Audit Pkg/pkg_audit_generator.pks`
- `Audit Pkg/pkg_audit_generator.pkg`
- `Audit Trigger/generate_audit_trigger.sql`
- `Audit Trigger/generate_audit_trigger_json.sql`
- `Audit Trigger/save_audit_generator_config.sql`
- `Audit Trigger/generate_audit_trigger_from_config.sql`
- `Demo/demo_end_to_end.sql`
- `Benchmark/benchmark_bulk_mode.sql`
- `Audit Tables/migrations/add_json_payload_to_audit_log.sql`
- `Audit Tables/migrations/add_audit_log_indexes.sql`
- `Audit Tables/audit_generator_config.sql`
- `Audit Tables/audit_generated_trigger.sql`
- `Audit Tables/indexes/audit_log_indexes.sql`
- `Audit Tables/partitioning/audit_log_partitioned.sql`

### Compile
```sql
-- Existing databases only (new setups can run Audit Tables/audit_log.sql directly):
@Audit Tables/migrations/add_json_payload_to_audit_log.sql
@Audit Tables/migrations/add_audit_log_indexes.sql

@Audit Tables/audit_generator_config.sql
@Audit Tables/audit_generated_trigger.sql

@Audit Pkg/audit_management_pkg.pks
@Audit Pkg/audit_management_pkg.pkg
@Audit Pkg/pkg_audit_generator.pks
@Audit Pkg/pkg_audit_generator.pkg
```

### Generate a trigger for a table
```sql
@Audit Trigger/generate_audit_trigger.sql EMP
```

### Generate a JSON-enabled trigger for a table
```sql
@Audit Trigger/generate_audit_trigger_json.sql EMP
```

This will:
1. Enable auditing in `audit_config` for the table
2. Create/replace trigger `TRG_AUD_<TABLE_NAME>` (or custom name if you call package directly)
3. Log INSERT, UPDATE (column-level), and DELETE through `audit_pkg`

### Direct package usage
```sql
BEGIN
  pkg_audit_generator.generate_trigger(
    p_table_name         => 'EMP',
    p_trigger_name       => 'TRG_AUDIT_EMP',
    p_include_insert_row => 'Y',
    p_include_delete_row => 'Y'
  );
END;
/

BEGIN
  pkg_audit_generator.drop_trigger(
    p_table_name   => 'EMP',
    p_trigger_name => 'TRG_AUDIT_EMP'
  );
END;
/
```

## Operational Controls (Step 3)

`pkg_audit_generator` now supports persistent config and generation metadata:

- `save_config(...)`: Store per-table trigger generation options.
- `clear_config(...)`: Remove saved config for a table.
- `generate_trigger_from_config(...)`: Generate trigger using saved options.
- `audit_generated_trigger`: Tracks the latest generated trigger/options per table.

### Example: save once, generate many times
```sql
@Audit Trigger/save_audit_generator_config.sql EMP
@Audit Trigger/generate_audit_trigger_from_config.sql EMP
```

## Performance-Focused Generator Options

`pkg_audit_generator.generate_trigger` now supports:

- `p_bulk_mode` (`Y`/`N`, default `Y`):
  Generates a compound trigger that buffers changes in memory and flushes once per statement using `FORALL`.
- `p_include_columns`:
  Comma-separated allow-list (example: `'EMP_NAME,SALARY,DEPTNO'`).
- `p_exclude_columns`:
  Comma-separated deny-list.
- `p_skip_datatypes`:
  Comma-separated datatype names to skip in UPDATE comparison (example: `'CLOB,NCLOB,TIMESTAMP WITH TIME ZONE'`).
- `p_include_lobs` (`Y`/`N`, default `N`):
  Avoids expensive LOB substring comparisons unless explicitly enabled.
- `p_json_mode` (`Y`/`N`, default `N`):
  Adds one extra `ROW_JSON` audit row per updated row with `json_payload` like `{"old": {...}, "new": {...}}`.

### Example: selective high-performance trigger
```sql
BEGIN
  pkg_audit_generator.generate_trigger(
    p_table_name         => 'EMP',
    p_include_insert_row => 'Y',
    p_include_delete_row => 'Y',
    p_include_columns    => 'ENAME,SAL,DEPTNO,HIREDATE',
    p_exclude_columns    => 'UPDATED_AT',
    p_skip_datatypes     => 'CLOB,NCLOB',
    p_include_lobs       => 'N',
    p_bulk_mode          => 'Y',
    p_json_mode          => 'N'
  );
END;
/
```

## JSON Mode (Optional, Additive)

JSON mode does not replace current column-level audit rows. It adds one extra row per updated record:

- `column_name = 'ROW_JSON'`
- `action_type = 'UPDATE'`
- `json_payload = {"old": {...}, "new": {...}}`

### Example: enable JSON diff row
```sql
BEGIN
  pkg_audit_generator.generate_trigger(
    p_table_name         => 'EMP',
    p_include_columns    => 'ENAME,SAL,DEPTNO',
    p_bulk_mode          => 'Y',
    p_json_mode          => 'Y'
  );
END;
/
```

## Batch Logging API

`audit_pkg` now includes `flush_changes` and shared types:

- `audit_pkg.t_change_rec`
- `audit_pkg.t_change_tab`
- `audit_pkg.flush_changes(...)`

Generated bulk-mode triggers use these for `FORALL` inserts into `audit_log`.

## Audit Log Scaling (Step 4)

### Existing database: add indexes
```sql
@Audit Tables/migrations/add_audit_log_indexes.sql
```

This adds idempotent indexes for the most common access patterns:

- by table and time (`table_name, changed_at`)
- by table/pk and time (`table_name, pk_value, changed_at`)
- by actor and time (`changed_by, changed_at`)

### New high-volume deployment: partitioned audit table
Use:

- `Audit Tables/partitioning/audit_log_partitioned.sql`

It creates `audit_log` with monthly interval partitions on `changed_at` and local indexes.

## Benchmark & Demo (Step 5)

### End-to-end demo
```sql
@Demo/demo_end_to_end.sql
```

This script:

- creates `EMPLOYEES` if missing
- enables auditing
- generates JSON-enabled trigger
- runs INSERT, UPDATE, DELETE
- shows audit rows and `ROW_JSON` payload

### Bulk mode benchmark
```sql
@Benchmark/benchmark_bulk_mode.sql 5000
```

`5000` is the number of rows used in the workload.

Output format:
```text
bulk_mode=N     elapsed_ms=<value> audit_rows=<value>
bulk_mode=Y     elapsed_ms=<value> audit_rows=<value>
```

### Benchmark results template

| Run Date | Row Count | bulk_mode=N (ms) | bulk_mode=Y (ms) | Speedup |
|----------|-----------|------------------|------------------|---------|
| YYYY-MM-DD | 5000 |  |  |  |

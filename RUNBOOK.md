# Runbook

## Scope
Operational guide for setup, migration, generation, validation, and cleanup of the audit framework.

## 1. Fresh Setup

Run in SQL*Plus/SQLcl from repo root:

```sql
@"Audit Tables/audit_config.sql"
@"Audit Tables/audit_log.sql"
@"Audit Tables/audit_generator_config.sql"
@"Audit Tables/audit_generated_trigger.sql"
@"Audit Tables/indexes/audit_log_indexes.sql"

@"Audit Pkg/audit_management_pkg.pks"
@"Audit Pkg/audit_management_pkg.pkg"
@"Audit Pkg/pkg_audit_generator.pks"
@"Audit Pkg/pkg_audit_generator.pkg"

@"Reporting View/vw_audit_history.sql"
```

## 2. Existing DB Migrations

```sql
@"Audit Tables/migrations/add_json_payload_to_audit_log.sql"
@"Audit Tables/migrations/add_audit_log_indexes.sql"
```

## 3. Enable and Generate Triggers

### Standard mode
```sql
@"Audit Trigger/generate_audit_trigger.sql" EMPLOYEES
```

### JSON-enabled mode
```sql
@"Audit Trigger/generate_audit_trigger_json.sql" EMPLOYEES
```

### Config-driven generation
```sql
@"Audit Trigger/save_audit_generator_config.sql" EMPLOYEES
@"Audit Trigger/generate_audit_trigger_from_config.sql" EMPLOYEES
```

## 4. Validation

### Functional demo
```sql
@"Demo/demo_end_to_end.sql"
```

### Performance benchmark
```sql
@"Benchmark/benchmark_bulk_mode.sql" 5000
```

## 5. Operational Queries

### Audit flag status
```sql
SELECT * FROM audit_config ORDER BY table_name;
```

### Saved generator configuration
```sql
SELECT * FROM audit_generator_config ORDER BY table_name;
```

### Last generated trigger metadata
```sql
SELECT * FROM audit_generated_trigger ORDER BY generated_at DESC;
```

### Recent audit events
```sql
SELECT *
FROM vw_audit_history
WHERE table_name = 'EMPLOYEES'
ORDER BY changed_at DESC;
```

## 6. Rollback / Cleanup

### Drop one generated trigger
```sql
BEGIN
  pkg_audit_generator.drop_trigger(p_table_name => 'EMPLOYEES');
END;
/
```

### Disable auditing for one table
```sql
BEGIN
  audit_pkg.disable_audit(p_table_name => 'EMPLOYEES');
END;
/
```

### Remove saved generation config
```sql
BEGIN
  pkg_audit_generator.clear_config(p_table_name => 'EMPLOYEES');
END;
/
```

### Purge audit data for one table
```sql
DELETE FROM audit_log WHERE table_name = 'EMPLOYEES';
COMMIT;
```

## 7. Release Checklist (Minimal)
1. Compile all objects without errors.
2. Run demo script successfully.
3. Run benchmark script and capture numbers in `README.md`.
4. Verify `vw_audit_history` returns expected rows.
5. Confirm trigger metadata populated in `audit_generated_trigger`.


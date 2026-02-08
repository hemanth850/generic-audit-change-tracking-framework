# generic-audit-change-tracking-framework
Creating a reusable auditing system that can track INSERT, UPDATE, DELETE changes on any table without rewriting logic every time.

## Dynamic Trigger Generator (Step 1)

This repo now includes `pkg_audit_generator` to create audit triggers for any table in the current schema.

### Files
- `Audit Pkg/pkg_audit_generator.pks`
- `Audit Pkg/pkg_audit_generator.pkg`
- `Audit Trigger/generate_audit_trigger.sql`

### Compile
```sql
@Audit Pkg/audit_management_pkg.pks
@Audit Pkg/audit_management_pkg.pkg
@Audit Pkg/pkg_audit_generator.pks
@Audit Pkg/pkg_audit_generator.pkg
```

### Generate a trigger for a table
```sql
@Audit Trigger/generate_audit_trigger.sql EMP
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
    p_bulk_mode          => 'Y'
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

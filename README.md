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
3. Log INSERT, UPDATE (column-level), and DELETE using `audit_pkg.log_change`

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

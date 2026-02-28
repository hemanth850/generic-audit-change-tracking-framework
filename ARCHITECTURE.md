# Architecture

## Objective
Provide a reusable PL/SQL auditing framework that captures `INSERT`, `UPDATE`, and `DELETE` changes for any table with minimal per-table coding.

## Core Components

### 1. Data Tables
- `Audit Tables/audit_log.sql`
  - central audit event store
  - column-level old/new values
  - optional `json_payload` for row-level diff
- `Audit Tables/audit_config.sql`
  - runtime toggle per table:
    - `audit_enabled`
    - `audit_insert`
    - `audit_update`
    - `audit_delete`
- `Audit Tables/audit_generator_config.sql`
  - persistent generation rules per table
  - include/exclude columns, datatype skips, JSON mode, bulk mode
- `Audit Tables/audit_generated_trigger.sql`
  - metadata snapshot of last generated trigger config per table

### 2. Packages
- `Audit Pkg/audit_management_pkg.*`
  - `enable_audit`, `disable_audit`
  - `log_change(...)` for row/column event insert
  - `flush_changes(...)` bulk insert (`FORALL`) path
- `Audit Pkg/pkg_audit_generator.*`
  - metadata-driven trigger generation from `USER_TAB_COLUMNS` and PK constraints
  - options:
    - include/exclude columns
    - skip datatypes
    - include/exclude LOB processing
    - bulk mode (`COMPOUND TRIGGER`)
    - JSON mode (`ROW_JSON` event)
  - config operations:
    - `save_config`
    - `clear_config`
    - `generate_trigger_from_config`

### 3. Trigger Scripts
- `Audit Trigger/generate_audit_trigger.sql`
- `Audit Trigger/generate_audit_trigger_json.sql`
- `Audit Trigger/save_audit_generator_config.sql`
- `Audit Trigger/generate_audit_trigger_from_config.sql`

### 4. Reporting Layer
- `Reporting View/vw_audit_history.sql`
  - unified query view for audit events including JSON payload field

## Runtime Flow

## Flow A: Trigger Generation
1. User executes generator (direct package call or SQL script).
2. `pkg_audit_generator` validates target table and primary key existence.
3. Package reads data dictionary metadata (`USER_TAB_COLUMNS`, constraints).
4. Package builds trigger DDL dynamically with selected options.
5. Trigger is created/replaced.
6. `audit_generated_trigger` is upserted with generation metadata.

## Flow B: DML Auditing
1. Table trigger fires on `INSERT/UPDATE/DELETE`.
2. Trigger checks `audit_config` flags.
3. If enabled:
   - logs insert/delete event rows (optional switches)
   - compares old/new values for included update columns
   - logs changed columns to `audit_log`
4. If `p_json_mode = 'Y'`:
   - builds row-level JSON diff
   - logs additional `ROW_JSON` audit entry
5. If `p_bulk_mode = 'Y'`:
   - accumulates changes in memory
   - flushes once per statement via `audit_pkg.flush_changes`

## Flow C: Operational Configuration
1. Team stores generation defaults in `audit_generator_config`.
2. Trigger regeneration uses `generate_trigger_from_config`.
3. Release/regeneration stays reproducible across environments.

## Performance Strategy
- Bulk mode reduces row-by-row insert overhead in heavy updates.
- Selective column and datatype filters reduce unnecessary comparisons.
- LOB comparison is opt-in to avoid expensive operations by default.
- Optional index and partition scripts optimize query and retention behavior:
  - `Audit Tables/indexes/audit_log_indexes.sql`
  - `Audit Tables/partitioning/audit_log_partitioned.sql`

## Design Tradeoffs
- Current implementation is metadata-driven but still emits one physical trigger per table.
  - Benefit: native DB trigger behavior and predictable execution.
  - Tradeoff: generated SQL artifact per table must be managed.
- In-memory runtime is not used for audit persistence (audit data is table-backed).
  - Benefit: durability for audit events.
  - Tradeoff: storage growth management is required.


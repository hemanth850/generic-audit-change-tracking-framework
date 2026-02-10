-- Example usage:
-- @Audit\ Trigger\generate_audit_trigger_from_config.sql EMP

DEFINE table_name = '&1'

BEGIN
    pkg_audit_generator.generate_trigger_from_config(
        p_table_name => UPPER('&&table_name')
    );
END;
/

PROMPT Trigger generated from saved config for &&table_name.


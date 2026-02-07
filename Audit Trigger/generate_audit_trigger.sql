-- Example usage:
-- @Audit\ Pkg\audit_management_pkg.pks
-- @Audit\ Pkg\audit_management_pkg.pkg
-- @Audit\ Pkg\pkg_audit_generator.pks
-- @Audit\ Pkg\pkg_audit_generator.pkg
-- @Audit\ Trigger\generate_audit_trigger.sql EMP

DEFINE table_name = '&1'

BEGIN
    audit_pkg.enable_audit(
        p_table_name => UPPER('&&table_name'),
        p_ins        => 'Y',
        p_upd        => 'Y',
        p_del        => 'Y'
    );

    pkg_audit_generator.generate_trigger(
        p_table_name         => UPPER('&&table_name'),
        p_include_insert_row => 'Y',
        p_include_delete_row => 'Y'
    );
END;
/

PROMPT Trigger generated for &&table_name.


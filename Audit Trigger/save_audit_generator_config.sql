-- Example usage:
-- @Audit\ Trigger\save_audit_generator_config.sql EMP

DEFINE table_name = '&1'

BEGIN
    pkg_audit_generator.save_config(
        p_table_name         => UPPER('&&table_name'),
        p_include_insert_row => 'Y',
        p_include_delete_row => 'Y',
        p_include_columns    => NULL,
        p_exclude_columns    => NULL,
        p_skip_datatypes     => 'CLOB,NCLOB',
        p_include_lobs       => 'N',
        p_bulk_mode          => 'Y',
        p_json_mode          => 'Y'
    );
END;
/

PROMPT Generator config saved for &&table_name.



-- Define a function which will be dropped after the session ends
CREATE FUNCTION pg_temp.lsmb__role(global_role text) RETURNS text
  LANGUAGE SQL STABLE AS
  $$ select coalesce((select value
                        from defaults
                       where setting_key = 'role_prefix'),
                     'lsmb_' || current_database() || '__') || global_role; $$;

  DO $$
    DECLARE
    t_rolename text;
    t_new_rolename text;
BEGIN
  select pg_temp.lsmb__role('ap_all_vouchers') into t_rolename;
  select pg_temp.lsmb__role('ap_voucher_all') into t_new_rolename;

  perform * from pg_roles where rolname = t_rolename;
  if found then
    perform * from pg_roles where rolname = t_new_rolename;
    if found then
      execute 'drop role if exists' || quote_ident(t_rolename);
    else
      execute 'alter role ' || quote_ident(t_rolename) || ' rename to ' || quote_ident(t_new_rolename);
    end if;
  end if;

  -- drop a role which doesn't have an AR equivalent and from its naming
  -- is at least confusing...
  select pg_temp.lsmb__role('ap_all_transactions') into t_rolename;
  execute 'drop role if exists ' || quote_ident(t_rolename);
END;
$$ language plpgsql;


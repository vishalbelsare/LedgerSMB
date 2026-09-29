
alter table warehouse
  add column last_updated timestamp without time zone not null default now();

drop trigger if exists warehouse_update_last_updated on warehouse;
create trigger warehouse_update_last_updated
   before update on warehouse
   for each row execute procedure cdc_update_last_updated();


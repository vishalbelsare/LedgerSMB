
alter table pricegroup
  add column last_updated timestamp without time zone not null default now();

drop trigger if exists pricegroup_update_last_updated on pricegroup;
create trigger pricegroup_update_last_updated
   before update on pricegroup
   for each row execute procedure cdc_update_last_updated();


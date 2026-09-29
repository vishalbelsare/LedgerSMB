
alter table language
  add column last_updated timestamp without time zone not null default now();

drop trigger if exists language_update_last_updated on language;
create trigger language_update_last_updated
   before update on language
   for each row execute procedure cdc_update_last_updated();


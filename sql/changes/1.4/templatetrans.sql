ALTER TABLE journal_entry ALTER COLUMN effective_start drop not null;
ALTER TABLE journal_entry ALTER COLUMN effective_end drop not null;
ALTER TABLE journal_entry ALTER COLUMN post_date drop not null;
ALTER TABLE journal_entry ALTER COLUMN reference drop not null;
ALTER TABLE journal_entry ADD CHECK(is_template or reference is not null);

DROP INDEX "je_unique_source";
CREATE UNIQUE INDEX "je_unique_source" ON journal_entry(journal, reference) where journal in (1, 2) and not is_template;


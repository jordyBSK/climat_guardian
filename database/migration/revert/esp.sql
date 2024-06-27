-- Revert climat-guardian:esp from pg

BEGIN;

    -- drop the esp table
    drop table api.esp;

COMMIT;

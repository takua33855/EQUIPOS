-- ============================================================================
--  03_grants.sql  ·  Pizarra de Equipos · Transporte Vila
--
--  FIX: 01_enganches.sql creó la tabla con RLS y su policy, pero sin los GRANT
--  de tabla. Una policy filtra FILAS; el permiso base para que el rol anon
--  toque la tabla es un GRANT. Sin esto PostgREST responde:
--      42501 · permission denied for table enganches
--  aunque la policy diga using(true).
--
--  Las tablas creadas desde el Table Editor de Supabase reciben estos grants
--  automáticamente; las creadas por SQL, no.
--
--  Correr una sola vez en el SQL Editor. Ya está incorporado a 01_enganches.sql,
--  así que si algún día re-corrés ese archivo completo, este queda redundante.
-- ============================================================================

grant select, insert, update, delete on public.enganches to anon, authenticated;
grant usage, select on all sequences in schema public to anon, authenticated;

-- Verificación: debe listar anon y authenticated con los 4 privilegios.
--   select grantee, privilege_type
--     from information_schema.role_table_grants
--    where table_name = 'enganches'
--    order by grantee, privilege_type;

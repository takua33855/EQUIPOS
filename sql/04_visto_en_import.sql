-- ============================================================================
--  04_visto_en_import.sql  ·  Pizarra de Equipos · Transporte Vila
--
--  Agrega visto_en_import a los tres maestros. El importador le pone now() a
--  cada fila que aparece en el Excel; las que no aparecen conservan la fecha
--  vieja, así el informe puede decir "esta unidad no viene en la planilla
--  desde el 14/08/2026" sin ocultar ni borrar nada.
--
--  NO se reusa la columna `activo` a propósito: ahí el significado natural es
--  "de baja en la flota" (vendido, renunció), un hecho del negocio distinto de
--  "no vino en la última planilla", que es un hecho de la sincronización.
--  Además `activo` ya tiene el sentido "enganche vigente" en public.enganches.
--
--  Ejecutar en el SQL Editor de Supabase. Es idempotente.
-- ============================================================================

alter table public.choferes  add column if not exists visto_en_import timestamptz;
alter table public.tractores add column if not exists visto_en_import timestamptz;
alter table public.semis     add column if not exists visto_en_import timestamptz;

comment on column public.choferes.visto_en_import  is
  'Última vez que la fila apareció en un Excel importado. NULL = nunca se vio en un import.';
comment on column public.tractores.visto_en_import is
  'Última vez que la fila apareció en un Excel importado. NULL = nunca se vio en un import.';
comment on column public.semis.visto_en_import     is
  'Última vez que la fila apareció en un Excel importado. NULL = nunca se vio en un import.';

-- Unicidad de la clave natural: es lo que hace que el merge por patente sea
-- determinista. Se compara normalizada (mayúsculas, sin separadores) para que
-- 'CDY 815' y 'CDY815' no puedan coexistir como dos unidades distintas.
create unique index if not exists tractores_patente_unico_idx
  on public.tractores (upper(regexp_replace(patente, '[^A-Za-z0-9]', '', 'g')));
create unique index if not exists semis_patente_unico_idx
  on public.semis (upper(regexp_replace(patente, '[^A-Za-z0-9]', '', 'g')));

-- ============================================================================
--  Verificación:
--    select patente, tipo, visto_en_import from public.semis order by patente;
-- ============================================================================

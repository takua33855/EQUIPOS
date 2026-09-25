-- ============================================================================
--  01_enganches.sql  ·  Pizarra de Equipos · Transporte Vila
--
--  Crea public.enganches: una fila = un enganche (chofer + tractor + semi
--  + equipo de frío) dentro de un grupo.
--
--  El grupo NO es tabla aparte: es texto libre en cada fila. Un grupo nuevo
--  existe con sólo insertar una fila que lo nombre.
--
--  Ejecutar en el SQL Editor de Supabase. Es idempotente.
-- ============================================================================

create table if not exists public.enganches (
  id          bigint generated always as identity primary key,

  -- Grupo / ruta / cliente. Texto libre, dinámico.
  grupo       text    not null default 'SIN GRUPO',

  -- Referencias por id a las tablas maestras existentes.
  chofer_id   bigint      references public.choferes  (id) on delete set null,
  tractor_id  bigint not null
                          references public.tractores (id) on delete restrict,
  semi_id     bigint      references public.semis     (id) on delete set null,

  -- Equipo de frío: texto libre, SIN FK. Todavía no existe tabla de frío con
  -- ids: ninguna de las 49 unidades EQUIPO DE FRIO del Excel está cargada en
  -- Supabase. La app lo resuelve por patente normalizada contra el maestro.
  frio_patente text,

  -- Orden de la tarjeta dentro del grupo.
  orden       int     not null default 0,

  nota        text,
  activo      boolean not null default true,
  creado_at   timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table  public.enganches is
  'Pizarra de equipos: chofer + tractor + semi + frío, agrupados por grupo (texto libre).';
comment on column public.enganches.grupo is
  'Cliente / ruta. Texto libre: un grupo nuevo aparece al insertar una fila.';
comment on column public.enganches.frio_patente is
  'Equipo de frío por patente (texto, sin FK): no hay tabla de frío con ids.';

-- ── Índices ─────────────────────────────────────────────────────────────────
create index if not exists enganches_grupo_orden_idx
  on public.enganches (grupo, orden);

-- Un recurso no puede estar en dos enganches activos a la vez: es lo que hace
-- que el panel "Disponibles" (universo menos asignado) se pueda calcular solo.
create unique index if not exists enganches_chofer_unico_idx
  on public.enganches (chofer_id)  where activo and chofer_id  is not null;
create unique index if not exists enganches_tractor_unico_idx
  on public.enganches (tractor_id) where activo;
create unique index if not exists enganches_semi_unico_idx
  on public.enganches (semi_id)    where activo and semi_id    is not null;
-- Frío se compara por patente normalizada (mismo criterio que el importador
-- del panel Admin: mayúsculas y sin separadores, "CDY 815" == "CDY815").
create unique index if not exists enganches_frio_unico_idx
  on public.enganches (upper(regexp_replace(frio_patente, '[^A-Za-z0-9]', '', 'g')))
  where activo and frio_patente is not null and frio_patente <> '';

-- ── updated_at automático ───────────────────────────────────────────────────
create or replace function public.enganches_touch()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists enganches_touch_trg on public.enganches;
create trigger enganches_touch_trg
  before update on public.enganches
  for each row execute function public.enganches_touch();

-- ── RLS ─────────────────────────────────────────────────────────────────────
-- Mismo criterio que choferes/tractores/semis: la app usa la anon key y
-- escribe directo. El rol editor se controla en la app, no acá.
alter table public.enganches enable row level security;

drop policy if exists enganches_anon_all on public.enganches;
create policy enganches_anon_all
  on public.enganches for all
  to anon, authenticated
  using (true) with check (true);

-- IMPRESCINDIBLE además de la policy: una policy filtra FILAS, pero el permiso
-- base sobre la tabla es un GRANT. Sin esto PostgREST devuelve 42501
-- "permission denied for table enganches" aunque la policy diga using(true).
-- Las tablas creadas desde el Table Editor de Supabase reciben estos grants
-- solas; las creadas por SQL como ésta, no.
grant select, insert, update, delete on public.enganches to anon, authenticated;
grant usage, select on all sequences in schema public to anon, authenticated;

-- ============================================================================
--  Verificación:
--    select count(*) from public.enganches;
--    select grupo, count(*) from public.enganches group by grupo order by 2 desc;
-- ============================================================================

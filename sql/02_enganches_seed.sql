-- ============================================================================
--  02_enganches_seed.sql  ·  Pizarra de Equipos · Transporte Vila
--
--  Carga inicial: 58 enganches, 11 grupos.
--  Origen: data/PIZARRA_ENGANCHES.xlsx, hoja ENGANCHES.
--
--  Los ids son los REALES de Supabase al 23/09/2026, resueltos así:
--    · tractor_id / semi_id : por patente normalizada (mayúsculas, sin separadores)
--    · chofer_id            : por DNI; por nombre cuando el DNI falta o es ambiguo
--
--  Casos particulares resueltos por nombre (el DNI no alcanza):
--    · Los choferes 129 y 153 tienen el MISMO DNI cargado en la tabla
--      choferes, siendo dos personas distintas: es un error del dato de
--      origen. Por eso esos dos enganches se resuelven por nombre.
--    · Los choferes 180 y 181 no tienen DNI en el Excel.
--    · Una fila trae en la columna CHOFER un texto que no es una persona ni
--      existe en la hoja CHOFERES: va con chofer_id NULL y el texto en nota.
--
--  Los comentarios de cada fila nombran sólo unidades, no personas: el
--  chofer va por id, que es lo que se inserta. Este repo es público.
--
--  Ejecutar DESPUÉS de 01_enganches.sql. Es idempotente: vacía y recarga.
-- ============================================================================

begin;

delete from public.enganches;

insert into public.enganches
  (grupo, chofer_id, tractor_id, semi_id, frio_patente, orden, nota)
values
  ('LINEAS', 175, 199, NULL, 'FRIO 37', 1, NULL),  -- OME548
  ('LINEAS', 168, 212, 95, 'FRIO 26', 2, NULL),  -- AI501UL + AF773UV
  ('LINEAS', 143, 144, 117, 'FRIO 38', 3, NULL),  -- AE031SH + OOJ939
  ('LINEAS', 122, 143, 89, 'FRIO 33', 4, NULL),  -- AE031SF + AF336MN
  ('LINEAS', 139, 176, 96, 'FRIO 32', 5, NULL),  -- AI344TU + AF788UH
  ('PALADINI', 140, 164, 88, 'FRIO 39', 1, NULL),  -- AG829LI + AF257OR
  ('PALADINI', 157, 192, 82, 'FRIO 48', 2, NULL),  -- MJF808 + AB059AV
  ('PALADINI', 148, 149, NULL, 'FRIO 47', 3, NULL),  -- AE633YA
  ('PALADINI', 167, 171, NULL, 'FRIO 66', 4, NULL),  -- AH438JA
  ('PALADINI', 165, 203, NULL, 'FRIO 51', 5, NULL),  -- OPL041
  ('COCA-COLA', 141, 182, 83, NULL, 1, NULL),  -- JKR265 + AE379VG
  ('COCA-COLA', 128, 155, 103, NULL, 2, NULL),  -- AF516CR + AG772CQ
  ('COCA-COLA', 118, 201, 86, NULL, 3, NULL),  -- OOJ967 + AF144FU
  ('COCA-COLA', 117, 140, 105, NULL, 4, NULL),  -- AB620QF + AH248KX
  ('COCA-COLA', 127, 154, 98, NULL, 5, NULL),  -- AF377VL + AF976AT
  ('COCA-COLA', 144, 197, 85, NULL, 6, NULL),  -- MWT867 + AE379VI
  ('COCA-COLA', 170, 184, 84, NULL, 7, NULL),  -- KHA702 + AE379VH
  ('COCA-COLA', 136, 158, 107, NULL, 8, NULL),  -- AG171WM + AH478DQ
  ('COCA-COLA', 176, 160, 102, NULL, 9, NULL),  -- AG646UM + AG473MN
  ('ANONIMA', 138, 169, 104, 'FRIO 63', 1, NULL),  -- AH211YW + AH160NL
  ('ANONIMA', 161, 150, 94, 'FRIO 44', 2, NULL),  -- AE633YK + AF773UU
  ('ANONIMA', 169, 142, 97, 'FRIO 19', 3, NULL),  -- AC875MP + AF799QF
  ('ANONIMA', 159, 157, 90, 'FRIO 34', 4, NULL),  -- AG040CT + AF336MO
  ('ANONIMA', 160, 159, 93, 'FRIO 43', 5, NULL),  -- AG328AY + AF577WL
  ('ANONIMA', 158, 174, 108, 'FRIO 67', 6, NULL),  -- AH862DB + AH478DR
  ('ANONIMA', 123, 206, 81, 'FRIO 23', 7, NULL),  -- PEB523 + AB059AU
  ('ANONIMA', 150, 198, NULL, 'FRIO 55', 8, NULL),  -- NKK571
  ('ANONIMA', 124, 147, NULL, 'FRIO 50', 9, NULL),  -- AE318UJ
  ('ANONIMA', 132, 172, 100, 'FRIO 36', 10, NULL),  -- AH794IY + AG027EU
  ('SERENISIMA REPARTO', 147, 163, NULL, 'FRIO 61', 1, NULL),  -- AG804GZ
  ('SERENISIMA REPARTO', 125, 200, NULL, 'FRIO 65', 2, NULL),  -- OOJ936
  ('SERENISIMA REPARTO', NULL, 193, NULL, 'FRIO 42', 3, NULL),  -- MLM974
  ('AUXILIO SERENISIMA', 119, 188, NULL, 'FRIO 40', 1, NULL),  -- KTZ123
  ('BATEA', 142, 189, 129, NULL, 1, NULL),  -- KTZ128 + AF325II
  ('BATEA', 177, 187, 130, NULL, 2, NULL),  -- KRE799 + AH143JX
  ('FURGON', 156, 175, 106, 'FRIO 64', 1, NULL),  -- AH862DC + AH248LH
  ('FURGON', 121, 205, 99, 'FRIO 30', 2, NULL),  -- PCK412 + AF976AZ
  ('FURGON', 133, 191, 110, 'FRIO 62', 3, NULL),  -- LDU042 + KGC764
  ('BARANDA/SIDER', 149, 196, 113, NULL, 1, NULL),  -- MOK621 + NAN729
  ('BARANDA/SIDER', 164, 141, 87, NULL, 2, NULL),  -- AC875MO + AF250GH
  ('BARANDA/SIDER', 155, 202, 91, NULL, 3, NULL),  -- OOJ968 + AF357MV
  ('BARANDA/SIDER', 163, 183, 111, NULL, 4, NULL),  -- JXS462 + LYV768
  ('BARANDA/SIDER', 152, 165, 115, NULL, 5, NULL),  -- AG883RT + NKK575
  ('PARAGUAY', 131, 216, 125, NULL, 1, NULL),  -- BZH961 + CDY425
  ('PARAGUAY', 129, 210, 121, NULL, 2, NULL),  -- AAAU356 + AAAU179
  ('PARAGUAY', 153, 208, 124, NULL, 3, NULL),  -- AAAU354 + CDY 815
  ('PARAGUAY', NULL, 213, 127, NULL, 4, NULL),  -- BOH702 + HAL 152
  ('PARAGUAY', NULL, 214, 128, NULL, 5, NULL),  -- BOH705 + HBZ510
  ('PARAGUAY', 171, 209, 123, NULL, 6, NULL),  -- AAAU355 + CDY 814
  ('PARAGUAY', 178, 215, 126, NULL, 7, NULL),  -- BYT986 + HAL 151
  ('PARAGUAY', 120, 211, 122, 'FRIO 69', 8, NULL),  -- AAVS071 + AAVR465
  ('Particulares', 173, 145, NULL, NULL, 1, NULL),  -- AE115DH
  ('Particulares', 179, 153, NULL, NULL, 2, NULL),  -- AF357MU
  ('Particulares', 180, 156, NULL, NULL, 3, NULL),  -- AF895HA
  ('Particulares', 181, 161, NULL, NULL, 4, NULL),  -- AG646UT
  ('Particulares', NULL, 162, NULL, NULL, 5, 'RAFAELA'),  -- AG646UX
  ('Particulares', 172, 151, NULL, NULL, 6, NULL),  -- AE876UY
  ('Particulares', 126, 139, NULL, NULL, 7, NULL);  -- AB059AT

commit;

-- ============================================================================
--  Verificación (debe devolver 58 / 54 / 41 / 28 y ninguna fila huérfana)
-- ============================================================================
--  select count(*) as total,
--         count(chofer_id)    as con_chofer,
--         count(semi_id)      as con_semi,
--         count(frio_patente) as con_frio
--    from public.enganches;
--
--  select e.grupo, c.nombre, t.patente as tractor, s.patente as semi,
--         e.frio_patente, e.orden, e.nota
--    from public.enganches e
--    left join public.choferes  c on c.id = e.chofer_id
--    left join public.tractores t on t.id = e.tractor_id
--    left join public.semis     s on s.id = e.semi_id
--   order by e.grupo, e.orden;
-- ============================================================================

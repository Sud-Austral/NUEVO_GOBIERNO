
-- ================================================================
-- DATOS DE PRUEBA: 20 REGISTROS POR TABLA (SUPABASE / POSTGRESQL)
-- Usa generate_series para poblar sin romper claves foráneas
-- ================================================================

-- LIMPIEZA OPCIONAL (DESCOMENTAR SI QUIERES RESETEAR)
-- TRUNCATE TABLE Evaluaciones, MatricesEvaluacion, Postulaciones, Documentos, Candidatos, Usuarios, Cargos, PartidosPoliticos RESTART IDENTITY CASCADE;

-- ------------------------------------------------
-- PARTIDOS POLITICOS (20)
-- ------------------------------------------------
INSERT INTO PartidosPoliticos (nombre_partido, sigla, descripcion)
SELECT
  'Partido Test ' || gs,
  'PT' || gs,
  'Partido político de prueba #' || gs
FROM generate_series(1,20) gs
ON CONFLICT DO NOTHING;

-- ------------------------------------------------
-- CARGOS (20)
-- ------------------------------------------------
INSERT INTO Cargos (nombre_cargo, descripcion_cargo, nivel_jerarquico, ambito, region, ministerio_servicio, estado_cargo)
SELECT
  'Cargo Test ' || gs,
  'Descripción cargo #' || gs,
  CASE WHEN gs % 3 = 0 THEN 'Ministro'
       WHEN gs % 3 = 1 THEN 'Subsecretario'
       ELSE 'Seremi' END,
  CASE WHEN gs % 2 = 0 THEN 'Nacional' ELSE 'Regional' END,
  CASE WHEN gs % 2 = 0 THEN NULL ELSE 'Región ' || (gs % 16 + 1) END,
  'Ministerio Test ' || (gs % 5 + 1),
  'Por Definir'
FROM generate_series(1,20) gs;

-- ------------------------------------------------
-- USUARIOS (20)
-- ------------------------------------------------
INSERT INTO Usuarios (nombre_completo, email, rol, id_partido)
SELECT
  'Usuario Prueba ' || gs,
  'usuario' || gs || '@test.cl',
  CASE WHEN gs = 1 THEN 'Administrador'
       WHEN gs % 5 = 0 THEN 'Sistema_IA'
       ELSE 'Personero_Test' END,
  (SELECT id_partido FROM PartidosPoliticos ORDER BY random() LIMIT 1)
FROM generate_series(1,20) gs
ON CONFLICT (email) DO NOTHING;

-- ------------------------------------------------
-- CANDIDATOS (20)
-- ------------------------------------------------
INSERT INTO Candidatos (rut, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, contacto_email, contacto_telefono, id_partido, estado_general)
SELECT
  (10000000 + gs)::text || '-' || (gs % 9 + 1),
  'Nombre' || gs,
  'ApellidoP' || gs,
  'ApellidoM' || gs,
  DATE '1970-01-01' + (gs * 400),
  'candidato' || gs || '@mail.cl',
  '+5690000' || LPAD(gs::text,4,'0'),
  (SELECT id_partido FROM PartidosPoliticos ORDER BY random() LIMIT 1),
  'En Revisión'
FROM generate_series(1,20) gs
ON CONFLICT (rut) DO NOTHING;

-- ------------------------------------------------
-- DOCUMENTOS (20)
-- ------------------------------------------------
INSERT INTO Documentos (id_candidato, tipo_documento, nombre_archivo_original, texto_completo)
SELECT
  c.id_candidato,
  'CV',
  'cv_test_' || c.id_candidato || '.pdf',
  'Texto de CV de prueba para el candidato ' || c.id_candidato || '. Experiencia, formación y gestión pública.'
FROM (
  SELECT id_candidato FROM Candidatos ORDER BY id_candidato LIMIT 20
) c;

-- ------------------------------------------------
-- POSTULACIONES (20)
-- ------------------------------------------------
INSERT INTO Postulaciones (id_candidato, id_cargo, postulacion_principal, estado_postulacion)
SELECT
  (SELECT id_candidato FROM Candidatos ORDER BY random() LIMIT 1),
  (SELECT id_cargo FROM Cargos ORDER BY random() LIMIT 1),
  CASE WHEN gs % 2 = 0 THEN TRUE ELSE FALSE END,
  'Enviada'
FROM generate_series(1,20) gs;

-- ------------------------------------------------
-- MATRICES DE EVALUACION (20)
-- ------------------------------------------------
INSERT INTO MatricesEvaluacion (id_cargo, nombre_criterio, ponderacion, palabras_clave_busqueda)
SELECT
  (SELECT id_cargo FROM Cargos ORDER BY random() LIMIT 1),
  'Criterio Test ' || gs,
  ROUND((random())::numeric, 2),
  'experiencia, gestión, liderazgo, política'
FROM generate_series(1,20) gs;

-- ------------------------------------------------
-- EVALUACIONES (20)
-- ------------------------------------------------
INSERT INTO Evaluaciones (id_postulacion, id_usuario_evaluador, tipo_evaluacion, puntaje_numerico, texto_evaluacion, datos_estructurados)
SELECT
  (SELECT id_postulacion FROM Postulaciones ORDER BY random() LIMIT 1),
  (SELECT id_usuario FROM Usuarios ORDER BY random() LIMIT 1),
  CASE WHEN gs % 2 = 0 THEN 'IA_PuntajeObjetivo' ELSE 'Humano_OpinionPolitica' END,
  ROUND((random()*100)::numeric,2),
  'Evaluación de prueba #' || gs,
  jsonb_build_object('confianza', random(), 'iteracion', gs)
FROM generate_series(1,20) gs;

-- ================================================================
-- FIN DATOS DE PRUEBA
-- ================================================================


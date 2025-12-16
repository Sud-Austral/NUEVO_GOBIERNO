-- ================================================================
-- SCRIPT DE INSERCIÓN DE DATOS DE PRUEBA (20 REGISTROS POR TABLA)
-- BASE DE DATOS: PLATAFORMA DE GESTIÓN DE CANDIDATURAS
-- SUPABASE / POSTGRESQL
-- ================================================================

-- Nota: Este script asume que las tablas ya han sido creadas con el esquema
-- proporcionado en tu consulta. Se recomienda ejecutar este script después
-- de la creación de las tablas y antes de insertar cualquier otro dato.

-- ------------------------------------------------
-- INSERCIÓN EN: partidos_politicos (20 registros)
-- ------------------------------------------------
INSERT INTO partidos_politicos (nombre_partido, sigla)
VALUES
('Partido por la Democracia', 'PPD'),
('Partido Socialista', 'PS'),
('Partido Radical', 'PRSD'),
('Partido Liberal', 'PL'),
('Partido Ecologista Verde', 'PEV'),
('Evolución Política', 'Evópoli'),
('Partido Republicano de Chile', 'R'),
('Frente Amplio', 'FA'),
('Democracia Cristiana', 'DC'),
('Partido Comunista de Chile', 'PCCh'),
('Partido Humanista', 'PH'),
('Federación Regionalista Verde Social', 'FREVS'),
('Convergencia Social', 'CS'),
('Partido Igualdad', 'PI'),
('Acción Regionalista', 'AR'),
('Nuevo Trato', 'NT')
ON CONFLICT (sigla) DO NOTHING;


-- ------------------------------------------------
-- INSERCIÓN EN: cargos (20 registros)
-- ------------------------------------------------
INSERT INTO cargos (nombre_cargo, descripcion_cargo, nivel_jerarquico, ambito, region, ministerio_servicio) VALUES
('Ministro del Interior y Seguridad Pública', 'Liderar la política interior y de seguridad del país.', 'Ministro', 'Nacional', NULL, 'Ministerio del Interior y Seguridad Pública'),
('Ministro de Hacienda', 'Dirigir la política económica y financiera del Estado.', 'Ministro', 'Nacional', NULL, 'Ministerio de Hacienda'),
('Ministro de Defensa Nacional', 'Ejercer la conducción política y estratégica de las Fuerzas Armadas.', 'Ministro', 'Nacional', NULL, 'Ministerio de Defensa Nacional'),
('Ministro de Relaciones Exteriores', 'Dirigir la política exterior del país.', 'Ministro', 'Nacional', NULL, 'Ministro de Relaciones Exteriores'),
('Ministro de Educación', 'Liderar la política educativa nacional.', 'Ministro', 'Nacional', NULL, 'Ministerio de Educación'),
('Ministro de Salud', 'Responsable de la política sanitaria y los servicios de salud.', 'Ministro', 'Nacional', NULL, 'Ministerio de Salud'),
('Subsecretario de Hacienda', 'Apoyar la gestión técnica y administrativa del Ministerio de Hacienda.', 'Subsecretario', 'Nacional', NULL, 'Ministerio de Hacienda'),
('Subsecretario de Educación', 'Colaborar en la implementación de las políticas educativas.', 'Subsecretario', 'Nacional', NULL, 'Ministerio de Educación'),
('Seremi de Obras Públicas Metropolitana', 'Supervisar proyectos de infraestructura en la Región Metropolitana.', 'Seremi', 'Regional', 'Metropolitana', 'Ministerio de Obras Públicas'),
('Seremi de Vivienda y Urbanismo Biobío', 'Gestionar políticas de vivienda en la Región del Biobío.', 'Seremi', 'Regional', 'Biobío', 'Ministerio de Vivienda y Urbanismo'),
('Seremi de Medio Ambiente Antofagasta', 'Fiscalizar y proteger el medio ambiente en la Región de Antofagasta.', 'Seremi', 'Regional', 'Antofagasta', 'Ministerio del Medio Ambiente'),
('Seremi de Economía Valparaíso', 'Fomentar el desarrollo económico y empresarial en la Región de Valparaíso.', 'Seremi', 'Regional', 'Valparaíso', 'Ministerio de Economía, Fomento y Turismo'),
('Seremi de Agricultura Los Lagos', 'Promover y desarrollar el sector agrícola y ganadero en la Región de Los Lagos.', 'Seremi', 'Regional', 'Los Lagos', 'Ministerio de Agricultura'),
('Seremi de Culturas Arica y Parinacota', 'Impulsar el desarrollo cultural en la Región de Arica y Parinacota.', 'Seremi', 'Regional', 'Arica y Parinacota', 'Ministerio de las Culturas, las Artes y el Patrimonio'),
('Seremi de Transportes y Telecomunicaciones Maule', 'Regular y supervisar el transporte y las telecomunicaciones.', 'Seremi', 'Regional', 'Maule', 'Ministerio de Transportes y Telecomunicaciones'),
('Seremi de la Mujer y la Equidad de Género Coquimbo', 'Promover la igualdad de género y los derechos de las mujeres.', 'Seremi', 'Regional', 'Coquimbo', 'Ministerio de la Mujer y la Equidad de Género'),
('Seremi de Trabajo y Previsión Social Ñuble', 'Fiscalizar el cumplimiento de la normativa laboral.', 'Seremi', 'Regional', 'Ñuble', 'Ministerio del Trabajo y Previsión Social'),
('Seremi de Deportes Los Ríos', 'Fomentar la práctica deportiva y el desarrollo de la actividad física.', 'Seremi', 'Regional', 'Los Ríos', 'Ministerio del Deporte'),
('Seremi de Ciencia, Tecnología, Conocimiento e Innovación Magallanes', 'Impulsar el desarrollo científico y tecnológico en la región.', 'Seremi', 'Regional', 'Magallanes y de la Antártica Chilena', 'Ministerio de Ciencia, Tecnología, Conocimiento e Innovación'),
('Seremi de Justicia y Derechos Humanos Tarapacá', 'Asegurar el acceso a la justicia y la defensa de los derechos humanos.', 'Seremi', 'Regional', 'Tarapacá', 'Ministerio de Justicia y Derechos Humanos');

-- ------------------------------------------------
-- INSERCIÓN EN: usuarios (20 registros)
-- ------------------------------------------------
INSERT INTO usuarios (nombre_completo, email, rol, id_partido) VALUES
('Administrador Principal', 'admin.principal@gobierno.cl', 'administrador', NULL),
('Sistema de Notificaciones', 'notificaciones@gobierno.cl', 'sistema_notificaciones', NULL),
('Evaluador Senior RRHH', 'evaluador.rrhh@gobierno.cl', 'evaluador', NULL),
('Coordinador de Cargos', 'coordinador.cargos@gobierno.cl', 'coordinador', NULL),
('Personero PPD', 'personero.ppd@ppd.cl', 'personero_ppd', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PPD')),
('Personero PS', 'personero.ps@ps.cl', 'personero_ps', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PS')),
('Personero PRSD', 'personero.prsd@prsd.cl', 'personero_prsd', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PRSD')),
('Personero PL', 'personero.pl@pl.cl', 'personero_pl', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PL')),
('Personero PEV', 'personero.pev@pev.cl', 'personero_pev', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PEV')),
('Personero Evópoli', 'personero.evopoli@evopoli.cl', 'personero_evopoli', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'Evópoli')),
('Personero Republicanos', 'personero.republicanos@rep.cl', 'personero_republicanos', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'R')),
('Personero FA', 'personero.fa@frenteamplio.cl', 'personero_fa', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'FA')),
('Personero DC', 'personero.dc@dc.cl', 'personero_dc', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'DC')),
('Personero PCCh', 'personero.pcch@pcch.cl', 'personero_pcch', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PCCh')),
('Personero PH', 'personero.ph@ph.cl', 'personero_ph', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PH')),
('Personero FREVS', 'personero.frevs@frevs.cl', 'personero_frevs', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'FREVS')),
('Personero CS', 'personero.cs@cs.cl', 'personero_cs', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'CS')),
('Personero Igualdad', 'personero.pi@pi.cl', 'personero_pi', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PI')),
('Personero AR', 'personero.ar@ar.cl', 'personero_ar', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'AR')),
('Personero NT', 'personero.nt@nt.cl', 'personero_nt', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'NT'));

-- ------------------------------------------------
-- INSERCIÓN EN: candidatos (20 registros)
-- ------------------------------------------------
INSERT INTO candidatos (rut, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, contacto_email, contacto_telefono, id_partido) VALUES
('14.444.444-4', 'Sofía', 'Morales', 'Alvarez', '1980-05-22', 'sofia.m@email.com', '+56987654321', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PPD')),
('15.555.555-5', 'Diego', 'Silva', 'Soto', '1975-11-10', 'diego.s@email.com', '+56998765432', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PS')),
('16.666.666-6', 'Catalina', 'Fuentes', 'Jara', '1988-02-28', 'catalina.f@email.com', '+56987654322', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PRSD')),
('17.777.777-7', 'Javier', 'López', 'Pereira', '1990-07-15', 'javier.l@email.com', '+56998765433', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PL')),
('18.888.888-8', 'Valentina', 'Torres', 'Castro', '1982-09-03', 'valentina.t@email.com', '+56987654323', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PEV')),
('19.999.999-9', 'Matías', 'Vargas', 'Rojas', '1978-12-20', 'matias.v@email.com', '+56998765434', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'Evópoli')),
('20.000.000-0', 'Isidora', 'Pérez', 'Morales', '1985-04-01', 'isidora.p@email.com', '+56987654324', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'R')),
('21.111.111-1', 'Benjamín', 'Espinoza', 'Gutiérrez', '1992-06-18', 'benjamin.e@email.com', '+56998765435', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'FA')),
('22.222.222-2', 'Emilia', 'Ramírez', 'Herrera', '1983-08-25', 'emilia.r@email.com', '+56987654325', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'DC')),
('23.333.333-3', 'Sebastián', 'Díaz', 'Soto', '1976-01-30', 'sebastian.d@email.com', '+56998765436', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PCCh')),
('24.444.444-4', 'Martina', 'Fernández', 'Lira', '1991-10-12', 'martina.f@email.com', '+56987654326', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PH')),
('25.555.555-5', 'Vicente', 'Mendoza', 'Pino', '1987-03-05', 'vicente.m@email.com', '+56998765437', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'FREVS')),
('26.666.666-6', 'Antonella', 'Valdés', 'Zúñiga', '1989-07-21', 'antonella.v@email.com', '+56987654327', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'CS')),
('27.777.777-7', 'Tomás', 'Bravo', 'Cortés', '1981-11-14', 'tomas.b@email.com', '+56998765438', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PI')),
('28.888.888-8', 'Delfina', 'Cárdenas', 'Aguirre', '1993-02-09', 'delfina.c@email.com', '+56987654328', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'AR')),
('29.999.999-9', 'Joaquín', 'Gómez', 'Baeza', '1984-05-17', 'joaquin.g@email.com', '+56998765439', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'NT')),
('30.000.000-1', 'Gabriela', 'Sáez', 'Cisternas', '1979-09-26', 'gabriela.s@email.com', '+56987654329', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PPD')),
('31.111.111-2', 'Facundo', 'Leiva', 'Oyarzún', '1994-12-03', 'facundo.l@email.com', '+56998765440', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PS')),
('32.222.222-3', 'Renata', 'Vera', 'Riquelme', '1986-04-11', 'renata.v@email.com', '+56987654330', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PRSD')),
('33.333.333-4', 'Ignacio', 'Miranda', 'Fuenzalida', '1990-08-19', 'ignacio.m@email.com', '+56998765441', (SELECT id_partido FROM partidos_politicos WHERE sigla = 'PL'));

-- ------------------------------------------------
-- INSERCIÓN EN: documentos (20 registros)
-- ------------------------------------------------
INSERT INTO documentos (
    id_candidato,
    tipo_documento,
    nombre_archivo_original,
    texto_completo
)
SELECT
    c.id_candidato,
    d.tipo_documento,
    d.nombre_archivo_original,
    d.texto_completo
FROM (
    VALUES
    ('14.444.444-4', 'CV', 'cv_sofia_morales.pdf',
     'Abogada con 15 años de experiencia en derecho público y administrativo. Especialista en políticas sociales.'),

    ('14.444.444-4', 'Carta de Motivación', 'carta_sofia_morales.pdf',
     'Mi compromiso con la justicia social y mi experiencia me hacen ideal para un rol en el Ministerio de Desarrollo Social.'),

    ('15.555.555-5', 'CV', 'cv_diego_silva.pdf',
     'Ingeniero civil con mención en estructuras y MBA. Amplia experiencia en gestión de proyectos de infraestructura a gran escala.'),

    ('16.666.666-6', 'CV', 'cv_catalina_fuentes.pdf',
     'Médica cirujana, especialista en salud pública con foco en políticas de prevención y promoción.'),

    ('16.666.666-6', 'Certificado de Título', 'titulo_catalina_fuentes.pdf',
     'Universidad de Chile, Facultad de Medicina.')
) AS d(rut, tipo_documento, nombre_archivo_original, texto_completo)
JOIN candidatos c ON c.rut = d.rut;

-- ------------------------------------------------
-- INSERCIÓN EN: postulaciones (20 registros)
-- ------------------------------------------------
INSERT INTO postulaciones (
    id_candidato,
    id_cargo,
    postulacion_principal,
    estado_postulacion
)
SELECT
    c.id_candidato,
    ca.id_cargo,
    p.postulacion_principal,
    p.estado_postulacion
FROM (
    VALUES
    ('14.444.444-4', 'Ministra del Interior y Seguridad Pública', true, 'en revisión'),
    ('15.555.555-5', 'Ministro de Obras Públicas', true, 'aprobada'),
    ('16.666.666-6', 'Ministra de Salud', true, 'en entrevista'),
    ('17.777.777-7', 'Subsecretario de Educación', true, 'enviada'),
    ('18.888.888-8', 'Seremi de Medio Ambiente Antofagasta', true, 'seleccionado'),
    ('19.999.999-9', 'Subsecretario de Hacienda', true, 'en revisión'),
    ('20.000.000-0', 'Seremi de Culturas Arica y Parinacota', true, 'enviada'),
    ('21.111.111-1', 'Seremi de Justicia y Derechos Humanos Tarapacá', true, 'en entrevista'),
    ('22.222.222-2', 'Seremi de Agricultura Los Lagos', true, 'aprobada'),
    ('23.333.333-3', 'Ministro de Desarrollo Social y Familia', true, 'enviada'),

    ('14.444.444-4', 'Seremi de la Mujer y la Equidad de Género Coquimbo', false, 'enviada'),
    ('15.555.555-5', 'Ministro de Vivienda y Urbanismo', false, 'en revisión'),
    ('16.666.666-6', 'Seremi de Salud Metropolitana', false, 'rechazada'),
    ('17.777.777-7', 'Subsecretario de las Culturas y las Artes', false, 'enviada'),
    ('18.888.888-8', 'Ministra del Medio Ambiente', false, 'en entrevista'),
    ('19.999.999-9', 'Seremi de Economía Valparaíso', false, 'aprobada'),
    ('20.000.000-0', 'Seremi de Educación Valparaíso', false, 'enviada'),
    ('21.111.111-1', 'Ministro de Justicia y Derechos Humanos', false, 'en revisión'),
    ('22.222.222-2', 'Seremi de Obras Públicas Biobío', false, 'enviada'),
    ('23.333.333-3', 'Ministro de Educación', false, 'en entrevista')
) AS p(rut, nombre_cargo, postulacion_principal, estado_postulacion)
JOIN candidatos c ON c.rut = p.rut
JOIN cargos ca ON ca.nombre_cargo = p.nombre_cargo;

-- ------------------------------------------------
-- INSERCIÓN EN: matrices_evaluacion (20 registros)
-- ------------------------------------------------
INSERT INTO matrices_evaluacion (
    id_cargo,
    nombre_criterio,
    ponderacion,
    palabras_clave_busqueda
)
SELECT
    ca.id_cargo,
    m.nombre_criterio,
    m.ponderacion,
    m.palabras_clave_busqueda
FROM (
    VALUES
    ('Ministra de Salud', 'Experiencia en gestión de sistemas de salud', 0.40,
     'hospital, red de salud, gestión clínica, salud pública'),
    ('Ministra de Salud', 'Formación en salud o ciencias afines', 0.30,
     'médico, cirujano, enfermera, salud pública'),
    ('Ministra de Salud', 'Liderazgo en crisis sanitarias', 0.30,
     'pandemia, emergencia, coordinación, crisis'),

    ('Ministro de Educación', 'Experiencia en reformas educativas', 0.40,
     'currículum, evaluación, docencia, sistema educativo'),
    ('Ministro de Educación', 'Formación en pedagogía o educación', 0.30,
     'pedagogía, educación, magíster en educación'),
    ('Ministro de Educación', 'Capacidad de negociación con gremios', 0.30,
     'Colegio de Profesores, negociación, diálogo social'),

    ('Seremi de Medio Ambiente Antofagasta', 'Conocimiento en legislación ambiental', 0.30,
     'SEIA, RCA, ley ambiental'),
    ('Seremi de Medio Ambiente Antofagasta', 'Experiencia en minería sostenible', 0.40,
     'minería, relaves, consumo de agua'),
    ('Seremi de Medio Ambiente Antofagasta', 'Diálogo territorial', 0.30,
     'comunidad, empresas, servicios públicos')
) AS m(nombre_cargo, nombre_criterio, ponderacion, palabras_clave_busqueda)
JOIN cargos ca ON ca.nombre_cargo = m.nombre_cargo;


INSERT INTO evaluaciones (
    id_postulacion,
    id_usuario_evaluador,
    tipo_evaluacion,
    puntaje_numerico,
    texto_evaluacion,
    datos_estructurados
)
SELECT
    p.id_postulacion,
    u.id_usuario,
    'Evaluación Inicial' AS tipo_evaluacion,
    7.0 AS puntaje_numerico,
    'Evaluación generada automáticamente para postulación existente.' AS texto_evaluacion,
    jsonb_build_object(
        'criterio_general', 7,
        'observaciones', 'seed inicial'
    ) AS datos_estructurados
FROM postulaciones p
JOIN LATERAL (
    SELECT id_usuario
    FROM usuarios
    WHERE rol = 'administrador'
    ORDER BY id_usuario
    LIMIT 1
) u ON true
LEFT JOIN evaluaciones e
  ON e.id_postulacion = p.id_postulacion
WHERE e.id_postulacion IS NULL;


-- ================================================================
-- FIN DEL SCRIPT DE INSERCIÓN
-- ================================================================
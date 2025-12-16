-- ================================================================
-- BASE DE DATOS: PLATAFORMA DE GESTIÓN DE CANDIDATURAS
-- SUPABASE / POSTGRESQL
-- ================================================================

-- ------------------------------------------------
-- TABLA: partidos_politicos
-- ------------------------------------------------
CREATE TABLE partidos_politicos (
    id_partido SERIAL PRIMARY KEY,
    nombre_partido TEXT NOT NULL UNIQUE,
    sigla TEXT NOT NULL UNIQUE,
    descripcion TEXT
);

INSERT INTO partidos_politicos (nombre_partido, sigla, descripcion) VALUES
('Partido Republicano', 'REP', 'Partido de derecha conservadora.'),
('Renovación Nacional', 'RN', 'Partido de centro-derecha liberal.'),
('Unión Demócrata Independiente', 'UDI', 'Partido de derecha conservadora.'),
('Partido Social Cristiano', 'PSC', 'Partido demócrata cristiano.'),
('Partido Demócrata', 'PD', 'Partido de centro-izquierda.');

-- ------------------------------------------------
-- TABLA: cargos
-- ------------------------------------------------
CREATE TABLE cargos (
    id_cargo SERIAL PRIMARY KEY,
    nombre_cargo TEXT NOT NULL,
    descripcion_cargo TEXT,
    nivel_jerarquico TEXT NOT NULL,
    ambito TEXT NOT NULL,
    region TEXT,
    ministerio_servicio TEXT,
    estado_cargo TEXT NOT NULL DEFAULT 'por definir'
);

INSERT INTO cargos (nombre_cargo, descripcion_cargo, nivel_jerarquico, ambito, region, ministerio_servicio) VALUES
('Ministro de Energía', 'Liderar la política energética nacional.', 'Ministro', 'Nacional', NULL, 'Ministerio de Energía'),
('Subsecretario de Energía', 'Apoyar al Ministro en la gestión técnica.', 'Subsecretario', 'Nacional', NULL, 'Ministerio de Energía'),
('Seremi de Salud Metropolitana', 'Representar al Ministerio de Salud en la RM.', 'Seremi', 'Regional', 'Metropolitana', 'Ministerio de Salud'),
('Seremi de Educación Valparaíso', 'Representar al Ministerio de Educación.', 'Seremi', 'Regional', 'Valparaíso', 'Ministerio de Educación');

-- ------------------------------------------------
-- TABLA: usuarios
-- ------------------------------------------------
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre_completo TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    rol TEXT NOT NULL,
    id_partido INTEGER REFERENCES partidos_politicos(id_partido) ON DELETE SET NULL
);

INSERT INTO usuarios (nombre_completo, email, rol, id_partido) VALUES
('Admin Sistema', 'admin@gobierno.cl', 'administrador', NULL),
('Ana Rojas Leiva', 'ana.r@rn.cl', 'personero_rn',
 (SELECT id_partido FROM partidos_politicos WHERE sigla = 'RN')),
('Carlos Soto Díaz', 'carlos.s@udi.cl', 'personero_udi',
 (SELECT id_partido FROM partidos_politicos WHERE sigla = 'UDI')),
('Sistema de Evaluación IA', 'sistema.ia@gobierno.cl', 'sistema_ia', NULL);

-- ------------------------------------------------
-- TABLA: candidatos
-- ------------------------------------------------
CREATE TABLE candidatos (
    id_candidato SERIAL PRIMARY KEY,
    rut TEXT NOT NULL UNIQUE,
    nombres TEXT NOT NULL,
    apellido_paterno TEXT NOT NULL,
    apellido_materno TEXT,
    fecha_nacimiento DATE,
    contacto_email TEXT,
    contacto_telefono TEXT,
    id_partido INTEGER NOT NULL REFERENCES partidos_politicos(id_partido),
    estado_general TEXT NOT NULL DEFAULT 'en revisión'
);

INSERT INTO candidatos (rut, nombres, apellido_paterno, apellido_materno, id_partido, contacto_email) VALUES
('11.111.111-1', 'Pedro', 'González', 'López',
 (SELECT id_partido FROM partidos_politicos WHERE sigla = 'REP'),
 'p.gonzalez@email.com'),
('22.222.222-2', 'María', 'Soto', 'Fernández',
 (SELECT id_partido FROM partidos_politicos WHERE sigla = 'RN'),
 'm.soto@email.com'),
('33.333.333-3', 'Luis', 'Ramírez', 'Pérez',
 (SELECT id_partido FROM partidos_politicos WHERE sigla = 'UDI'),
 'l.ramirez@email.com');

-- ------------------------------------------------
-- TABLA: documentos
-- ------------------------------------------------
CREATE TABLE documentos (
    id_documento SERIAL PRIMARY KEY,
    id_candidato INTEGER NOT NULL REFERENCES candidatos(id_candidato) ON DELETE CASCADE,
    tipo_documento TEXT NOT NULL,
    nombre_archivo_original TEXT,
    url_archivo_original TEXT,
    texto_completo TEXT,
    fecha_extraccion TIMESTAMPTZ DEFAULT now()
);

INSERT INTO documentos (id_candidato, tipo_documento, nombre_archivo_original, texto_completo) VALUES
((SELECT id_candidato FROM candidatos WHERE rut = '11.111.111-1'),
 'CV', 'cv_pedro_gonzalez.pdf',
 'Ingeniero civil con 20 años de experiencia en energía y renovables.'),
((SELECT id_candidato FROM candidatos WHERE rut = '22.222.222-2'),
 'CV', 'cv_maria_soto.pdf',
 'Abogada especialista en derecho administrativo y regulación energética.'),
((SELECT id_candidato FROM candidatos WHERE rut = '33.333.333-3'),
 'CV', 'cv_luis_ramirez.pdf',
 'Médico cirujano con experiencia en gestión hospitalaria.');

-- ------------------------------------------------
-- TABLA: postulaciones
-- ------------------------------------------------
CREATE TABLE postulaciones (
    id_postulacion SERIAL PRIMARY KEY,
    id_candidato INTEGER NOT NULL REFERENCES candidatos(id_candidato) ON DELETE CASCADE,
    id_cargo INTEGER NOT NULL REFERENCES cargos(id_cargo) ON DELETE CASCADE,
    fecha_postulacion TIMESTAMPTZ DEFAULT now(),
    postulacion_principal BOOLEAN DEFAULT false,
    estado_postulacion TEXT NOT NULL DEFAULT 'enviada'
);

INSERT INTO postulaciones (id_candidato, id_cargo, postulacion_principal) VALUES
((SELECT id_candidato FROM candidatos WHERE rut = '11.111.111-1'),
 (SELECT id_cargo FROM cargos WHERE nombre_cargo = 'Ministro de Energía'), true),
((SELECT id_candidato FROM candidatos WHERE rut = '11.111.111-1'),
 (SELECT id_cargo FROM cargos WHERE nombre_cargo = 'Subsecretario de Energía'), false),
((SELECT id_candidato FROM candidatos WHERE rut = '22.222.222-2'),
 (SELECT id_cargo FROM cargos WHERE nombre_cargo = 'Subsecretario de Energía'), true),
((SELECT id_candidato FROM candidatos WHERE rut = '33.333.333-3'),
 (SELECT id_cargo FROM cargos WHERE nombre_cargo = 'Seremi de Salud Metropolitana'), true);

-- ------------------------------------------------
-- TABLA: matrices_evaluacion
-- ------------------------------------------------
CREATE TABLE matrices_evaluacion (
    id_matriz SERIAL PRIMARY KEY,
    id_cargo INTEGER NOT NULL REFERENCES cargos(id_cargo) ON DELETE CASCADE,
    nombre_criterio TEXT NOT NULL,
    ponderacion DECIMAL(3,2) NOT NULL CHECK (ponderacion BETWEEN 0 AND 1),
    palabras_clave_busqueda TEXT
);

INSERT INTO matrices_evaluacion (id_cargo, nombre_criterio, ponderacion, palabras_clave_busqueda) VALUES
((SELECT id_cargo FROM cargos WHERE nombre_cargo = 'Subsecretario de Energía'),
 'Experiencia sector energético', 0.5,
 'energía, SEC, CNE, renovable'),
((SELECT id_cargo FROM cargos WHERE nombre_cargo = 'Subsecretario de Energía'),
 'Formación académica', 0.2,
 'ingeniería, magíster, derecho'),
((SELECT id_cargo FROM cargos WHERE nombre_cargo = 'Subsecretario de Energía'),
 'Gestión pública', 0.3,
 'ministerio, superintendencia');

-- ------------------------------------------------
-- TABLA: evaluaciones
-- ------------------------------------------------
CREATE TABLE evaluaciones (
    id_evaluacion SERIAL PRIMARY KEY,
    id_postulacion INTEGER NOT NULL REFERENCES postulaciones(id_postulacion) ON DELETE CASCADE,
    id_usuario_evaluador INTEGER NOT NULL REFERENCES usuarios(id_usuario),
    fecha_evaluacion TIMESTAMPTZ DEFAULT now(),
    tipo_evaluacion TEXT NOT NULL,
    puntaje_numerico DECIMAL(5,2),
    texto_evaluacion TEXT,
    datos_estructurados JSONB
);

-- ================================================================
-- FIN DEL SCRIPT
-- ================================================================

-- =================================================================
-- SCRIPT SQL PARA LA CREACIÓN Y POBLAMIENTO DE LA BASE DE DATOS
-- PLATAFORMA DE GESTIÓN DE CANDIDATURAS GUBERNAMENTALES
-- DISEÑADO PARA SUPABASE (POSTGRESQL)
-- =================================================================

-- -----------------------------------------------------------------
-- TABLA: PartidosPoliticos
-- Almacena la información de los partidos políticos que proponen candidatos.
-- -----------------------------------------------------------------
CREATE TABLE PartidosPoliticos (
    id_partido SERIAL PRIMARY KEY,
    nombre_partido TEXT NOT NULL UNIQUE,
    sigla TEXT NOT NULL UNIQUE,
    descripcion TEXT
);

-- Inserción de datos de ejemplo para partidos políticos chilenos.
INSERT INTO PartidosPoliticos (nombre_partido, sigla, descripcion) VALUES
('Partido Republicano', 'REP', 'Partido de derecha conservadora.'),
('Renovación Nacional', 'RN', 'Partido de centro-derecha liberal.'),
('Unión Demócrata Independiente', 'UDI', 'Partido de derecha conservadora.'),
('Partido Social Cristiano', 'PSC', 'Partido demócrata cristiano.'),
('Partido Demócrata', 'PD', 'Partido de centro-izquierda.');

-- -----------------------------------------------------------------
-- TABLA: Cargos
-- Describe cada uno de los puestos de trabajo que deben ser llenados.
-- -----------------------------------------------------------------
CREATE TABLE Cargos (
    id_cargo SERIAL PRIMARY KEY,
    nombre_cargo TEXT NOT NULL,
    descripcion_cargo TEXT,
    nivel_jerarquico TEXT NOT NULL, -- Ej: 'Ministro', 'Subsecretario', 'Seremi'
    ambito TEXT NOT NULL, -- Ej: 'Nacional', 'Regional'
    region TEXT, -- Si es regional, la región a la que corresponde. Es NULL si es nacional.
    ministerio_servicio TEXT,
    estado_cargo TEXT NOT NULL DEFAULT 'Por Definir' -- Ej: 'Por Definir', 'Asignado'
);

-- Inserción de datos de ejemplo para cargos.
INSERT INTO Cargos (nombre_cargo, descripcion_cargo, nivel_jerarquico, ambito, region, ministerio_servicio) VALUES
('Ministro de Energía', 'Liderar la política energética nacional.', 'Ministro', 'Nacional', NULL, 'Ministerio de Energía'),
('Subsecretario de Energía', 'Apoyar al Ministro en la gestión técnica.', 'Subsecretario', 'Nacional', NULL, 'Ministerio de Energía'),
('Seremi de Salud Metropolitana', 'Representar al Ministerio de Salud en la Región Metropolitana.', 'Seremi', 'Regional', 'Metropolitana', 'Ministerio de Salud'),
('Seremi de Educación Valparaíso', 'Representar al Ministerio de Educación en la Región de Valparaíso.', 'Seremi', 'Regional', 'Valparaíso', 'Ministerio de Educación');

-- -----------------------------------------------------------------
-- TABLA: Usuarios
-- Identifica a todas las personas que interactúan con el sistema.
-- -----------------------------------------------------------------
CREATE TABLE Usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre_completo TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    rol TEXT NOT NULL, -- Ej: 'Administrador', 'Personero_RN', 'Sistema_IA'
    id_partido INTEGER REFERENCES PartidosPoliticos(id_partido) ON DELETE SET NULL -- Un usuario puede no estar asociado a un partido (ej: admin, IA)
);

-- Inserción de datos de ejemplo para usuarios.
INSERT INTO Usuarios (nombre_completo, email, rol, id_partido) VALUES
('Admin Sistema', 'admin@gobierno.cl', 'Administrador', NULL),
('Ana Rojas Leiva', 'ana.r@rn.cl', 'Personero_RN', (SELECT id_partido FROM PartidosPoliticos WHERE sigla = 'RN')),
('Carlos Soto Díaz', 'carlos.s@udi.cl', 'Personero_UDI', (SELECT id_partido FROM PartidosPoliticos WHERE sigla = 'UDI')),
('Sistema de Evaluación IA', 'sistema.ia@gobierno.cl', 'Sistema_IA', NULL);

-- -----------------------------------------------------------------
-- TABLA: Candidatos
-- Contiene el perfil detallado de cada persona propuesta para un cargo.
-- -----------------------------------------------------------------
CREATE TABLE Candidatos (
    id_candidato SERIAL PRIMARY KEY,
    rut TEXT NOT NULL UNIQUE,
    nombres TEXT NOT NULL,
    apellido_paterno TEXT NOT NULL,
    apellido_materno TEXT,
    fecha_nacimiento DATE,
    contacto_email TEXT,
    contacto_telefono TEXT,
    id_partido INTEGER NOT NULL REFERENCES PartidosPoliticos(id_partido),
    estado_general TEXT NOT NULL DEFAULT 'En Revisión' -- Ej: 'En Revisión', 'Preseleccionado', 'Descartado'
);

-- Inserción de datos de ejemplo para candidatos.
INSERT INTO Candidatos (rut, nombres, apellido_paterno, apellido_materno, id_partido, contacto_email) VALUES
('11.111.111-1', 'Pedro', 'González', 'López', (SELECT id_partido FROM PartidosPoliticos WHERE sigla = 'REP'), 'p.gonzalez@email.com'),
('22.222.222-2', 'María', 'Soto', 'Fernández', (SELECT id_partido FROM PartidosPoliticos WHERE sigla = 'RN'), 'm.soto@email.com'),
('33.333.333-3', 'Luis', 'Ramírez', 'Pérez', (SELECT id_partido FROM PartidosPoliticos WHERE sigla = 'UDI'), 'l.ramirez@email.com');

-- -----------------------------------------------------------------
-- TABLA: Documentos
-- Almacena el contenido de los CVs y otros documentos de los candidatos.
-- -----------------------------------------------------------------
CREATE TABLE Documentos (
    id_documento SERIAL PRIMARY KEY,
    id_candidato INTEGER NOT NULL REFERENCES Candidatos(id_candidato) ON DELETE CASCADE,
    tipo_documento TEXT NOT NULL, -- Ej: 'CV', 'Ficha de Antecedentes'
    nombre_archivo_original TEXT,
    url_archivo_original TEXT, -- URL al archivo en un servicio de almacenamiento (ej: S3)
    texto_completo TEXT, -- Contenido extraído del archivo, para análisis de IA.
    fecha_extraccion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserción de datos de ejemplo para documentos (CVs).
INSERT INTO Documentos (id_candidato, tipo_documento, nombre_archivo_original, texto_completo) VALUES
((SELECT id_candidato FROM Candidatos WHERE rut = '11.111.111-1'), 'CV', 'cv_pedro_gonzalez.pdf', 'Pedro González es ingeniero civil con 20 años de experiencia en el sector energético. Se ha desempeñado como Gerente de Proyectos en Enel Chile y como Director de la Asociación de Energías Renovables. Tiene un Magíster en Economía de la Universidad de Chile y ha liderado la construcción de parques eólicos y solares a nivel nacional.'),
((SELECT id_candidato FROM Candidatos WHERE rut = '22.222.222-2'), 'CV', 'cv_maria_soto.pdf', 'María Soto es abogada con especialización en derecho administrativo y regulación. Trabajó por 10 años en la Superintendencia de Electricidad y Combustibles (SEC), donde fue jefa de la división legal. Posteriormente, se desempeñó como consultora independiente para empresas del sector energético en temas de cumplimiento normativo. Es candidata a doctor en Derecho Público.'),
((SELECT id_candidato FROM Candidatos WHERE rut = '33.333.333-3'), 'CV', 'cv_luis_ramirez.pdf', 'Luis Ramírez es médico cirujano de la Universidad de Chile, con un posgrado en Gestión de Servicios de Salud. Durante 15 años trabajó en el Hospital Clínico de la Universidad de Chile, donde llegó a ser Subdirector Médico. Su experiencia se centra en la reorganización de servicios de urgencia y la implementación de tecnologías de información en salud.');

-- -----------------------------------------------------------------
-- TABLA: Postulaciones
-- Conecta a los candidatos con los cargos a los que postulan.
-- -----------------------------------------------------------------
CREATE TABLE Postulaciones (
    id_postulacion SERIAL PRIMARY KEY,
    id_candidato INTEGER NOT NULL REFERENCES Candidatos(id_candidato) ON DELETE CASCADE,
    id_cargo INTEGER NOT NULL REFERENCES Cargos(id_cargo) ON DELETE CASCADE,
    fecha_postulacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    postulacion_principal BOOLEAN DEFAULT FALSE,
    estado_postulacion TEXT NOT NULL DEFAULT 'Enviada' -- Ej: 'Enviada', 'En Evaluación', 'Preseleccionado'
);

-- Inserción de datos de ejemplo para postulaciones.
-- Pedro González postula a dos cargos en energía.
INSERT INTO Postulaciones (id_candidato, id_cargo, postulacion_principal) VALUES
((SELECT id_candidato FROM Candidatos WHERE rut = '11.111.111-1'), (SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Ministro de Energía'), TRUE),
((SELECT id_candidato FROM Candidatos WHERE rut = '11.111.111-1'), (SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Subsecretario de Energía'), FALSE);

-- María Soto postula a Subsecretario de Energía.
INSERT INTO Postulaciones (id_candidato, id_cargo, postulacion_principal) VALUES
((SELECT id_candidato FROM Candidatos WHERE rut = '22.222.222-2'), (SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Subsecretario de Energía'), TRUE);

-- Luis Ramírez postula a Seremi de Salud Metropolitana.
INSERT INTO Postulaciones (id_candidato, id_cargo, postulacion_principal) VALUES
((SELECT id_candidato FROM Candidatos WHERE rut = '33.333.333-3'), (SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Seremi de Salud Metropolitana'), TRUE);

-- -----------------------------------------------------------------
-- TABLA: MatricesEvaluacion
-- Define los criterios y parámetros para la evaluación de un cargo específico.
-- -----------------------------------------------------------------
CREATE TABLE MatricesEvaluacion (
    id_matriz SERIAL PRIMARY KEY,
    id_cargo INTEGER NOT NULL REFERENCES Cargos(id_cargo) ON DELETE CASCADE,
    nombre_criterio TEXT NOT NULL,
    ponderacion DECIMAL(3, 2) NOT NULL CHECK (ponderacion >= 0 AND ponderacion <= 1), -- Ponderación entre 0.00 y 1.00
    palabras_clave_busqueda TEXT -- Palabras clave para el modelo de IA.
);

-- Inserción de datos de ejemplo: Matriz para el cargo de Subsecretario de Energía.
INSERT INTO MatricesEvaluacion (id_cargo, nombre_criterio, ponderacion, palabras_clave_busqueda) VALUES
((SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Subsecretario de Energía'), 'Experiencia Sector Energético', 0.5, 'energía, eléctrica, SEC, CNE, Enel, generadora, renovable'),
((SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Subsecretario de Energía'), 'Formación Académica Relevantes', 0.2, 'ingeniería, magíster, economía, derecho, administración'),
((SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Subsecretario de Energía'), 'Experiencia en Gestión Pública', 0.3, 'servicio público, ministerio, superintendencia, dirección, jefatura');

-- -----------------------------------------------------------------
-- TABLA: Evaluaciones
-- Almacena los resultados de las evaluaciones, tanto de IA como de personas.
-- -----------------------------------------------------------------
CREATE TABLE Evaluaciones (
    id_evaluacion SERIAL PRIMARY KEY,
    id_postulacion INTEGER NOT NULL REFERENCES Postulaciones(id_postulacion) ON DELETE CASCADE,
    id_usuario_evaluador INTEGER NOT NULL REFERENCES Usuarios(id_usuario),
    fecha_evaluacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    tipo_evaluacion TEXT NOT NULL, -- Ej: 'IA_PuntajeObjetivo', 'Humano_OpinionPolitica'
    puntaje_numerico DECIMAL(5, 2), -- Puntaje numérico, puede ser nulo.
    texto_evaluacion TEXT, -- Comentarios y justificaciones.
    datos_estructurados JSONB -- Datos estructurados adicionales en formato JSON.
);

-- Inserción de datos de ejemplo: Evaluaciones para la postulación de Pedro González a Ministro de Energía.
-- 1. Evaluación del Sistema de IA.
INSERT INTO Evaluaciones (id_postulacion, id_usuario_evaluador, tipo_evaluacion, puntaje_numerico, texto_evaluacion) VALUES
(
    (SELECT id_postulacion FROM Postulaciones WHERE id_candidato = (SELECT id_candidato FROM Candidatos WHERE rut = '11.111.111-1') AND id_cargo = (SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Ministro de Energía')),
    (SELECT id_usuario FROM Usuarios WHERE rol = 'Sistema_IA'),
    'IA_PuntajeObjetivo',
    92.50,
    'Puntaje alto basado en 20 años de experiencia en el sector energético y un Magíster en Economía. Se detecta liderazgo en proyectos de energías renovables.'
);

-- 2. Evaluación del Personero de UDI.
INSERT INTO Evaluaciones (id_postulacion, id_usuario_evaluador, tipo_evaluacion, texto_evaluacion) VALUES
(
    (SELECT id_postulacion FROM Postulaciones WHERE id_candidato = (SELECT id_candidato FROM Candidatos WHERE rut = '11.111.111-1') AND id_cargo = (SELECT id_cargo FROM Cargos WHERE nombre_cargo = 'Ministro de Energía')),
    (SELECT id_usuario FROM Usuarios WHERE rol = 'Personero_UDI'),
    'Humano_OpinionPolitica',
    'El candidato tiene un perfil técnico impecable y es muy respetado en el sector privado. Sin embargo, no tenemos antecedentes sobre su afinidad o lealtad al proyecto político. Se sugiere una entrevista para evaluar su alineación estratégica.'
);

-- -----------------------------------------------------------------
-- FIN DEL SCRIPT
-- -----------------------------------------------------------------
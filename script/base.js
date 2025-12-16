
// Configuración de Supabase
const supabaseUrl = 'https://fmhmduocrjloewntpcox.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZtaG1kdW9jcmpsb2V3bnRwY294Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4OTA2NDUsImV4cCI6MjA4MTQ2NjY0NX0.NVxYT0HRLa8jhPnpy3hhyRHhESy_D51Eb-O3B4s96lw';
const supabase = window.supabase.createClient(supabaseUrl, supabaseAnonKey);

// Variables globales para las instancias de los gráficos
let governanceChartInstance = null;
let progressChartInstance = null;
let competencyRadarChartInstance = null;
let diversityPieChartInstance = null;
let agreementBarChartInstance = null;

// Variables globales para los datos
let currentUser = null;
let candidatesData = [];
let partiesData = [];
let positionsData = [];
let applicationsData = [];
let evaluationsData = [];

// --- Funciones de autenticación ---
async function login() {
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    if (!email || !password) {
        showNotification('Por favor, ingrese email y contraseña', 'error');
        return;
    }

    document.getElementById('loginSpinner').style.display = 'block';

    try {
        const { data, error } = await supabase.auth.signInWithPassword({
            email: email,
            password: password
        });

        if (error) throw error;

        currentUser = data.user;
        document.getElementById('userName').textContent = email;
        document.getElementById('loginContainer').style.display = 'none';
        document.getElementById('mainApp').style.display = 'flex';

        // Cargar datos iniciales
        await loadInitialData();

        showNotification('Inicio de sesión exitoso', 'success');
    } catch (error) {
        console.error('Error al iniciar sesión:', error);
        showNotification('Error al iniciar sesión: ' + error.message, 'error');
    } finally {
        document.getElementById('loginSpinner').style.display = 'none';
    }
}

async function logout() {
    try {
        await supabase.auth.signOut();
        currentUser = null;
        document.getElementById('loginContainer').style.display = 'flex';
        document.getElementById('mainApp').style.display = 'none';
        showNotification('Sesión cerrada correctamente', 'success');
    } catch (error) {
        console.error('Error al cerrar sesión:', error);
        showNotification('Error al cerrar sesión', 'error');
    }
}

// --- Funciones de carga de datos ---
async function loadInitialData() {
    try {
        // Cargar partidos políticos
        const { data: parties, error: partiesError } = await supabase
            .from('PartidosPoliticos')
            .select('*');

        if (partiesError) throw partiesError;
        partiesData = parties || [];

        // Actualizar selector de partidos
        const partyFilter = document.getElementById('partyFilter');
        partiesData.forEach(party => {
            const option = document.createElement('option');
            option.value = party.id_partido;
            option.textContent = party.nombre_partido;
            partyFilter.appendChild(option);
        });

        // Cargar cargos
        const { data: positions, error: positionsError } = await supabase
            .from('Cargos')
            .select('*');

        if (positionsError) throw positionsError;
        positionsData = positions || [];

        // Actualizar selector de ministerios
        const ministryFilter = document.getElementById('ministryFilter');
        const ministries = [...new Set(positionsData.map(p => p.ministerio_servicio).filter(Boolean))];
        ministries.forEach(ministry => {
            const option = document.createElement('option');
            option.value = ministry;
            option.textContent = ministry;
            ministryFilter.appendChild(option);
        });

        // Actualizar selector de regiones
        const regionFilter = document.getElementById('regionFilter');
        const regions = [...new Set(positionsData.map(p => p.region).filter(Boolean))];
        regions.forEach(region => {
            const option = document.createElement('option');
            option.value = region;
            option.textContent = region;
            regionFilter.appendChild(option);
        });

        // Cargar candidatos
        const { data: candidates, error: candidatesError } = await supabase
            .from('Candidatos')
            .select('*, PartidosPoliticos(*)');

        if (candidatesError) throw candidatesError;
        candidatesData = candidates || [];

        // Cargar postulaciones
        const { data: applications, error: applicationsError } = await supabase
            .from('Postulaciones')
            .select('*, Candidatos(*), Cargos(*)');

        if (applicationsError) throw applicationsError;
        applicationsData = applications || [];

        // Cargar evaluaciones
        const { data: evaluations, error: evaluationsError } = await supabase
            .from('Evaluaciones')
            .select('*, Postulaciones(*, Candidatos(*), Cargos(*))');

        if (evaluationsError) throw evaluationsError;
        evaluationsData = evaluations || [];

        // Actualizar dashboard
        updateDashboard();

        // Inicializar gráficos
        initializeCharts();

    } catch (error) {
        console.error('Error al cargar datos iniciales:', error);
        showNotification('Error al cargar datos: ' + error.message, 'error');
    }
}

// --- Funciones de actualización de UI ---
function updateDashboard() {
    // Actualizar KPIs
    document.getElementById('totalCandidates').textContent = candidatesData.length;

    const pendingPositions = positionsData.filter(p => p.estado_cargo === 'Por Definir').length;
    document.getElementById('pendingPositions').textContent = pendingPositions;

    const preselectedCandidates = candidatesData.filter(c => c.estado_general === 'Preseleccionado').length;
    document.getElementById('preselectedCandidates').textContent = preselectedCandidates;

    document.getElementById('partyParticipation').textContent = `${partiesData.length} / ${partiesData.length}`;
}

// --- Lógica de Pestañas y Gráficos ---
function showTab(event, tabName) {
    var i, tabcontent, navlinks;
    tabcontent = document.getElementsByClassName("tab-content");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].classList.remove("active");
    }
    navlinks = document.getElementsByClassName("nav-link");
    for (i = 0; i < navlinks.length; i++) {
        navlinks[i].classList.remove("active");
    }

    document.getElementById(tabName).classList.add("active");
    event.currentTarget.classList.add("active");

    // Inicializar o redibujar gráficos según la pestaña activa
    if (tabName === 'dashboard') {
        if (!governanceChartInstance) initializeCharts();
        else {
            governanceChartInstance.resize();
            progressChartInstance.resize();
        }
    } else if (tabName === 'candidates') {
        loadCandidates();
    } else if (tabName === 'analysis') {
        loadAnalysis();
    } else if (tabName === 'reports') {
        if (!diversityPieChartInstance) initializeReportsCharts();
        else {
            diversityPieChartInstance.resize();
            agreementBarChartInstance.resize();
        }
    }
}

function initializeCharts() {
    // GRÁFICO 1: BARRAS HORIZONTALES
    const governanceCtx = document.getElementById('governanceChart').getContext('2d');

    // Contar cargos por partido
    const partyDistribution = {};
    applicationsData.forEach(app => {
        const partyId = app.Candidatos.id_partido;
        const party = partiesData.find(p => p.id_partido === partyId);
        const partyName = party ? party.nombre_partido : 'Independiente';

        if (!partyDistribution[partyName]) {
            partyDistribution[partyName] = 0;
        }
        partyDistribution[partyName]++;
    });

    governanceChartInstance = new Chart(governanceCtx, {
        type: 'bar',
        data: {
            labels: Object.keys(partyDistribution),
            datasets: [{
                label: 'Cargos Asignados',
                data: Object.values(partyDistribution),
                backgroundColor: [
                    'rgba(255, 99, 132, 0.7)',
                    'rgba(54, 162, 235, 0.7)',
                    'rgba(255, 206, 86, 0.7)',
                    'rgba(75, 192, 192, 0.7)',
                    'rgba(153, 102, 255, 0.7)'
                ],
                borderColor: 'rgba(0, 0, 0, 0.1)',
                borderWidth: 1
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    beginAtZero: true,
                    title: { display: true, text: 'Número de Cargos' }
                }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });

    // GRÁFICO 2: BARRAS APILADAS
    const progressCtx = document.getElementById('progressChart').getContext('2d');

    // Contar cargos por nivel y estado
    const levelDistribution = {};
    positionsData.forEach(position => {
        const level = position.nivel_jerarquico;

        if (!levelDistribution[level]) {
            levelDistribution[level] = { assigned: 0, pending: 0 };
        }

        if (position.estado_cargo === 'Asignado') {
            levelDistribution[level].assigned++;
        } else {
            levelDistribution[level].pending++;
        }
    });

    progressChartInstance = new Chart(progressCtx, {
        type: 'bar',
        data: {
            labels: Object.keys(levelDistribution),
            datasets: [
                {
                    label: 'Asignados',
                    data: Object.values(levelDistribution).map(v => v.assigned),
                    backgroundColor: 'rgba(0, 85, 164, 0.7)',
                    borderColor: 'rgba(0, 85, 164, 1)',
                    borderWidth: 1
                },
                {
                    label: 'Por Asignar',
                    data: Object.values(levelDistribution).map(v => v.pending),
                    backgroundColor: 'rgba(201, 203, 207, 0.7)',
                    borderColor: 'rgba(201, 203, 207, 1)',
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: { stacked: true, },
                y: { stacked: true, beginAtZero: true }
            },
            plugins: {
                legend: { position: 'top', }
            }
        }
    });
}

function initializeAnalysisCharts() {
    const competencyCtx = document.getElementById('competencyRadarChart').getContext('2d');
    competencyRadarChartInstance = new Chart(competencyCtx, {
        type: 'radar',
        data: {
            labels: ['Experiencia Pública', 'Liderazgo', 'Conocimiento Técnico', 'Gestión de Crisis', 'Negociación Política'],
            datasets: [{
                label: 'Puntaje Promedio Postulantes',
                data: [60, 85, 92, 45, 70],
                backgroundColor: 'rgba(0, 85, 164, 0.2)',
                borderColor: 'rgba(0, 85, 164, 1)',
                pointBackgroundColor: 'rgba(0, 85, 164, 1)',
            }, {
                label: 'Puntaje Ideal del Cargo',
                data: [80, 90, 95, 80, 85],
                backgroundColor: 'rgba(255, 99, 132, 0.2)',
                borderColor: 'rgba(255, 99, 132, 1)',
                pointBackgroundColor: 'rgba(255, 99, 132, 1)',
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                r: {
                    beginAtZero: true,
                    max: 100
                }
            }
        }
    });
}

function initializeReportsCharts() {
    // Gráfico de diversidad
    const diversityCtx = document.getElementById('diversityPieChart').getContext('2d');
    diversityPieChartInstance = new Chart(diversityCtx, {
        type: 'doughnut',
        data: {
            labels: ['Hombres', 'Mujeres', 'Otros'],
            datasets: [{
                data: [65, 33, 2],
                backgroundColor: [
                    'rgba(54, 162, 235, 0.7)',
                    'rgba(255, 99, 132, 0.7)',
                    'rgba(201, 203, 207, 0.7)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });

    // Gráfico de acuerdo político
    const agreementCtx = document.getElementById('agreementBarChart').getContext('2d');
    agreementBarChartInstance = new Chart(agreementCtx, {
        type: 'bar',
        data: {
            labels: ['Ministerios', 'Subsecretarías', 'SEREMI'],
            datasets: [
                { label: 'Partido Republicano', data: [5, 10, 20], backgroundColor: 'rgba(255, 99, 132, 0.7)' },
                { label: 'Renovación Nacional', data: [3, 8, 15], backgroundColor: 'rgba(54, 162, 235, 0.7)' },
                { label: 'UDI', data: [2, 5, 10], backgroundColor: 'rgba(255, 206, 86, 0.7)' },
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: { stacked: true },
                y: { stacked: true, beginAtZero: true }
            },
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });

    // Actualizar gráfico de estado del proceso
    updateProcessStatusChart();
}

function updateProcessStatusChart() {
    const chartContainer = document.getElementById('processStatusChart');
    chartContainer.innerHTML = `
                <div style="display: flex; justify-content: space-around; align-items: center; font-size: 1.5em; font-weight: bold; color: var(--primary-color);">
                    <div>
                        <div style="font-size: 2em; color: var(--secondary-color);">${candidatesData.length}</div>
                        <div style="font-size: 0.5em; font-weight: normal;">Total Candidatos</div>
                    </div>
                    <div>
                        <div style="font-size: 2em; color: var(--accent-color);">${candidatesData.filter(c => c.estado_general === 'Preseleccionado').length}</div>
                        <div style="font-size: 0.5em; font-weight: normal;">Preseleccionados</div>
                    </div>
                    <div>
                        <div style="font-size: 2em; color: var(--critical-color);">${positionsData.filter(p => p.estado_cargo === 'Por Definir').length}</div>
                        <div style="font-size: 0.5em; font-weight: normal;">Por Definir</div>
                    </div>
                </div>
            `;
}

// --- Funciones de carga de datos para pestañas específicas ---
async function loadCandidates() {
    document.getElementById('candidatesSpinner').style.display = 'block';
    document.getElementById('candidatesGrid').innerHTML = '';

    try {
        // Cargar candidatos con sus postulaciones y evaluaciones
        const { data: candidates, error } = await supabase
            .from('Candidatos')
            .select('*, PartidosPoliticos(*)');

        if (error) throw error;

        const candidatesGrid = document.getElementById('candidatesGrid');

        candidates.forEach(candidate => {
            // Buscar la postulación principal del candidato
            const mainApplication = applicationsData.find(app =>
                app.id_candidato === candidate.id_candidato && app.postulacion_principal
            );

            // Buscar evaluaciones de IA para este candidato
            const iaEvaluations = evaluationsData.filter(eval =>
                eval.tipo_evaluacion === 'IA_PuntajeObjetivo' &&
                eval.Postulaciones.id_candidato === candidate.id_candidato
            );

            // Calcular puntaje promedio de IA
            let iaScore = 0;
            if (iaEvaluations.length > 0) {
                iaScore = iaEvaluations.reduce((sum, eval) => sum + eval.puntaje_numerico, 0) / iaEvaluations.length;
            }

            // Crear tarjeta de candidato
            const candidateCard = document.createElement('div');
            candidateCard.className = 'candidate-card';
            candidateCard.onclick = () => openModal(candidate.id_candidato);

            const partyName = candidate.PartidosPoliticos ? candidate.PartidosPoliticos.nombre_partido : 'Independiente';
            const positionName = mainApplication ? mainApplication.Cargos.nombre_cargo : 'Sin postulación principal';

            candidateCard.innerHTML = `
                        <div class="candidate-card-header">
                            <p class="candidate-party">${partyName}</p>
                        </div>
                        <div class="candidate-card-body">
                            <h3 class="candidate-name">${candidate.nombres} ${candidate.apellido_paterno} ${candidate.apellido_materno || ''}</h3>
                            <div class="candidate-details">
                                <span><span class="label">Postulación</span><span class="value">${positionName}</span></span>
                                <span><span class="label">Puntaje IA</span><span class="value">${iaScore.toFixed(1)}</span></span>
                            </div>
                        </div>
                    `;

            candidatesGrid.appendChild(candidateCard);
        });

    } catch (error) {
        console.error('Error al cargar candidatos:', error);
        showNotification('Error al cargar candidatos: ' + error.message, 'error');
    } finally {
        document.getElementById('candidatesSpinner').style.display = 'none';
    }
}

async function loadAnalysis() {
    document.getElementById('analysisSpinner').style.display = 'block';

    try {
        // Cargar análisis de posiciones críticas
        const { data: criticalPositions, error } = await supabase
            .from('Cargos')
            .select('*');

        if (error) throw error;

        // Calcular estadísticas para cada posición
        const positionStats = [];

        for (const position of criticalPositions) {
            // Contar postulantes para esta posición
            const applicants = applicationsData.filter(app => app.id_cargo === position.id_cargo);

            // Calcular puntaje promedio de IA para esta posición
            let avgScore = 0;
            let scoreCount = 0;

            for (const applicant of applicants) {
                const evaluations = evaluationsData.filter(eval =>
                    eval.id_postulacion === applicant.id_postulacion &&
                    eval.tipo_evaluacion === 'IA_PuntajeObjetivo'
                );

                for (const eval of evaluations) {
                    if (eval.puntaje_numerico) {
                        avgScore += eval.puntaje_numerico;
                        scoreCount++;
                    }
                }
            }

            if (scoreCount > 0) {
                avgScore = avgScore / scoreCount;
            }

            // Determinar estado
            let status = 'success';
            let statusText = 'Cubierto';

            if (applicants.length < 5 || (scoreCount > 0 && avgScore < 70)) {
                status = 'critical';
                statusText = 'Crítico';
            } else if (applicants.length < 10 || (scoreCount > 0 && avgScore < 80)) {
                status = 'warning';
                statusText = 'Preocupante';
            }

            positionStats.push({
                position: position,
                applicants: applicants.length,
                avgScore: avgScore.toFixed(1),
                status: status,
                statusText: statusText
            });
        }

        // Ordenar posiciones por criticidad
        positionStats.sort((a, b) => {
            if (a.status === 'critical' && b.status !== 'critical') return -1;
            if (a.status !== 'critical' && b.status === 'critical') return 1;
            if (a.status === 'warning' && b.status !== 'warning') return -1;
            if (a.status !== 'warning' && b.status === 'warning') return 1;
            return a.applicants - b.applicants;
        });

        // Actualizar tabla de posiciones críticas
        const tableBody = document.querySelector('#criticalPositionsTable tbody');
        tableBody.innerHTML = '';

        positionStats.slice(0, 10).forEach(stat => {
            const row = document.createElement('tr');
            row.className = stat.status;

            row.innerHTML = `
                        <td>${stat.position.nombre_cargo}</td>
                        <td>${stat.position.nivel_jerarquico}</td>
                        <td>${stat.applicants}</td>
                        <td>${stat.avgScore > 0 ? stat.avgScore : '-'}</td>
                        <td><span class="badge ${stat.status}">${stat.statusText}</span></td>
                    `;

            tableBody.appendChild(row);
        });

        // Inicializar gráfico de competencias si no existe
        if (!competencyRadarChartInstance) {
            initializeAnalysisCharts();
        } else {
            competencyRadarChartInstance.resize();
        }

    } catch (error) {
        console.error('Error al cargar análisis:', error);
        showNotification('Error al cargar análisis: ' + error.message, 'error');
    } finally {
        document.getElementById('analysisSpinner').style.display = 'none';
    }
}

// --- Funciones de interacción ---
function applyFilters() {
    const searchTerm = document.getElementById('candidateSearch').value.toLowerCase();
    const partyFilter = document.getElementById('partyFilter').value;
    const levelFilter = document.getElementById('levelFilter').value;

    // Filtrar candidatos
    const filteredCandidates = candidatesData.filter(candidate => {
        // Filtro por término de búsqueda
        const matchesSearch = !searchTerm ||
            candidate.nombres.toLowerCase().includes(searchTerm) ||
            candidate.apellido_paterno.toLowerCase().includes(searchTerm) ||
            candidate.apellido_materno.toLowerCase().includes(searchTerm) ||
            candidate.rut.toLowerCase().includes(searchTerm);

        // Filtro por partido
        const matchesParty = !partyFilter || candidate.id_partido == partyFilter;

        // Filtro por nivel (basado en postulaciones)
        const applications = applicationsData.filter(app => app.id_candidato === candidate.id_candidato);
        const matchesLevel = !levelFilter || applications.some(app => {
            const position = positionsData.find(p => p.id_cargo === app.id_cargo);
            return position && position.nivel_jerarquico === levelFilter;
        });

        return matchesSearch && matchesParty && matchesLevel;
    });

    // Actualizar grid de candidatos con los resultados filtrados
    const candidatesGrid = document.getElementById('candidatesGrid');
    candidatesGrid.innerHTML = '';

    filteredCandidates.forEach(candidate => {
        // Buscar la postulación principal del candidato
        const mainApplication = applicationsData.find(app =>
            app.id_candidato === candidate.id_candidato && app.postulacion_principal
        );

        // Buscar evaluaciones de IA para este candidato
        const iaEvaluations = evaluationsData.filter(eval =>
            eval.tipo_evaluacion === 'IA_PuntajeObjetivo' &&
            eval.Postulaciones.id_candidato === candidate.id_candidato
        );

        // Calcular puntaje promedio de IA
        let iaScore = 0;
        if (iaEvaluations.length > 0) {
            iaScore = iaEvaluations.reduce((sum, eval) => sum + eval.puntaje_numerico, 0) / iaEvaluations.length;
        }

        // Crear tarjeta de candidato
        const candidateCard = document.createElement('div');
        candidateCard.className = 'candidate-card';
        candidateCard.onclick = () => openModal(candidate.id_candidato);

        const partyName = candidate.PartidosPoliticos ? candidate.PartidosPoliticos.nombre_partido : 'Independiente';
        const positionName = mainApplication ? mainApplication.Cargos.nombre_cargo : 'Sin postulación principal';

        candidateCard.innerHTML = `
                    <div class="candidate-card-header">
                        <p class="candidate-party">${partyName}</p>
                    </div>
                    <div class="candidate-card-body">
                        <h3 class="candidate-name">${candidate.nombres} ${candidate.apellido_paterno} ${candidate.apellido_materno || ''}</h3>
                        <div class="candidate-details">
                            <span><span class="label">Postulación</span><span class="value">${positionName}</span></span>
                            <span><span class="label">Puntaje IA</span><span class="value">${iaScore.toFixed(1)}</span></span>
                        </div>
                    </div>
                `;

        candidatesGrid.appendChild(candidateCard);
    });
}

function updateAnalysis() {
    loadAnalysis();
}

function generateReport(type) {
    showNotification(`Generando reporte de ${type}...`, 'success');
    // Aquí se implementaría la lógica para generar y exportar el reporte
}

// --- Lógica del Modal ---
async function openModal(candidateId) {
    try {
        // Cargar datos detallados del candidato
        const { data: candidate, error } = await supabase
            .from('Candidatos')
            .select('*, PartidosPoliticos(*)')
            .eq('id_candidato', candidateId)
            .single();

        if (error) throw error;

        // Cargar postulaciones del candidato
        const { data: applications, error: appError } = await supabase
            .from('Postulaciones')
            .select('*, Cargos(*)')
            .eq('id_candidato', candidateId);

        if (appError) throw appError;

        // Cargar evaluaciones del candidato
        const { data: evaluations, error: evalError } = await supabase
            .from('Evaluaciones')
            .select('*, Usuarios(*)')
            .in('id_postulacion', applications.map(app => app.id_postulacion));

        if (evalError) throw evalError;

        // Construir contenido del modal
        const modalBody = document.getElementById('modal-body');

        const partyName = candidate.PartidosPoliticos ? candidate.PartidosPoliticos.nombre_partido : 'Independiente';

        let applicationsHtml = '';
        applications.forEach(app => {
            applicationsHtml += `
                        <div class="evaluation-item">
                            <div><strong>Postulación:</strong> ${app.Cargos.nombre_cargo}</div>
                            <div><strong>Estado:</strong> ${app.estado_postulacion}</div>
                            <div><strong>Principal:</strong> ${app.postulacion_principal ? 'Sí' : 'No'}</div>
                        </div>
                    `;
        });

        let evaluationsHtml = '';
        evaluations.forEach(eval => {
            const evaluatorName = eval.Usuarios ? eval.Usuarios.nombre_completo : 'Sistema IA';
            const evalDate = new Date(eval.fecha_evaluacion).toLocaleDateString();

            evaluationsHtml += `
                        <div class="evaluation-item">
                            <div class="author">${evaluatorName}</div>
                            <div class="date">${evalDate}</div>
                            <div><strong>Tipo:</strong> ${eval.tipo_evaluacion}</div>
                            ${eval.puntaje_numerico ? `<div><strong>Puntaje:</strong> ${eval.puntaje_numerico}</div>` : ''}
                            ${eval.texto_evaluacion ? `<div><strong>Comentarios:</strong> ${eval.texto_evaluacion}</div>` : ''}
                        </div>
                    `;
        });

        // Calcular puntaje promedio de IA
        const iaEvaluations = evaluations.filter(eval => eval.tipo_evaluacion === 'IA_PuntajeObjetivo');
        let avgIaScore = 0;
        if (iaEvaluations.length > 0) {
            avgIaScore = iaEvaluations.reduce((sum, eval) => sum + eval.puntaje_numerico, 0) / iaEvaluations.length;
        }

        modalBody.innerHTML = `
                    <div class="modal-header">
                        <h2>${candidate.nombres} ${candidate.apellido_paterno} ${candidate.apellido_materno || ''}</h2>
                        <p>RUT: ${candidate.rut} | Partido: ${partyName}</p>
                    </div>
                    
                    <div class="ai-score">Puntaje IA: ${avgIaScore.toFixed(1)}</div>
                    
                    <div class="evaluation-section">
                        <h3>Postulaciones</h3>
                        ${applicationsHtml || '<p>No hay postulaciones registradas</p>'}
                    </div>
                    
                    <div class="evaluation-section">
                        <h3>Evaluaciones</h3>
                        ${evaluationsHtml || '<p>No hay evaluaciones registradas</p>'}
                    </div>
                `;

        // Mostrar modal
        document.getElementById('candidateModal').style.display = 'block';

    } catch (error) {
        console.error('Error al abrir modal:', error);
        showNotification('Error al cargar detalles del candidato', 'error');
    }
}

function closeModal() {
    document.getElementById('candidateModal').style.display = 'none';
}

// --- Funciones de utilidad ---
function showNotification(message, type) {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.className = 'notification ' + type;
    notification.style.display = 'block';

    setTimeout(() => {
        notification.style.display = 'none';
    }, 3000);
}

// --- Event Listeners ---
document.getElementById('loginBtn').addEventListener('click', login);

window.onclick = function (event) {
    const modal = document.getElementById('candidateModal');
    if (event.target == modal) {
        modal.style.display = 'none';
    }
}

// Inicializar la aplicación
document.addEventListener('DOMContentLoaded', function () {
    // Verificar si hay una sesión activa
    supabase.auth.getSession().then(({ data: { session } }) => {
        if (session) {
            currentUser = session.user;
            document.getElementById('userName').textContent = session.user.email;
            document.getElementById('loginContainer').style.display = 'none';
            document.getElementById('mainApp').style.display = 'flex';

            // Cargar datos iniciales
            loadInitialData();
        }
    });
});
const fs = require('fs');
const path = require('path');

const dataDir = path.join(__dirname, '..', 'data');
const dataFile = path.join(dataDir, 'reports.json');

function ensureStorage() {
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }

  if (!fs.existsSync(dataFile)) {
    const seedReports = [
      {
        id: 'OAX-2024-0891',
        title: 'Fuga de agua',
        description: 'Fuga detectada en Calle Macedonio Alcalá.',
        category: 'agua',
        location: 'Calle Macedonio Alcalá',
        userName: 'Alejandro Ramírez',
        status: 'Enviado',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      {
        id: 'OAX-2024-0854',
        title: 'Bache',
        description: 'Bache profundo en Colonia Reforma.',
        category: 'bache',
        location: 'Colonia Reforma',
        userName: 'María López',
        status: 'En Revisión',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      {
        id: 'OAX-2024-0722',
        title: 'Luminaria fundida',
        description: 'Lámpara apagada cerca de Parque El Llano.',
        category: 'luminaria',
        location: 'Parque El Llano',
        userName: 'Juan Pérez',
        status: 'Finalizado',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
    ];

    fs.writeFileSync(dataFile, JSON.stringify(seedReports, null, 2), 'utf8');
  }
}

function loadReports() {
  ensureStorage();
  const raw = fs.readFileSync(dataFile, 'utf8');
  return JSON.parse(raw);
}

function saveReports(reports) {
  ensureStorage();
  fs.writeFileSync(dataFile, JSON.stringify(reports, null, 2), 'utf8');
}

module.exports = {
  loadReports,
  saveReports,
};

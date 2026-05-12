const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { loadReports, saveReports } = require('./storage');

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const allowedOrigin = process.env.CORS_ORIGIN || '*';

app.use(cors({ origin: allowedOrigin }));
app.use(express.json());

let reports = loadReports();

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'oaxaca-reporta-backend' });
});

app.get('/reports', (req, res) => {
  const { status } = req.query;

  if (status) {
    const filtered = reports.filter((report) => report.status === status);
    return res.json(filtered);
  }

  return res.json(reports);
});

app.get('/reports/:id', (req, res) => {
  const report = reports.find((item) => item.id === req.params.id);

  if (!report) {
    return res.status(404).json({ message: 'Report not found' });
  }

  return res.json(report);
});

app.post('/reports', (req, res) => {
  const { title, description, category, location, userName } = req.body;

  if (!title || !description || !category || !location) {
    return res.status(400).json({
      message: 'title, description, category, and location are required',
    });
  }

  const now = new Date().toISOString();
  const report = {
    id: `OAX-${Date.now()}`,
    title,
    description,
    category,
    location,
    userName: userName || 'Ciudadano',
    status: 'Enviado',
    createdAt: now,
    updatedAt: now,
  };

  reports = [report, ...reports];
  saveReports(reports);

  return res.status(201).json(report);
});

app.patch('/reports/:id/status', (req, res) => {
  const { status } = req.body;
  const validStatuses = ['Enviado', 'En Revisión', 'Finalizado'];

  if (!validStatuses.includes(status)) {
    return res.status(400).json({
      message: `status must be one of: ${validStatuses.join(', ')}`,
    });
  }

  const index = reports.findIndex((item) => item.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ message: 'Report not found' });
  }

  reports[index] = {
    ...reports[index],
    status,
    updatedAt: new Date().toISOString(),
  };

  saveReports(reports);

  return res.json(reports[index]);
});

app.post('/auth/login', (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'email is required' });
  }

  return res.json({
    token: 'demo-token',
    user: {
      id: 'user-1',
      name: 'Alejandro Ramírez',
      email,
      city: 'Oaxaca de Juárez',
    },
  });
});

app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

app.listen(port, () => {
  console.log(`Oaxaca Reporta backend running on http://localhost:${port}`);
});

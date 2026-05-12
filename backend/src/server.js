const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const allowedOrigin = process.env.CORS_ORIGIN || '*';
const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/oaxaca_reporta';
const adminToken = process.env.ADMIN_TOKEN || 'admin-demo-token';

const uploadDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const safe = file.originalname.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9._-]/g, '');
    cb(null, `${Date.now()}-${safe}`);
  },
});
const upload = multer({ storage });

app.use(cors({ origin: allowedOrigin }));
app.use(express.json({ limit: '2mb' }));
app.use('/uploads', express.static(uploadDir));

const reportSchema = new mongoose.Schema(
  {
    reportId: { type: String, unique: true, index: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    category: { type: String, default: 'bache' },
    locationText: { type: String, required: true },
    coordinates: {
      lat: { type: Number, required: true },
      lng: { type: Number, required: true },
    },
    userName: { type: String, default: 'Ciudadano' },
    status: {
      type: String,
      enum: ['Enviado', 'En Revisión', 'Finalizado'],
      default: 'Enviado',
      index: true,
    },
    priority: {
      type: String,
      enum: ['Baja', 'Media', 'Alta'],
      default: 'Media',
    },
  },
  { timestamps: true }
);

const feedPostSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: { type: String, required: true },
    locationText: { type: String, required: true },
    imageUrls: [{ type: String }],
    createdBy: { type: String, default: 'Administrador' },
  },
  { timestamps: true }
);

const Report = mongoose.model('Report', reportSchema);
const FeedPost = mongoose.model('FeedPost', feedPostSchema);

const validStatuses = ['Enviado', 'En Revisión', 'Finalizado'];

function authAdmin(req, res, next) {
  const token = req.headers['x-admin-token'];
  if (token !== adminToken) {
    return res.status(401).json({ message: 'Admin token inválido' });
  }
  return next();
}

function reportToClient(doc) {
  return {
    id: doc.reportId,
    _id: doc._id,
    title: doc.title,
    description: doc.description,
    category: doc.category,
    location: doc.locationText,
    coordinates: doc.coordinates,
    userName: doc.userName,
    status: doc.status,
    priority: doc.priority,
    createdAt: doc.createdAt,
    updatedAt: doc.updatedAt,
  };
}

function getRiskByCount(count) {
  if (count >= 10) return { label: 'Alta incidencia', level: 'high', color: '#C62828' };
  if (count >= 5) return { label: 'Incidencia media', level: 'medium', color: '#F9A825' };
  return { label: 'Baja incidencia', level: 'low', color: '#2E7D32' };
}

async function buildRiskZones() {
  const reports = await Report.find({ category: 'bache' }).lean();

  const buckets = new Map();
  for (const report of reports) {
    const lat = report.coordinates?.lat;
    const lng = report.coordinates?.lng;
    if (typeof lat !== 'number' || typeof lng !== 'number') continue;

    // Agrupación por cuadrante (~550m) para definir zonas de riesgo dinámicas
    const cellLat = Math.round(lat * 200) / 200;
    const cellLng = Math.round(lng * 200) / 200;
    const key = `${cellLat}:${cellLng}`;

    const current = buckets.get(key) || { lat: cellLat, lng: cellLng, count: 0 };
    current.count += 1;
    buckets.set(key, current);
  }

  return Array.from(buckets.values())
    .map((bucket, index) => {
      const risk = getRiskByCount(bucket.count);
      return {
        id: `zone-${index + 1}`,
        point: { lat: bucket.lat, lng: bucket.lng },
        reports: bucket.count,
        label: risk.label,
        riskLevel: risk.level,
        color: risk.color,
      };
    })
    .sort((a, b) => b.reports - a.reports);
}

app.get('/health', async (_req, res) => {
  res.json({
    status: 'ok',
    service: 'oaxaca-reporta-backend',
    db: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
  });
});

app.get('/reports', async (req, res) => {
  const { status } = req.query;
  const query = {};

  if (status) {
    query.status = status;
  }

  const reports = await Report.find(query).sort({ createdAt: -1 });
  return res.json(reports.map(reportToClient));
});

app.get('/reports/map', async (_req, res) => {
  const reports = await Report.find({ category: 'bache' }).sort({ createdAt: -1 }).lean();
  return res.json(
    reports.map((report) => ({
      id: report.reportId,
      title: report.title,
      description: report.description,
      status: report.status,
      priority: report.priority,
      location: report.locationText,
      lat: report.coordinates.lat,
      lng: report.coordinates.lng,
      createdAt: report.createdAt,
    }))
  );
});

app.get('/reports/:id', async (req, res) => {
  const report = await Report.findOne({ reportId: req.params.id });

  if (!report) {
    return res.status(404).json({ message: 'Report not found' });
  }

  return res.json(reportToClient(report));
});

app.post('/reports', async (req, res) => {
  const {
    title,
    description,
    category,
    location,
    locationText,
    coordinates,
    lat,
    lng,
    userName,
  } = req.body;

  const resolvedLocationText = locationText || location;
  const resolvedLat = coordinates?.lat ?? lat;
  const resolvedLng = coordinates?.lng ?? lng;

  if (!title || !description || !resolvedLocationText || resolvedLat == null || resolvedLng == null) {
    return res.status(400).json({
      message: 'title, description, location/locationText, lat y lng son requeridos',
    });
  }

  const report = await Report.create({
    reportId: `OAX-${Date.now()}`,
    title,
    description,
    category: category || 'bache',
    locationText: resolvedLocationText,
    coordinates: {
      lat: Number(resolvedLat),
      lng: Number(resolvedLng),
    },
    userName: userName || 'Ciudadano',
  });

  return res.status(201).json(reportToClient(report));
});

app.patch('/reports/:id/status', authAdmin, async (req, res) => {
  const { status } = req.body;

  if (!validStatuses.includes(status)) {
    return res.status(400).json({
      message: `status must be one of: ${validStatuses.join(', ')}`,
    });
  }

  const report = await Report.findOneAndUpdate(
    { reportId: req.params.id },
    { status, updatedAt: new Date() },
    { new: true }
  );

  if (!report) {
    return res.status(404).json({ message: 'Report not found' });
  }

  return res.json(reportToClient(report));
});

app.get('/risk-zones', async (_req, res) => {
  const zones = await buildRiskZones();
  return res.json(zones);
});

app.get('/feed', async (_req, res) => {
  const posts = await FeedPost.find({}).sort({ createdAt: -1 }).lean();
  return res.json(posts);
});

app.post('/feed', authAdmin, upload.array('photos', 5), async (req, res) => {
  const { title, description, locationText, createdBy } = req.body;

  if (!title || !description || !locationText) {
    return res.status(400).json({ message: 'title, description y locationText son requeridos' });
  }

  const uploadedPhotos = (req.files || []).map((file) => `/uploads/${file.filename}`);
  const imageUrlsFromBody = Array.isArray(req.body.imageUrls)
    ? req.body.imageUrls
    : req.body.imageUrls
      ? [req.body.imageUrls]
      : [];

  const post = await FeedPost.create({
    title,
    description,
    locationText,
    imageUrls: [...uploadedPhotos, ...imageUrlsFromBody],
    createdBy: createdBy || 'Administrador',
  });

  return res.status(201).json(post);
});

app.post('/auth/login', (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'email is required' });
  }

  const isAdmin = email.toLowerCase().includes('admin');
  return res.json({
    token: isAdmin ? adminToken : 'demo-token',
    user: {
      id: isAdmin ? 'admin-1' : 'user-1',
      name: isAdmin ? 'Administrador Oaxaca' : 'Alejandro Ramírez',
      email,
      city: 'Oaxaca de Juárez',
      role: isAdmin ? 'admin' : 'user',
    },
  });
});

// Serve web admin static files from the same backend process so a single
// deployment serves API + UI. Files are located in project_root/web/interface.
const webDir = path.join(__dirname, '..', '..', 'web', 'interface');
if (fs.existsSync(webDir)) {
  app.use(express.static(webDir));
  // Root serves the dashboard page by default
  app.get('/', (_req, res) => res.sendFile(path.join(webDir, 'dashboard_mapa_de_incidencias.html')));
}

// 404 fallback for unknown API routes
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

async function start() {
  try {
    await mongoose.connect(mongoUri);
    console.log('MongoDB connected');
    app.listen(port, () => {
      console.log(`Oaxaca Reporta backend running on http://localhost:${port}`);
    });
  } catch (error) {
    console.error('Failed to start backend:', error.message);
    process.exit(1);
  }
}

start();

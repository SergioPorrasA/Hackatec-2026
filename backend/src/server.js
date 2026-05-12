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
const disableAdminAuth = process.env.DISABLE_ADMIN_AUTH === 'true' || adminToken === 'admin-demo-token';

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
    zoneKey: { type: String, index: true, default: '' },
    zoneLabel: { type: String, default: '' },
    userName: { type: String, default: 'Ciudadano' },
    userPhone: { type: String, default: '' },
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
    zoneKey: { type: String, index: true, default: '' },
    zoneLabel: { type: String, default: '' },
    locationLat: { type: Number },
    locationLng: { type: Number },
    updatedReportCount: { type: Number, default: 0 },
    updatedReportIds: [{ type: String }],
    imageUrls: [{ type: String }],
    createdBy: { type: String, default: 'Administrador' },
  },
  { timestamps: true }
);

const notificationSchema = new mongoose.Schema(
  {
    notificationId: { type: String, unique: true, index: true },
    userPhone: { type: String, index: true },
    reportId: { type: String, index: true },
    title: { type: String, required: true },
    message: { type: String, required: true },
    reportStatus: { type: String, required: true },
    readAt: { type: Date, default: null },
  },
  { timestamps: true }
);

const Report = mongoose.model('Report', reportSchema);
const FeedPost = mongoose.model('FeedPost', feedPostSchema);
const Notification = mongoose.model('Notification', notificationSchema);

const validStatuses = ['Enviado', 'En Revisión', 'Finalizado'];

function authAdmin(req, res, next) {
  if (disableAdminAuth) {
    return next();
  }

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
    userPhone: doc.userPhone,
    status: doc.status,
    priority: doc.priority,
    createdAt: doc.createdAt,
    updatedAt: doc.updatedAt,
  };
}

function getRiskByCount(count) {
  // Nuevo criterio: >=5 -> alerta amarilla, >10 -> alerta roja
  if (count > 10) return { label: 'Alerta roja', level: 'red', color: '#C62828' };
  if (count >= 5) return { label: 'Alerta amarilla', level: 'yellow', color: '#F9A825' };
  return { label: 'Baja incidencia', level: 'low', color: '#2E7D32' };
}

function getZoneKeyFromCoordinates(lat, lng) {
  const bucketLat = Math.round(Number(lat) * 200) / 200;
  const bucketLng = Math.round(Number(lng) * 200) / 200;
  return `${bucketLat}:${bucketLng}`;
}

function getZoneLabelForReport(report) {
  return String(report.zoneLabel || report.locationText || report.title || 'Zona prioritaria').trim();
}

function haversineDistanceMeters(lat1, lng1, lat2, lng2) {
  const toRadians = (value) => (value * Math.PI) / 180;
  const earthRadius = 6371000;
  const deltaLat = toRadians(lat2 - lat1);
  const deltaLng = toRadians(lng2 - lng1);
  const a = Math.sin(deltaLat / 2) ** 2
    + Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) * Math.sin(deltaLng / 2) ** 2;
  return 2 * earthRadius * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

async function createStatusNotification(report, status) {
  if (!report || !report.userPhone) {
    return null;
  }

  return Notification.create({
    notificationId: `NTF-${Date.now()}-${report.reportId}-${status}`,
    userPhone: report.userPhone,
    reportId: report.reportId,
    title: 'Seguimiento de tu reporte',
    message: `Tu reporte ${report.reportId} ahora está en estado ${status}. El equipo municipal le dio seguimiento.`,
    reportStatus: status,
  });
}

async function findReportsInZone(lat, lng, radiusMeters = 180) {
  const reports = await Report.find({ category: 'bache', status: { $ne: 'Finalizado' } }).lean();
  const zoneKey = getZoneKeyFromCoordinates(lat, lng);

  return reports.filter((report) => {
    const reportLat = report.coordinates?.lat;
    const reportLng = report.coordinates?.lng;
    if (typeof reportLat !== 'number' || typeof reportLng !== 'number') {
      return false;
    }

    const matchesExistingZone = report.zoneKey && report.zoneKey === zoneKey;
    return matchesExistingZone || haversineDistanceMeters(lat, lng, reportLat, reportLng) <= radiusMeters;
  });
}

async function buildRiskZones() {
  // Only consider active (non-finalized) bache reports when building risk zones.
  const reports = await Report.find({ category: 'bache', status: { $ne: 'Finalizado' } }).lean();

  const buckets = new Map();
  for (const report of reports) {
    const lat = report.coordinates?.lat;
    const lng = report.coordinates?.lng;
    if (typeof lat !== 'number' || typeof lng !== 'number') continue;

    // Agrupación persistente por zona para mantener relación zona-bache.
    const key = report.zoneKey || getZoneKeyFromCoordinates(lat, lng);
    const label = getZoneLabelForReport(report);

    // Track sum of lat/lng and count so we can compute centroid of reports.
    const current = buckets.get(key) || { key, latSum: 0, lngSum: 0, count: 0, label };
    current.latSum += lat;
    current.lngSum += lng;
    current.count += 1;
    current.label = current.label || label;
    buckets.set(key, current);
  }

  return Array.from(buckets.values())
    .map((bucket, index) => {
        const risk = getRiskByCount(bucket.count);
        // radius: provide a compact scale in meters so clients render tighter
        // zones. Use a smaller base and per-report multiplier so nearby baches
        // don't produce overly large areas. Cap to a reasonable maximum.
        const radius = Math.min(150, 30 + bucket.count * 12);
        // compute centroid from summed lat/lng
        const avgLat = bucket.latSum / bucket.count;
        const avgLng = bucket.lngSum / bucket.count;
        return {
          id: `zone-${index + 1}`,
          key: bucket.key,
          point: { lat: avgLat, lng: avgLng },
          reports: bucket.count,
          radius,
          label: bucket.label || risk.label,
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
  // Return only active (non-finalized) bache reports for map display.
  const reports = await Report.find({ category: 'bache', status: { $ne: 'Finalizado' } }).sort({ createdAt: -1 }).lean();
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
    userPhone,
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
    zoneKey: getZoneKeyFromCoordinates(resolvedLat, resolvedLng),
    zoneLabel: resolvedLocationText,
    userName: userName || 'Ciudadano',
    userPhone: String(userPhone || '').trim(),
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

  await createStatusNotification(report, status);

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

app.get('/notifications', async (req, res) => {
  const { phone } = req.query;

  if (!phone) {
    return res.status(400).json({ message: 'phone es requerido' });
  }

  const notifications = await Notification.find({ userPhone: String(phone).trim() })
    .sort({ createdAt: -1 })
    .lean();

  return res.json(notifications);
});

app.post('/feed', authAdmin, upload.array('photos', 5), async (req, res) => {
  const {
    title,
    description,
    locationText,
    locationLat,
    locationLng,
    zoneKey,
    zoneLabel,
    reportIds,
    createdBy,
  } = req.body;

  if (!title || !description || !locationText) {
    return res.status(400).json({ message: 'title, description y locationText son requeridos' });
  }

  const parsedLat = locationLat != null && locationLat !== '' ? Number(locationLat) : null;
  const parsedLng = locationLng != null && locationLng !== '' ? Number(locationLng) : null;
  const feedZoneKey = String(zoneKey || '').trim() || (
    Number.isFinite(parsedLat) && Number.isFinite(parsedLng)
      ? getZoneKeyFromCoordinates(parsedLat, parsedLng)
      : ''
  );
  const feedZoneLabel = String(zoneLabel || locationText || '').trim();
  let updatedReportIds = [];

  const parsedReportIds = String(reportIds || '')
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean);

  if (parsedReportIds.length > 0) {
    const existingReports = await Report.find({
      category: 'bache',
      status: { $ne: 'Finalizado' },
      reportId: { $in: parsedReportIds },
    }).lean();
    updatedReportIds = existingReports.map((report) => report.reportId);
  }

  if (updatedReportIds.length === 0 && feedZoneKey) {
    const zoneReports = await Report.find({
      category: 'bache',
      status: { $ne: 'Finalizado' },
      zoneKey: feedZoneKey,
    }).lean();
    updatedReportIds = zoneReports.map((report) => report.reportId);
  }

  if (updatedReportIds.length === 0 && Number.isFinite(parsedLat) && Number.isFinite(parsedLng)) {
    const zoneReports = await findReportsInZone(parsedLat, parsedLng);
    updatedReportIds = zoneReports.map((report) => report.reportId);
  }

  if (updatedReportIds.length > 0) {
    await Report.updateMany(
      { reportId: { $in: updatedReportIds } },
      {
        $set: {
          status: 'Finalizado',
          updatedAt: new Date(),
          zoneKey: feedZoneKey,
          zoneLabel: feedZoneLabel,
        },
      }
    );

    const updatedReports = await Report.find({ reportId: { $in: updatedReportIds } }).lean();
    await Promise.all(updatedReports.map((report) => createStatusNotification(report, 'Finalizado')));
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
    zoneKey: feedZoneKey,
    zoneLabel: feedZoneLabel,
    locationLat: Number.isFinite(parsedLat) ? parsedLat : undefined,
    locationLng: Number.isFinite(parsedLng) ? parsedLng : undefined,
    updatedReportCount: updatedReportIds.length,
    updatedReportIds,
    imageUrls: [...uploadedPhotos, ...imageUrlsFromBody],
    createdBy: createdBy || 'Administrador',
  });

  return res.status(201).json(post);
});

app.post('/auth/login', (req, res) => {
  const {
    email,
    username,
    user,
    phone,
    password,
  } = req.body;

  const resolvedUser = (username || user || email || '').trim();
  const resolvedPhone = String(phone || '').trim();
  const resolvedPassword = String(password || '').trim();

  if (!resolvedUser || !resolvedPhone || !resolvedPassword) {
    return res.status(400).json({
      message: 'username/user, phone y password son requeridos',
    });
  }

  const isAdmin = resolvedUser.toLowerCase().includes('admin');
  return res.json({
    token: isAdmin ? adminToken : 'demo-token',
    user: {
      id: isAdmin ? 'admin-1' : 'user-1',
      name: isAdmin ? 'Administrador Oaxaca' : resolvedUser,
      username: resolvedUser,
      phone: resolvedPhone,
      email: email || `${resolvedPhone}@oaxaca.local`,
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

# Sistema de Notificaciones en Tiempo Real

## 📋 Descripción General

Hemos implementado un sistema de notificaciones en **tiempo real** usando **Socket.io** que permite que cuando un usuario web marca un reporte como **"En Revisión"**, los usuarios de la app móvil reciban una notificación instantánea.

## 🏗️ Arquitectura

```
┌─────────────────────┐
│  Web Dashboard      │
│  (reportes_ejecut)  │ ──PATCH /reports/{id}/status──┐
└─────────────────────┘                                │
                                                       ▼
                                           ┌──────────────────────┐
                                           │  Node.js Backend     │
                                           │  + Socket.io Server  │
                                           │  (port 3000/ws)      │
                                           └──────────────────────┘
                                                       │
                                    ┌──────────────────┴──────────────────┐
                                    │                                     │
                                    ▼                                     ▼
                            📱 Mobile App (Flutter)  📊 MongoDB
                            - Conecta via WebSocket  - Guarda notificaciones
                            - Escucha eventos       - Tabla: Notification
                            - Muestra SnackBar
```

## 🔧 Cambios Implementados

### 1. Backend (Node.js + Socket.io)

**Archivo**: `backend/src/server.js`

#### Cambios principales:

```javascript
// ✅ Nuevas dependencias
const http = require("http");
const { Server } = require("socket.io");

// ✅ Crear servidor HTTP con Socket.io
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

// ✅ Manejo de conexiones WebSocket
io.on("connection", (socket) => {
  console.log(`Mobile app connected: ${socket.id}`);

  socket.on("subscribe_to_updates", (data) => {
    console.log(`Client subscribed: ${data?.phone}`);
  });

  socket.on("disconnect", () => {
    console.log(`Mobile app disconnected: ${socket.id}`);
  });
});

// ✅ Emitir notificación cuando estado cambia a "En Revisión"
app.patch("/reports/:id/status", authAdmin, async (req, res) => {
  // ... actualizar reporte ...

  if (status === "En Revisión") {
    io.emit("status_updated", {
      reportId: report.reportId,
      title: report.title,
      location: report.locationText,
      status: status,
      coordinates: report.coordinates,
      timestamp: new Date(),
      message: `El reporte "${report.title}" en ${report.locationText} ahora está en revisión.`,
    });
  }

  return res.json(reportToClient(report));
});
```

**Instalación de Socket.io:**

```bash
cd backend
npm install socket.io
```

### 2. Mobile App (Flutter)

**Archivo**: `lib/services/api_service.dart`

#### Cambios principales:

```dart
// ✅ Importar Socket.io client
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiService {
  static IO.Socket? _socket;
  static Function(Map<String, dynamic>)? _onStatusUpdated;

  /// Inicializar WebSocket para notificaciones
  static void initializeWebSocket({
    required Function(Map<String, dynamic>) onStatusUpdated,
  }) {
    _onStatusUpdated = onStatusUpdated;
    _connectWebSocket();
  }

  static void _connectWebSocket() {
    final wsBaseUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');

    _socket = IO.io(wsBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(99999)
          .build(),
    );

    // ✅ Escuchar eventos del servidor
    _socket!.on('status_updated', (data) {
      if (_onStatusUpdated != null) {
        _onStatusUpdated!(Map<String, dynamic>.from(data as Map));
      }
    });
  }

  /// Desconectar WebSocket
  static void disconnectWebSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
```

**Dependencias en pubspec.yaml:**

```yaml
dependencies:
  socket_io_client: ^2.0.0
  flutter_local_notifications: ^17.1.2
```

### 3. Pantalla Principal (main.dart)

**Cambios principales:**

```dart
class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // ✅ Inicializar WebSocket cuando la app inicia
    ApiService.initializeWebSocket(
      onStatusUpdated: _handleStatusUpdate,
    );
  }

  @override
  void dispose() {
    // ✅ Desconectar WebSocket cuando la app se cierra
    ApiService.disconnectWebSocket();
    super.dispose();
  }

  void _handleStatusUpdate(Map<String, dynamic> notification) {
    // ✅ Mostrar notificación como SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'Reporte actualizado',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(notification['message'] ?? ''),
            if (notification['location'] != null)
              Text('Ubicación: ${notification['location']}'),
          ],
        ),
        duration: const Duration(seconds: 6),
        backgroundColor: Colors.blue.shade700,
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Navegar a la vista de estado para ver el reporte
            setState(() { _selectedIndex = 3; });
          },
        ),
      ),
    );
  }
}
```

## 📱 Flujo de Uso

1. **Usuario Web**:
   - Abre el dashboard de reportes ejecutivos
   - Ve el mapa con todos los reportes (heatmap)
   - Hace click en un reporte y cambia su estado a **"En Revisión"**
   - Se envía una solicitud PATCH a `/reports/{id}/status`

2. **Backend**:
   - Recibe la solicitud PATCH
   - Actualiza el estado en la BD
   - Verifica si el nuevo estado es "En Revisión"
   - Emite un evento `status_updated` vía Socket.io a todos los clientes conectados

3. **App Móvil**:
   - Está conectada al servidor WebSocket
   - Recibe el evento `status_updated`
   - Muestra un **SnackBar** con la información del reporte
   - El usuario puede hacer click en "Ver" para navegar a la vista de estado

## 🧪 Cómo Probar

### Opción 1: Via Web Dashboard

1. Abre `http://localhost:3000` en el navegador (web dashboard)
2. Abre la app móvil en el emulador/dispositivo (conectado al mismo backend)
3. En el dashboard, localiza un reporte en el mapa
4. Abre el dropdown de estado y cambia a **"En Revisión"**
5. Deberías ver una notificación instantánea en la app móvil

### Opción 2: Via API (curl/Postman)

```bash
# 1. Primero, obtén la lista de reportes
GET http://localhost:3000/reports

# 2. Copia el reportId de uno cualquiera (ej: OAX-123456789)
# 3. Actualiza su estado a "En Revisión"
PATCH http://localhost:3000/reports/OAX-123456789/status
Headers:
  - Content-Type: application/json
  - x-admin-token: admin-demo-token
Body:
  {
    "status": "En Revisión"
  }

# 4. La notificación debería llegar a la app móvil instantáneamente
```

## 📊 Estructura de la Notificación

Cuando el backend emite una notificación, contiene:

```json
{
  "reportId": "OAX-1234567890",
  "title": "Bache en Calle Principal",
  "location": "Calle Principal, Colonia Centro",
  "status": "En Revisión",
  "message": "El reporte \"Bache en Calle Principal\" en Calle Principal, Colonia Centro ahora está en revisión.",
  "coordinates": {
    "lat": 17.0627,
    "lng": -96.7266
  },
  "timestamp": "2026-05-12T10:30:00.000Z"
}
```

## 🔗 Endpoints Relacionados

| Método | Endpoint                   | Descripción                                                           |
| ------ | -------------------------- | --------------------------------------------------------------------- |
| GET    | `/reports`                 | Obtener todos los reportes                                            |
| PATCH  | `/reports/:id/status`      | Cambiar estado del reporte (dispara notificación si es "En Revisión") |
| GET    | `/notifications?phone=xxx` | Obtener notificaciones guardadas (fallback de polling)                |
| WS     | `ws://host:3000`           | Conexión WebSocket para notificaciones en tiempo real                 |

## 🚀 Próximas Mejoras (Opcional)

- [ ] Notificaciones locales persistentes (flutter_local_notifications)
- [ ] Historial de notificaciones en la app
- [ ] Filtrar notificaciones por ubicación/colonia
- [ ] Badge en el icono de la app mostrando número de notificaciones nuevas
- [ ] Sonido/vibración al recibir notificación
- [ ] Notificaciones push via Firebase Cloud Messaging (FCM)

## ✅ Estado Actual

- ✅ Backend: Socket.io implementado y funcionando
- ✅ Mobile: ApiService con WebSocket client
- ✅ UI: SnackBar con notificación en tiempo real
- ✅ Sin dependencias externas (Firebase)
- ✅ Funciona en emulador y dispositivos reales
- ✅ Reconecta automáticamente si se pierde conexión

## 📝 Notas

1. El servidor WebSocket está disponible en `ws://0.0.0.0:3000` (o `ws://localhost:3000` desde la app)
2. La app móvil se conecta automáticamente en `initState()` y se desconecta en `dispose()`
3. Las notificaciones se guardan también en MongoDB como fallback
4. El sistema soporta múltiples clientes conectados simultáneamente
5. Si la app se cierra y vuelve a abrir, descargará las notificaciones pendientes via GET `/notifications?phone=xxx`

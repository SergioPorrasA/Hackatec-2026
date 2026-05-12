# Oaxaca Reporta Backend

API Node.js para la app móvil de Oaxaca Reporta.

## Requisitos

- Node.js 18 o superior

## Instalar

```powershell
cd backend
npm install
```

## Ejecutar

```powershell
npm start
```

## Endpoints

- `GET /health`
- `GET /reports`
- `GET /reports/:id`
- `POST /reports`
- `PATCH /reports/:id/status`
- `POST /auth/login`

## Ejemplo para emulador Android

Si tu Flutter corre en un emulador Android y el backend corre en tu PC, usa:

```text
http://10.0.2.2:3000
```

## Ejemplo de `POST /reports`

```json
{
  "title": "Bache profundo",
  "description": "Se formó un bache grande frente a la escuela.",
  "category": "bache",
  "location": "Av. Juárez 120",
  "userName": "Alejandro"
}
```

# Car Rental Server

Node.js/Express backend for the car rental application.

## Run

```bash
npm install
npm run dev
```

The server listens on `PORT` or `5000` by default.

## Environment variables

Create a local `.env` file with:

```env
MONGO_URI=<mongodb-connection-string>
JWT_SECRET=<local-secret>
JWT_EXPIRES_IN=7d
PORT=5000
ADMIN_EMAIL=<admin-email>
ADMIN_PASSWORD=<local-admin-password>
ADMIN_NAME=System Admin
```

Create or refresh the admin account with:

```bash
npm run create-admin
```

Do not commit `.env` or real credentials.

## Authentication

Protected endpoints require:

```http
Authorization: Bearer <jwt-token>
```

Admin endpoints require a token for a user whose database role is `admin`. Blocked users receive `403` from protected endpoints.

## Admin API

All endpoints below use `protect` and `authorize("admin")`:

- `GET /api/admin/dashboard`
- `GET /api/admin/reports/revenue?year=2026`
- `GET /api/admin/reports/bookings`
- `GET /api/admin/reports/top-cars?limit=5`
- `GET /api/admin/users`
- `GET /api/admin/users/:id`
- `PATCH /api/admin/users/:id/status` with `{ "status": "active" | "blocked" }`
- `GET /api/admin/payments?status=paid`
- `GET /api/admin/payments/:id`

Admin booking management is available at:

- `GET /api/bookings/admin/all?status=pending&paymentStatus=paid&search=keyword`
- `PATCH /api/bookings/admin/:id/status` with `{ "status": "confirmed" }`

Payment reports use `Booking.paymentStatus` because this project does not have a separate Payment collection.

## Car management

- Public read: `GET /api/cars`, `GET /api/cars/:id`
- Admin write: `POST /api/cars`, `PUT /api/cars/:id`, `DELETE /api/cars/:id`

A car with booking history cannot be physically deleted. Change its status to `maintenance` or `rented` instead.

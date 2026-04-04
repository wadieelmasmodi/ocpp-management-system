# Setup Guide - Open-Source OCPP CMS

This guide walkthrough the steps to set up both the Backend and Frontend of the Open-Source OCPP 1.6 CMS.

## Prerequisites

Ensure you have the following installed:
- **Node.js** 18 or higher
- **PostgreSQL** database (running locally or a connection string to a remote instance)

---

## 1. Backend Setup

The Backend handles the OCPP protocol, database management, and provides the API for the frontend.

### Step 1.1: Install Dependencies
```bash
cd Backend
npm install
```

### Step 1.2: Environment Configuration
Copy the `.env.example` to `.env` and update the `DATABASE_URL` with your PostgreSQL credentials.
```env
DATABASE_URL="postgresql://user:password@localhost:5432/ocpp_cms?schema=public"
PORT=3000
OCPP_PORT=9220
OCPP_LOG_WS_PORT=3001
JWT_SECRET="your-secret-key"
```

### Step 1.3: Database Setup
```bash
# Generate Prisma types
npm run prisma:generate

# Run migrations to create tables
npm run prisma:migrate
```

### Step 1.4: Start Backend
```bash
npm run dev
```
The backend will now be running:
- **API**: `http://localhost:3000`
- **OCPP WebSocket**: `ws://localhost:9220`
- **OCPP Logs**: `ws://localhost:3001`

---

## 2. Frontend Setup

The Frontend provides the administrative dashboard to manage the CMS.

### Step 2.1: Install Dependencies
```bash
cd ../Frontend
npm install
```

### Step 2.2: Start Frontend
```bash
npm run dev
```
The dashboard will be available at `http://localhost:3002` (standard Next.js port may vary if 3000 is taken).

---

## 3. Initial Data Setup

Since this is a fresh installation, you'll need to create an initial admin user and at least one charging station.

### 3.1 Create Admin User
Use Prisma Studio for a GUI way to add the first user:
```bash
cd Backend
npm run prisma:studio
```
Add a record to the `User` table with `role: "admin"`.

### 3.2 Create Station & Charger
You can use the Dashboard UI once logged in to create your first **Charging Station** and then add **Chargers** to it.

---

## 4. Connecting a Charger

To test the system, connect an OCPP 1.6 charger (or simulator) to:
```
ws://localhost:9220/OCPP/1.6/{chargerId}
```
*Note: `{chargerId}` should match the `charger_id` of a charger you created in the database.*

## Troubleshooting

- **Database Connection**: Ensure PostgreSQL is running and the `DATABASE_URL` is correct.
- **Port Conflicts**: If port 3000, 9220, or 3001 are in use, update the `.env` file in the Backend.
- **Next.js Port**: If the Frontend doesn't open on 3002, check the terminal output for the correct URL.

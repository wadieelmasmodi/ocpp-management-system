-- CreateTable
CREATE TABLE "User" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'admin',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "ChargingStation" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "station_name" TEXT NOT NULL,
    "street_name" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "postal_code" TEXT NOT NULL,
    "latitude" REAL NOT NULL,
    "longitude" REAL NOT NULL,
    "on_site_person_name" TEXT NOT NULL,
    "on_site_contact_details" TEXT NOT NULL,
    "emergency_contact" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'active',
    "owner_id" INTEGER NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "ChargingStation_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Charger" (
    "charger_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "model" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "manufacturer" TEXT NOT NULL,
    "serial_number" TEXT NOT NULL,
    "manufacturing_date" DATETIME NOT NULL,
    "power_capacity" REAL NOT NULL,
    "power_consumption" REAL NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'offline',
    "last_heartbeat" DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00 +00:00',
    "firmware_version" TEXT NOT NULL,
    "warranty_period" TEXT NOT NULL,
    "service_contacts" TEXT NOT NULL,
    "latitude" REAL,
    "longitude" REAL,
    "owner_id" INTEGER NOT NULL,
    "charging_station_id" INTEGER NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Charger_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Charger_charging_station_id_fkey" FOREIGN KEY ("charging_station_id") REFERENCES "ChargingStation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Connector" (
    "connector_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "connector_name" TEXT NOT NULL DEFAULT 'Connector 1',
    "status" TEXT NOT NULL,
    "current_type" TEXT NOT NULL,
    "max_current" REAL,
    "max_power" REAL,
    "mac_address" TEXT,
    "charger_id" INTEGER NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Connector_charger_id_fkey" FOREIGN KEY ("charger_id") REFERENCES "Charger" ("charger_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "RfidUser" (
    "rfid_user_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "rfid_tag" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "company_name" TEXT,
    "address" TEXT,
    "type" TEXT NOT NULL DEFAULT 'postpaid',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "owner_id" INTEGER NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "RfidUser_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "RfidSession" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "transactionId" INTEGER NOT NULL,
    "rfidUserId" INTEGER NOT NULL,
    "charger_id" INTEGER NOT NULL,
    "connectorName" TEXT NOT NULL,
    "startTime" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endTime" DATETIME,
    "initialMeterValue" REAL,
    "finalMeterValue" REAL,
    "energyConsumed" REAL NOT NULL DEFAULT 0,
    "tariffRate" REAL,
    "amountDue" REAL NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'charging',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "RfidSession_charger_id_fkey" FOREIGN KEY ("charger_id") REFERENCES "Charger" ("charger_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "RfidSession_rfidUserId_fkey" FOREIGN KEY ("rfidUserId") REFERENCES "RfidUser" ("rfid_user_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "transactionId" INTEGER NOT NULL,
    "connectorName" TEXT NOT NULL,
    "charger_id" INTEGER NOT NULL,
    "startTime" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endTime" DATETIME,
    "initialMeterValue" REAL,
    "finalMeterValue" REAL,
    "energyConsumed" REAL NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'initiated',
    "idTag" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Transaction_charger_id_fkey" FOREIGN KEY ("charger_id") REFERENCES "Charger" ("charger_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "OcppLog" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "chargerId" INTEGER NOT NULL,
    "transactionId" INTEGER,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "direction" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    CONSTRAINT "OcppLog_chargerId_fkey" FOREIGN KEY ("chargerId") REFERENCES "Charger" ("charger_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Tariff" (
    "tariff_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "tariff_name" TEXT NOT NULL,
    "charge" REAL NOT NULL,
    "electricity_rate" REAL NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "_ChargerToTariff" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,
    CONSTRAINT "_ChargerToTariff_A_fkey" FOREIGN KEY ("A") REFERENCES "Charger" ("charger_id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "_ChargerToTariff_B_fkey" FOREIGN KEY ("B") REFERENCES "Tariff" ("tariff_id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Charger_name_key" ON "Charger"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Charger_serial_number_key" ON "Charger"("serial_number");

-- CreateIndex
CREATE UNIQUE INDEX "RfidUser_rfid_tag_key" ON "RfidUser"("rfid_tag");

-- CreateIndex
CREATE UNIQUE INDEX "RfidSession_transactionId_key" ON "RfidSession"("transactionId");

-- CreateIndex
CREATE UNIQUE INDEX "Tariff_tariff_name_key" ON "Tariff"("tariff_name");

-- CreateIndex
CREATE UNIQUE INDEX "_ChargerToTariff_AB_unique" ON "_ChargerToTariff"("A", "B");

-- CreateIndex
CREATE INDEX "_ChargerToTariff_B_index" ON "_ChargerToTariff"("B");

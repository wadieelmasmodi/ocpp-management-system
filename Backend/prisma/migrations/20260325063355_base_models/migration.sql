/*
  Warnings:

  - Added the required column `password` to the `User` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `User` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "User" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "password" TEXT NOT NULL,
ADD COLUMN     "role" TEXT NOT NULL DEFAULT 'admin',
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- CreateTable
CREATE TABLE "ChargingStation" (
    "id" SERIAL NOT NULL,
    "station_name" TEXT NOT NULL,
    "street_name" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "postal_code" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "on_site_person_name" TEXT NOT NULL,
    "on_site_contact_details" TEXT NOT NULL,
    "emergency_contact" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'active',
    "owner_id" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ChargingStation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Charger" (
    "charger_id" SERIAL NOT NULL,
    "model" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "manufacturer" TEXT NOT NULL,
    "serial_number" TEXT NOT NULL,
    "manufacturing_date" TIMESTAMP(3) NOT NULL,
    "power_capacity" DOUBLE PRECISION NOT NULL,
    "power_consumption" DOUBLE PRECISION NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'offline',
    "last_heartbeat" TIMESTAMP(3) NOT NULL DEFAULT '1970-01-01 00:00:00 +00:00',
    "firmware_version" TEXT NOT NULL,
    "warranty_period" TEXT NOT NULL,
    "service_contacts" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "owner_id" INTEGER NOT NULL,
    "charging_station_id" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Charger_pkey" PRIMARY KEY ("charger_id")
);

-- CreateTable
CREATE TABLE "Connector" (
    "connector_id" SERIAL NOT NULL,
    "connector_name" TEXT NOT NULL DEFAULT 'Connector 1',
    "status" TEXT NOT NULL,
    "current_type" TEXT NOT NULL,
    "max_current" DOUBLE PRECISION,
    "max_power" DOUBLE PRECISION,
    "mac_address" TEXT,
    "charger_id" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Connector_pkey" PRIMARY KEY ("connector_id")
);

-- CreateTable
CREATE TABLE "RfidUser" (
    "rfid_user_id" SERIAL NOT NULL,
    "rfid_tag" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "company_name" TEXT,
    "address" TEXT,
    "type" TEXT NOT NULL DEFAULT 'postpaid',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "owner_id" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RfidUser_pkey" PRIMARY KEY ("rfid_user_id")
);

-- CreateTable
CREATE TABLE "RfidSession" (
    "id" SERIAL NOT NULL,
    "transactionId" INTEGER NOT NULL,
    "rfidUserId" INTEGER NOT NULL,
    "charger_id" INTEGER NOT NULL,
    "connectorName" TEXT NOT NULL,
    "startTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endTime" TIMESTAMP(3),
    "initialMeterValue" DOUBLE PRECISION,
    "finalMeterValue" DOUBLE PRECISION,
    "energyConsumed" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "tariffRate" DOUBLE PRECISION,
    "amountDue" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'charging',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RfidSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" SERIAL NOT NULL,
    "transactionId" INTEGER NOT NULL,
    "connectorName" TEXT NOT NULL,
    "charger_id" INTEGER NOT NULL,
    "startTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endTime" TIMESTAMP(3),
    "initialMeterValue" DOUBLE PRECISION,
    "finalMeterValue" DOUBLE PRECISION,
    "energyConsumed" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'initiated',
    "idTag" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OcppLog" (
    "id" SERIAL NOT NULL,
    "chargerId" INTEGER NOT NULL,
    "transactionId" INTEGER,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "direction" TEXT NOT NULL,
    "message" TEXT NOT NULL,

    CONSTRAINT "OcppLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Tariff" (
    "tariff_id" SERIAL NOT NULL,
    "tariff_name" TEXT NOT NULL,
    "charge" DOUBLE PRECISION NOT NULL,
    "electricity_rate" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Tariff_pkey" PRIMARY KEY ("tariff_id")
);

-- CreateTable
CREATE TABLE "_ChargerToTariff" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,

    CONSTRAINT "_ChargerToTariff_AB_pkey" PRIMARY KEY ("A","B")
);

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
CREATE INDEX "_ChargerToTariff_B_index" ON "_ChargerToTariff"("B");

-- AddForeignKey
ALTER TABLE "ChargingStation" ADD CONSTRAINT "ChargingStation_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Charger" ADD CONSTRAINT "Charger_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Charger" ADD CONSTRAINT "Charger_charging_station_id_fkey" FOREIGN KEY ("charging_station_id") REFERENCES "ChargingStation"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Connector" ADD CONSTRAINT "Connector_charger_id_fkey" FOREIGN KEY ("charger_id") REFERENCES "Charger"("charger_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RfidUser" ADD CONSTRAINT "RfidUser_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RfidSession" ADD CONSTRAINT "RfidSession_charger_id_fkey" FOREIGN KEY ("charger_id") REFERENCES "Charger"("charger_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RfidSession" ADD CONSTRAINT "RfidSession_rfidUserId_fkey" FOREIGN KEY ("rfidUserId") REFERENCES "RfidUser"("rfid_user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_charger_id_fkey" FOREIGN KEY ("charger_id") REFERENCES "Charger"("charger_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OcppLog" ADD CONSTRAINT "OcppLog_chargerId_fkey" FOREIGN KEY ("chargerId") REFERENCES "Charger"("charger_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ChargerToTariff" ADD CONSTRAINT "_ChargerToTariff_A_fkey" FOREIGN KEY ("A") REFERENCES "Charger"("charger_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ChargerToTariff" ADD CONSTRAINT "_ChargerToTariff_B_fkey" FOREIGN KEY ("B") REFERENCES "Tariff"("tariff_id") ON DELETE CASCADE ON UPDATE CASCADE;

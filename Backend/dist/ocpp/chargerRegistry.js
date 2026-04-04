import { logger } from "../utils/logger.js";
class ChargerRegistry {
    chargers = new Map();
    offlineMonitorInterval = null;
    offlineThreshold;
    constructor(offlineThresholdSeconds = 60) {
        this.offlineThreshold = offlineThresholdSeconds * 1000;
        this.startOfflineMonitor();
    }
    /**
     * Register a new charger connection
     */
    register(chargerId, chargerName, ws) {
        const connection = {
            chargerId,
            ws,
            chargerName,
            connectedAt: new Date(),
            lastHeartbeat: new Date(),
            transactions: new Map(),
        };
        this.chargers.set(chargerId, connection);
        logger.info(`Charger registered: ${chargerName} (ID: ${chargerId})`);
    }
    /**
     * Unregister a charger (disconnected)
     */
    unregister(chargerId) {
        const connection = this.chargers.get(chargerId);
        if (connection) {
            this.chargers.delete(chargerId);
            logger.info(`Charger unregistered: ${connection.chargerName} (ID: ${chargerId})`);
        }
    }
    /**
     * Get a charger connection by ID
     */
    getConnection(chargerId) {
        return this.chargers.get(chargerId);
    }
    /**
     * Check if a charger is connected
     */
    isConnected(chargerId) {
        return this.chargers.has(chargerId);
    }
    /**
     * Update charger's last heartbeat timestamp
     */
    updateHeartbeat(chargerId) {
        const connection = this.chargers.get(chargerId);
        if (connection) {
            connection.lastHeartbeat = new Date();
        }
    }
    /**
     * Start an active transaction for a charger
     */
    startTransaction(chargerId, transactionId, connectorName, idTag) {
        const connection = this.chargers.get(chargerId);
        if (connection) {
            connection.transactions.set(transactionId, {
                transactionId,
                connectorName,
                idTag,
                startTime: new Date(),
                initialMeterValue: 0,
            });
        }
    }
    /**
     * End a transaction for a charger
     */
    endTransaction(chargerId, transactionId) {
        const connection = this.chargers.get(chargerId);
        if (connection) {
            const transaction = connection.transactions.get(transactionId);
            connection.transactions.delete(transactionId);
            return transaction;
        }
        return undefined;
    }
    /**
     * Get active transaction for a charger
     */
    getTransaction(chargerId, transactionId) {
        const connection = this.chargers.get(chargerId);
        if (connection) {
            return connection.transactions.get(transactionId);
        }
        return undefined;
    }
    /**
     * Send OCPP message to a charger
     */
    async sendToCharger(chargerId, message) {
        const connection = this.chargers.get(chargerId);
        if (!connection) {
            throw new Error(`Charger ${chargerId} is not connected`);
        }
        // Lazily import to avoid circular dependency
        const { logOcppMessage } = await import("./messageHandlers.js");
        return new Promise((resolve, reject) => {
            connection.ws.send(JSON.stringify(message), (error) => {
                if (error) {
                    reject(error);
                }
                else {
                    // Log outgoing message correctly formatted for WebSocket clients
                    logOcppMessage(chargerId, "out", message).catch(err => logger.error(`Failed to broadcast logged msg: ${err}`));
                    resolve(message);
                }
            });
        });
    }
    /**
     * Get all connected charger IDs
     */
    getConnectedChargers() {
        return Array.from(this.chargers.keys());
    }
    /**
     * Get connection count
     */
    getConnectionCount() {
        return this.chargers.size;
    }
    /**
     * Start monitoring for offline chargers
     */
    startOfflineMonitor() {
        this.offlineMonitorInterval = setInterval(() => {
            const now = Date.now();
            for (const [chargerId, connection] of this.chargers) {
                const timeSinceHeartbeat = now - connection.lastHeartbeat.getTime();
                if (timeSinceHeartbeat > this.offlineThreshold) {
                    logger.warn(`Charger ${connection.chargerName} (ID: ${chargerId}) appears to be offline. Last heartbeat: ${connection.lastHeartbeat.toISOString()}`);
                    // Note: We don't automatically unregister; let the system handle via DB update
                }
            }
        }, 10000); // Check every 10 seconds
    }
    /**
     * Stop the offline monitor
     */
    stopOfflineMonitor() {
        if (this.offlineMonitorInterval) {
            clearInterval(this.offlineMonitorInterval);
            this.offlineMonitorInterval = null;
        }
    }
    /**
     * Clear all connections
     */
    clear() {
        this.chargers.clear();
    }
}
// Singleton instance
export const chargerRegistry = new ChargerRegistry();

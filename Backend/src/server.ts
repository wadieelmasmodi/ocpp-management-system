import "dotenv/config";
import { startServers } from "./app.js";
import { logger } from "./utils/logger.js";

// Start all servers
startServers();

logger.info("Starting Open-Source OCPP CMS...");

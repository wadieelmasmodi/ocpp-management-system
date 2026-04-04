import { logger } from "../utils/logger.js";
/**
 * Global error handler middleware
 */
export function errorHandler(err, req, res, next) {
    logger.error(`Error: ${err.message}`, { stack: err.stack });
    const statusCode = err.statusCode || 500;
    const message = err.isOperational ? err.message : "Internal server error";
    res.status(statusCode).json({
        success: false,
        error: message,
        ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
    });
}
/**
 * Not found handler
 */
export function notFoundHandler(req, res) {
    res.status(404).json({
        success: false,
        error: `Route ${req.method} ${req.path} not found`,
    });
}

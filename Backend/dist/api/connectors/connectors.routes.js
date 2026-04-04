import { Router } from "express";
import { getAllConnectors, getConnectorById, createConnector, updateConnector, deleteConnector, } from "./connectors.controller.js";
const router = Router();
router.get("/", getAllConnectors);
router.get("/:id", getConnectorById);
router.post("/", createConnector);
router.put("/:id", updateConnector);
router.delete("/:id", deleteConnector);
export default router;

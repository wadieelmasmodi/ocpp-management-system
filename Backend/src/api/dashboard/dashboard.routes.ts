import { Router } from "express";
import {
  getOverview,
  getLiveSessions,
  getDistribution,
  getChargersStatus,
} from "./dashboard.controller.js";

const router = Router();

router.get("/overview", getOverview);
router.get("/live-sessions", getLiveSessions);
router.get("/distribution", getDistribution);
router.get("/chargers-status", getChargersStatus);

export default router;

import { Router } from "express";
import {
  getAllRfidUsers,
  getRfidUserById,
  createRfidUser,
  updateRfidUser,
  toggleRfidUserStatus,
  deleteRfidUser,
} from "./rfid.controller.js";

const router = Router();

router.get("/", getAllRfidUsers);
router.get("/:id", getRfidUserById);
router.post("/", createRfidUser);
router.put("/:id", updateRfidUser);
router.patch("/:id/toggle", toggleRfidUserStatus);
router.delete("/:id", deleteRfidUser);

export default router;

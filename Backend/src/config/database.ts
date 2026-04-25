import "dotenv/config";
import { PrismaClient } from "../../generated/prisma/index.js";

export const prisma = new PrismaClient();

// Graceful shutdown handler
process.on("beforeExit", async () => {
  await prisma.$disconnect();
});

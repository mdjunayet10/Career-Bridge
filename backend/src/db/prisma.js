const { PrismaClient } = require("@prisma/client");

if (!process.env.DATABASE_URL && process.env.NODE_ENV !== "production") {
  process.env.DATABASE_URL =
    "postgresql://career_bridge:career_bridge_password@localhost:5432/career_bridge?schema=public";
}

const prisma = new PrismaClient({
  log: process.env.PRISMA_LOG === "true" ? ["query", "warn", "error"] : ["error"]
});

module.exports = prisma;

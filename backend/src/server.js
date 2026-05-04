const path = require("path");

require("dotenv").config({ path: path.resolve(__dirname, "../.env") });

const createApp = require("./app");
const prisma = require("./db/prisma");

const port = process.env.PORT || 4000;
const app = createApp();

const server = app.listen(port, () => {
  console.log(`Career Bridge backend running at http://localhost:${port}`);
});

server.on("error", async (error) => {
  if (error.code === "EADDRINUSE") {
    console.error(`Port ${port} is already in use. Stop the other backend process or set PORT to another value.`);
  } else {
    console.error("Career Bridge backend failed to start:", error);
  }

  await prisma.$disconnect();
  process.exit(1);
});

let isShuttingDown = false;

async function shutdown(signal) {
  if (isShuttingDown) {
    return;
  }

  isShuttingDown = true;
  console.log(`${signal} received. Closing Career Bridge backend...`);
  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));

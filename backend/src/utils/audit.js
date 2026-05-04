const prisma = require("../db/prisma");

async function writeAuditLog({ actorUserId, action, targetType, targetId = null, metadata = null }) {
  try {
    await prisma.auditLog.create({
      data: {
        actorUserId: actorUserId || null,
        action,
        targetType,
        targetId,
        metadata
      }
    });
  } catch (error) {
    console.error("Audit log write failed:", error);
  }
}

module.exports = {
  writeAuditLog
};

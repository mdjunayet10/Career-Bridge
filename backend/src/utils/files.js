const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const multer = require("multer");
const { createError } = require("./apiError");
const { isSafePath } = require("./fileCleanup");

const uploadDirectory = path.resolve(__dirname, "../../uploads");

fs.mkdirSync(uploadDirectory, { recursive: true });

// TODO: Move resume storage to S3, Supabase Storage, Firebase Storage, or Cloudinary
// before production deployment so app servers stay stateless.
const allowedMimeTypesByExtension = {
  ".pdf": new Set(["application/pdf"]),
  ".doc": new Set(["application/msword"]),
  ".docx": new Set(["application/vnd.openxmlformats-officedocument.wordprocessingml.document"])
};

const allowedExtensions = new Set(Object.keys(allowedMimeTypesByExtension));

const storage = multer.diskStorage({
  destination: (_req, _file, callback) => {
    callback(null, uploadDirectory);
  },
  filename: (_req, file, callback) => {
    const extension = path.extname(file.originalname || "").toLowerCase();
    const uniqueName = `${Date.now()}-${crypto.randomUUID()}${extension}`;
    callback(null, uniqueName);
  }
});

function getMaxUploadBytes() {
  const mb = Number(process.env.MAX_CV_UPLOAD_MB || 5);
  const safeMb = Number.isFinite(mb) && mb > 0 ? mb : 5;
  return safeMb * 1024 * 1024;
}

const uploadResume = multer({
  storage,
  limits: {
    fileSize: getMaxUploadBytes()
  },
  fileFilter: (_req, file, callback) => {
    const extension = path.extname(file.originalname || "").toLowerCase();
    const mimeType = String(file.mimetype || "").toLowerCase();
    const allowedMimeTypes = allowedMimeTypesByExtension[extension];

    if (allowedExtensions.has(extension) && allowedMimeTypes?.has(mimeType)) {
      callback(null, true);
      return;
    }

    callback(createError(400, "Only PDF, DOC, or DOCX files are allowed for CV uploads."));
  }
});

function removeUploadedFile(file) {
  if (!file?.path) {
    return;
  }

  fs.unlink(file.path, () => {
    // Best effort cleanup for rejected uploads.
  });
}

function getResumePath(storageName) {
  const safeName = path.basename(String(storageName || ""));
  const absolutePath = path.resolve(uploadDirectory, safeName);

  if (!safeName || !isSafePath(uploadDirectory, absolutePath)) {
    return "";
  }

  return absolutePath;
}

function sanitizeDownloadFileName(value) {
  return String(value || "resume")
    .replace(/[\r\n\t]/g, " ")
    .replaceAll('"', "")
    .trim() || "resume";
}

module.exports = {
  getResumePath,
  removeUploadedFile,
  sanitizeDownloadFileName,
  uploadDirectory,
  uploadResume
};

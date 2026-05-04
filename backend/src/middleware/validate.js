const { ZodError } = require("zod");
const { createError } = require("../utils/apiError");

function formatZodIssues(error) {
  return error.issues.map((issue) => ({
    path: issue.path.join("."),
    message: issue.message
  }));
}

function validateBody(schema) {
  return (req, _res, next) => {
    const result = schema.safeParse(req.body || {});

    if (!result.success) {
      next(createError(400, "Validation failed", formatZodIssues(result.error)));
      return;
    }

    req.body = result.data;
    next();
  };
}

function validateQuery(schema) {
  return (req, _res, next) => {
    const result = schema.safeParse(req.query || {});

    if (!result.success) {
      next(createError(400, "Validation failed", formatZodIssues(result.error)));
      return;
    }

    req.query = result.data;
    next();
  };
}

function isZodError(error) {
  return error instanceof ZodError;
}

module.exports = {
  isZodError,
  validateBody,
  validateQuery
};

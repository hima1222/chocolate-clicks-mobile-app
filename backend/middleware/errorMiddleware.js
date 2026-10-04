const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || (res.statusCode === 200 ? 500 : res.statusCode);

  if (err.name === 'CastError') {
    statusCode = 400;
  }
  if (err.name === 'ValidationError') {
    statusCode = 400;
  }

  res.status(statusCode).json({
    message: err.message || 'Server Error',
  });
};

const createError = (message, statusCode = 500) => {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
};

module.exports = errorHandler;
module.exports.createError = createError;

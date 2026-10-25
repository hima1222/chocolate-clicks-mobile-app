const { createError } = require('./errorMiddleware');

const adminOnly = (req, res, next) => {
  if (req.user?.role !== 'admin') {
    return next(createError('Administrator access required', 403));
  }
  next();
};

module.exports = { adminOnly };

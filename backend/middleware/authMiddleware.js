const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { createError } = require('./errorMiddleware');

const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer ')
  ) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const secret = process.env.JWT_SECRET;
      if (!secret) {
        throw new Error('JWT_SECRET is not defined');
      }

      const decoded = jwt.verify(token, secret);
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return next(createError('User not found', 401));
      }

      next();
    } catch (error) {
      return next(createError('Not authorized, invalid token', 401));
    }
  } else {
    return next(createError('Not authorized, token missing', 401));
  }
};

module.exports = { protect };

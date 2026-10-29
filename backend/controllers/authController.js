const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const crypto = require('crypto');
const sendEmail = require('../utils/sendEmail');
const { OAuth2Client } = require('google-auth-library');

const googleClient = new OAuth2Client(process.env.GOOGLE_WEB_CLIENT_ID);

const googleConfig = (req, res) => {
  const clientId = (process.env.GOOGLE_WEB_CLIENT_ID || '').trim();
  if (!clientId.endsWith('.apps.googleusercontent.com')) {
    return res.status(503).json({ success: false, message: 'Google sign-in is not configured on the server.' });
  }
  // OAuth client IDs are public. Never return client secrets or other env values.
  return res.json({ success: true, data: { clientId } });
};

const hashCode = (code) =>
  crypto.createHash('sha256').update(String(code)).digest('hex');

const register = async (req, res, next) => {
  try {
    const { firstName, lastName, email, phone, password } = req.body;

    if (!firstName || !lastName || !email || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide firstName, lastName, email, phone, and password',
      });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this email',
      });
    }

    const user = await User.create({
      firstName,
      lastName,
      email,
      phone,
      password,
    });

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: user.toJSON(),
        token: generateToken(user._id),
      },
    });
  } catch (error) {
    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
    }

    const user = await User.findOne({ email });
    if (!user || !(await user.matchPassword(password))) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    return res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: user.toJSON(),
        token: generateToken(user._id),
      },
    });
  } catch (error) {
    next(error);
  }
};

const googleLogin = async (req, res, next) => {
  try {
    const clientId = (process.env.GOOGLE_WEB_CLIENT_ID || '').trim();
    if (!clientId.endsWith('.apps.googleusercontent.com')) {
      return res.status(503).json({ success: false, message: 'Google sign-in is not configured on the server.' });
    }
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: 'Google idToken is required',
      });
    }

    // Verify the token with Google (a failure here means a bad token, not a server error)
    let payload;
    try {
      const ticket = await googleClient.verifyIdToken({
        idToken,
        audience: clientId,
      });
      payload = ticket.getPayload();
    } catch (err) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Google token',
      });
    }

    if (!payload.email_verified) {
      return res.status(401).json({
        success: false,
        message: 'Google email is not verified',
      });
    }

    const email = payload.email.toLowerCase();
    let user = await User.findOne({ $or: [{ googleId: payload.sub }, { email }] });

    if (!user) {
      user = await User.create({
        googleId: payload.sub,
        email,
        firstName: payload.given_name || payload.name || 'User',
        lastName: payload.family_name || '',
        profileImageUrl: payload.picture,
        isEmailVerified: true,
      });
    } else if (!user.googleId) {
      // existing email/password account: link it to Google
      user.googleId = payload.sub;
      user.isEmailVerified = true;
      if (!user.profileImageUrl) user.profileImageUrl = payload.picture;
      await user.save();
    }

    return res.json({
      success: true,
      message: 'Google login successful',
      data: {
        user: user.toJSON(),
        token: generateToken(user._id),
      },
    });
  } catch (error) {
    next(error);
  }
};

const getMe = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, data: req.user });
  } catch (error) {
    next(error);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const { firstName, lastName, phone, profileImageUrl } = req.body;

    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Not authorized' });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.firstName = firstName || user.firstName;
    user.lastName = lastName || user.lastName;
    user.phone = phone || user.phone;
    user.profileImageUrl = profileImageUrl || user.profileImageUrl;

    await user.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: user.toJSON(),
    });
  } catch (error) {
    next(error);
  }
};

const forgotPassword = async (req, res, next) => {
  try {
    const email = req.body.email?.toLowerCase().trim();
    const genericReply = {
      success: true,
      message: 'If the email exists, a reset code has been sent',
    };

    if (!email) return res.json(genericReply);

    const user = await User.findOne({ email });
    if (!user) return res.json(genericReply);

    const code = crypto.randomInt(100000, 1000000).toString();

    user.resetCodeHash = hashCode(code);
    user.resetCodeExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 min
    user.resetCodeAttempts = 0;
    await user.save();

    await sendEmail({
      to: user.email,
      subject: 'Your password reset code',
      text: `Your reset code is ${code}. It expires in 10 minutes. If you did not request this, ignore this email.`,
    });

    return res.json(genericReply);
  } catch (error) {
    next(error);
  }
};

const resetPassword = async (req, res, next) => {
  try {
    const email = req.body.email?.toLowerCase().trim();
    const { code, password } = req.body;

    if (!email || !code || !password || password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Email, code and a password of at least 6 characters are required',
      });
    }

    const user = await User.findOne({ email }).select(
      '+resetCodeHash +resetCodeExpires +resetCodeAttempts'
    );

    const invalid = () =>
      res.status(400).json({
        success: false,
        message: 'Reset code is invalid or expired',
      });

    if (!user || !user.resetCodeHash || user.resetCodeExpires < new Date()) {
      return invalid();
    }

    if (user.resetCodeAttempts >= 5) {
      return res.status(429).json({
        success: false,
        message: 'Too many attempts. Please request a new code',
      });
    }

    if (user.resetCodeHash !== hashCode(code)) {
      user.resetCodeAttempts += 1;
      await user.save();
      return invalid();
    }

    user.password = password; // User.js has a pre('save') bcrypt hook

    user.resetCodeHash = undefined;
    user.resetCodeExpires = undefined;
    user.resetCodeAttempts = 0;
    await user.save();

    return res.json({ success: true, message: 'Password reset successfully' });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  googleLogin,
  googleConfig,
  getMe,
  updateProfile, 
  forgotPassword, 
  resetPassword
};

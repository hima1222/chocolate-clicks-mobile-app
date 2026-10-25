const Notification = require('../models/Notification');
const User = require('../models/User');

const notifyUser = (userId, notification) =>
  Notification.create({ ...notification, user: userId });

const notifyAllUsers = async (notification) => {
  const users = await User.find({}, '_id').lean();
  if (users.length === 0) return [];

  return Notification.insertMany(
    users.map(({ _id }) => ({ ...notification, user: _id }))
  );
};

module.exports = { notifyUser, notifyAllUsers };

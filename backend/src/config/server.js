module.exports = {
  port: parseInt(process.env.PORT || '3000'),
  jwtSecret: process.env.JWT_SECRET || 'dev-secret-change-in-production',
  jwtExpiresIn: '7d',
  corsOrigin: process.env.CORS_ORIGIN || '*',
};

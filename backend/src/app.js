const express = require('express');
const cors = require('cors');
const config = require('./config/server');

const app = express();

app.use(cors({ origin: config.corsOrigin }));
app.use(express.json());

// Routes
// app.use('/api/v1/auth', require('./routes/auth'));
// app.use('/api/v1/businesses', require('./routes/businesses'));
// app.use('/api/v1/products', require('./routes/products'));
// app.use('/api/v1/sales', require('./routes/sales'));
// app.use('/api/v1/stock', require('./routes/stock'));
// app.use('/api/v1/reports', require('./routes/reports'));
// app.use('/api/v1/sync', require('./routes/sync'));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', version: '0.1.0' });
});

module.exports = app;

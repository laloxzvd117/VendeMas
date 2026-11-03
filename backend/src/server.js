const app = require('./app');
const config = require('./config/server');

app.listen(config.port, () => {
  console.log(`VendeMas API running on port ${config.port}`);
});

const defaultCityFees = require('./delivery-city-fees.json');
const { createError } = require('../middleware/errorMiddleware');

function parseCityFees(value = process.env.DELIVERY_CITY_FEES) {
  if (value == null || value.trim() === '') return { ...defaultCityFees };
  let raw = value.trim();
  if (raw.startsWith("'") && raw.endsWith("'")) raw = raw.slice(1, -1).trim();
  let fees;
  try {
    try { fees = JSON.parse(raw); }
    catch (_) {
      // Support old flat tables whose city-name quotes were stripped by a shell.
      // Quote keys only, then use JSON.parse; never evaluate configuration as code.
      const normalized = raw.replace(/([{,]\s*)([A-Za-z][A-Za-z0-9 ._-]*?)\s*:/g,
        (_, prefix, city) => prefix + JSON.stringify(city.trim()) + ':');
      fees = JSON.parse(normalized);
    }
    // Some hosting dashboards store a JSON-encoded string instead of an object.
    if (typeof fees === 'string') fees = JSON.parse(fees);
    if (!fees || typeof fees !== 'object' || Array.isArray(fees)) throw new Error();
    for (const [city, fee] of Object.entries(fees)) {
      if (!city.trim() || !['number', 'string'].includes(typeof fee) || String(fee).trim() === '' ||
          !Number.isFinite(Number(fee)) || Number(fee) < 0) throw new Error();
    }
  } catch (_) {
    throw createError('Invalid DELIVERY_CITY_FEES configuration. Use a JSON object with city names and numeric fees, or remove this override to use the delivery rate file.', 503);
  }
  return fees;
}
module.exports = { parseCityFees };

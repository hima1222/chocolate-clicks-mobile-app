const { parseCityFees } = require('../config/deliveryConfig');
test('valid JSON and dotenv-wrapped JSON preserve area fees', () => {
  for (const value of ['{"Colombo 06":300,"Mount Lavinia":500}', '\'{"Colombo 06":300,"Mount Lavinia":500}\'']) {
    expect(parseCityFees(value)).toEqual({ 'Colombo 06': 300, 'Mount Lavinia': 500 });
  }
});
test('legacy unquoted city names are normalized without changing fees', () => {
  expect(parseCityFees('{Colombo:300,Colombo 06:300,Mount Lavinia:500,Maharagama:700}'))
    .toEqual({ Colombo: 300, 'Colombo 06': 300, 'Mount Lavinia': 500, Maharagama: 700 });
});
test('JSON-encoded dashboard strings are accepted', () => {
  expect(parseCityFees(JSON.stringify('{"Colombo 06":300}'))).toEqual({ 'Colombo 06': 300 });
});
test('missing override uses the versioned city table', () => {
  expect(parseCityFees('')['Colombo 06']).toBe(300);
  expect(parseCityFees('')['Maharagama']).toBe(700);
});
test.each(['null', '[]', '{broken}', '{"Colombo":null}', '{"Colombo":true}', '{"Colombo":-1}', '{"Colombo":""}', '{"Colombo":{}}'])('rejects invalid configuration %s without hiding mistakes', (value) => {
  expect(() => parseCityFees(value)).toThrow('Invalid DELIVERY_CITY_FEES configuration');
});

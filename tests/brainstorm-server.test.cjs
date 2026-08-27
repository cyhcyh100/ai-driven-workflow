const test = require('node:test');
const assert = require('node:assert/strict');

const server = require('../skills/brainstorming/scripts/server.cjs');
const helper = require('../skills/brainstorming/scripts/helper.js');

function maskedTextFrame(text) {
  const payload = Buffer.from(text);
  const mask = Buffer.from([0x12, 0x34, 0x56, 0x78]);
  const header = Buffer.from([0x81, 0x80 | payload.length]);
  const masked = Buffer.alloc(payload.length);
  for (let i = 0; i < payload.length; i += 1) {
    masked[i] = payload[i] ^ mask[i % mask.length];
  }
  return Buffer.concat([header, mask, masked]);
}

test('computes the RFC 6455 accept key', () => {
  assert.equal(
    server.computeAcceptKey('dGhlIHNhbXBsZSBub25jZQ=='),
    's3pPLMBiTxaQ9kYGzzhZRbK+xOo='
  );
});

test('decodes a masked client text frame', () => {
  const decoded = server.decodeFrame(maskedTextFrame('hello'));
  assert.equal(decoded.opcode, server.OPCODES.TEXT);
  assert.equal(decoded.payload.toString(), 'hello');
  assert.equal(decoded.bytesConsumed, 11);
});

test('rejects an unmasked client frame', () => {
  const frame = server.encodeFrame(server.OPCODES.TEXT, Buffer.from('hello'));
  assert.throws(() => server.decodeFrame(frame), /must be masked/);
});

test('caps reconnect backoff', () => {
  assert.equal(helper.nextReconnectDelay(500, 30_000), 1_000);
  assert.equal(helper.nextReconnectDelay(20_000, 30_000), 30_000);
});

test('uses argv-based browser launchers', () => {
  assert.deepEqual(
    server.browserLauncherForPlatform('http://localhost:1234', {
      platform: 'darwin',
      osRelease: '',
      env: {},
    }),
    { bin: 'open', args: ['http://localhost:1234'] }
  );
});

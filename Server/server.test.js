import { WebSocket } from 'ws';
import { wss, connect_to_chat, shutdownServer } from './index.js';
import { DataType } from './utils.js';

let client;

beforeAll((done) => {
    client = new WebSocket('ws://localhost:3000');
    client.on('open', () => {
        console.log('WebSocket opened');
        done();
    });
})
afterAll(() => {
    shutdownServer();
});

test('something', (done) => {
    client.on('message', (data) => {
        try {
            const decoder = new TextDecoder();
            console.log('Message received:', decoder.decode(data));
            expect(true).toBe(true);
            done();
        } catch (error) {
            done(error);
        }
    });
    client.on('error', (err) => {
        done(err);
    });

    client.send(JSON.stringify({"type": 99}));
});
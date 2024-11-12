import { WebSocket } from 'ws';
import { shutdownServer, runServer } from './server.js';

xdescribe('Server testing', () => {
    let client;
    beforeAll((done) => {
        runServer()
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
});
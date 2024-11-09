import { WebSocketServer } from 'ws';
const wss = new WebSocketServer({"port": 3000});

wss.on('connection', function connection(ws, req) {
    console.log("A connection established")
    
    ws.on('error', console.error);
    ws.on('message', function message(data) {
        const decoder = new TextDecoder();
        console.log('received: ', decoder.decode(data));
    })
    const obj = {"test": "aaaa"};
    const str = JSON.stringify(obj);
    ws.send(new TextEncoder().encode(str));
});
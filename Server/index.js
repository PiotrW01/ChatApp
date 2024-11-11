import { WebSocketServer } from 'ws';
import { createServer } from 'http';
import express from 'express';
import { makeid, DataType } from './utils.js';

const app = express()
const server = createServer(app)
const wss = new WebSocketServer({"server": server});
const usersMap = new Map();

wss.on('connection', function connection(ws, req) {
    ws.on('error', console.error);
    ws.on('message', function message(data) {
        const decoder = new TextDecoder();
        data = JSON.parse(decoder.decode(data));
        switch(data.type){
            case DataType.MESSAGE:
                if(verifyUserID(ws, data.session_id));
                broadcastMessage(usersMap.get(ws).username, data.message);
                break;
            case DataType.LOGIN:
                connectToChat(ws, data);
                break;
            default:
                console.log("Received data with wrong type: ", data.type);
                ws.send("error");
                break;
        }
    });
    ws.on('close', (code, reason) => {
        if(usersMap.has(ws)){
            broadcastUserDisconnected(usersMap.get(ws).username);
        }
        usersMap.delete(ws);
    });

});

server.listen(3000, () => { 
});

/*
setTimeout(function messageClients() {
    wss.clients.forEach(ws => {
        const obj = {
            "type": "message",
            "username": makeid(5),
            "message": "hello from server!",
        };
        const str = JSON.stringify(obj);
        ws.send(new TextEncoder().encode(str));
    });
    setTimeout(messageClients, 1000);
}, 1000); */

function broadcastMessage(username, message){
    const res = {
        "type": DataType.MESSAGE,
        "username": username,
        "message": message,
    }
    const str = JSON.stringify(res);
    usersMap.forEach((_, ws) => {
        ws.send(str);
    })
}

function broadcastUserConnected(username){
    const res = {"type": DataType.USER_CONNECTED, "username": username};
    wss.clients.forEach(ws => {
        ws.send(JSON.stringify(res));
    });
}

function broadcastUserDisconnected(username){
    const res = {"type": DataType.USER_DISCONNECTED, "username": username};
    wss.clients.forEach(ws => {
        ws.send(JSON.stringify(res));
    });
}

function connectToChat(ws, data){
    for (const user of usersMap.values()) {
        if(user.username == data.username){
            console.log("Username taken!");
            return;
        }
    }
    const id = makeid(12);
    usersMap.set(ws, {"session_id": id, "username": data.username,});

    const users = [];
    usersMap.forEach((user) => {
        users.push(user.username);
    });

    const res = {"type": DataType.LOGIN, "session_id": id, "users": users};
    ws.send(JSON.stringify(res));

    broadcastUserConnected(data.username);
}

function verifyUserID(ws, session_id){
    const user = usersMap.get(ws);
    if(session_id != user.session_id){
        console.log("id's don't match!");
        return false;
    }
    return true;
}

function shutdownServer() {
    wss.clients.forEach(client => client.close());
    wss.close(() => {
        server.close();
    });
}

export { wss, usersMap, shutdownServer}
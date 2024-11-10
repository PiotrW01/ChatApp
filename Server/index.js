//const express = require('express');
import { WebSocketServer } from 'ws';
import { createServer } from 'http';
import express from 'express';

const app = express()
const server = createServer(app)
const wss = new WebSocketServer({"server": server,});

const connectedUsers = [];
const usersHash = {};

wss.on('connection', function connection(ws, req) {
    ws.on('error', console.error);
    ws.on('message', function message(data) {
        const decoder = new TextDecoder();
        data = JSON.parse(decoder.decode(data));
        switch(data.type){
            case "message":
                broadcast_message(data.session_id, data.message);
                break;
            default:
                console.log("Received data with wrong type: ", data.type);
                break;
        }
    })
    ws.on('close', (code, reason) => {
        broadcast_user_disconnected(usersHash[ws]);
        const index = connectedUsers.indexOf(usersHash[ws]);
        if(index > -1) {
            connectedUsers.splice(index, 1);
        }
    });

    initialize_client(ws);
});

app.get('/', (req,res) => {
    res.send("aaa");
})


server.listen(3000);

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


function makeid(length) {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    let counter = 0;
    while (counter < length) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
      counter += 1;
    }
    return result;
}

function broadcast_message(username, message){
    const obj = {
        "type": "message",
        "username": username,
        "message": message,
    }
    const str = JSON.stringify(obj);
    wss.clients.forEach(ws => {
        ws.send(str)
    })
}

function broadcast_user_connected(id){
    const str = JSON.stringify({"type": "user_connected", "session_id": id});
    wss.clients.forEach(ws => {
        ws.send(str);
    });
}

function broadcast_user_disconnected(id){
    const str = JSON.stringify({"type": "user_disconnected", "session_id": id});
    wss.clients.forEach(ws => {
        ws.send(str);
    });
}


function initialize_client(ws){
    const id = makeid(8);
    const obj = {
        "type": "initialize",
        "session_id": id,
        "users": connectedUsers,
    }
    ws.send(JSON.stringify(obj));
    connectedUsers.push(id);
    usersHash[ws] = id;
    broadcast_user_connected(id);
}
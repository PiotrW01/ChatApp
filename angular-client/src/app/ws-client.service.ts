import { Injectable } from '@angular/core';
import { DataType } from './data-type';
import { max, Observable, Subject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class WsClientService {
  
  ip: string = 'ws://localhost:3000';
  socket!: WebSocket;
  sessionId!: string;
  messageSubject = new Subject<any>();
  connect_timeout_seconds = 5;

  constructor() {}


  sendData(data: object){
    this.socket.send(JSON.stringify(data));
  }

  sendMessage(msg: string){
    var data = {
      "type": DataType.MESSAGE,
      "session_id": this.sessionId,
      "message": msg,
    }
    this.socket.send(JSON.stringify(data));
  }

  login(username: string){
    if(username.length > 3){
      var data = {
        "type": DataType.LOGIN,
        "username": username,
      }
      this.socket.send(JSON.stringify(data));
    }
  }

  connect(){
    this.socket = new WebSocket(this.ip);
    this.socket.addEventListener('open', () => {
      this.messageSubject.next({"type": DataType.CONNECTED});
      console.log("connected!");
      this.connect_timeout_seconds = 5;
    })
    this.socket.addEventListener('message', (data: any) => {
      data = JSON.parse(data.data);
      if (data.type == DataType.LOGIN){
        this.sessionId = data.session_id
        console.log("Logged in! Session id: ", this.sessionId);
      }
      this.messageSubject.next(data);
    })

    this.socket.addEventListener('close', () => {
      var data = {
        "type": DataType.DISCONNECTED,
      }
      this.messageSubject.next(data);
      setTimeout(this.connect.bind(this), this.connect_timeout_seconds * 1000);
    })
  }

  get messages$(): Observable<any> {
    return this.messageSubject.asObservable();
  }
}


import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';

export class DataType {
  static INIT = 0;
  static MESSAGE = 1;
  static LOGIN = 2;
  static USER_CONNECTED = 3;
  static USER_DISCONNECTED = 4; 
}

bootstrapApplication(AppComponent, appConfig)
  .catch((err) => console.error(err));

const socket = new WebSocket("ws://localhost:3000");

socket.addEventListener('open', () => {
  console.log("connected!");
  socket.send(JSON.stringify({"type": DataType.LOGIN, "username": "glob"}));
})

socket.addEventListener('message', (data) => {
  console.log(data);
})



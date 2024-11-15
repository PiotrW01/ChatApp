import { Component, OnInit } from '@angular/core';
import { WsClientService } from '../ws-client.service';
import { FormsModule } from '@angular/forms';
import { NgIf } from '@angular/common';
import { DataType } from '../data-type';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule, NgIf],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent implements OnInit {
  constructor(private wsClientService: WsClientService) {}
  newUsername: string = "";
  visible: boolean = true;
  isDisabled: boolean = true;

  ngOnInit(): void {
    this.wsClientService.messages$.subscribe((data) => {
      if(data.type == DataType.CONNECTED){
        this.isDisabled = false;
      }
      else if(data.type == DataType.LOGIN){
        this.newUsername = "";
        this.visible = false;
      }
      else if(data.type == DataType.DISCONNECTED){
        this.visible = true;
      }
    })
  }

  login(): void {
      if(this.isDisabled) return;
      this.wsClientService.login(this.newUsername);
  }
}

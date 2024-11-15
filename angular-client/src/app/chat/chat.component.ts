import { Component, ElementRef, OnInit, ViewChild, AfterViewChecked} from '@angular/core';
import { MessageComponent } from '../message/message.component';
import { WsClientService } from '../ws-client.service';
import { DataType } from '../data-type';
import { NgFor } from '@angular/common';
import { FormsModule, NgModel } from '@angular/forms';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [NgFor, FormsModule],
  templateUrl: './chat.component.html',
  styleUrl: './chat.component.css'
})
export class ChatComponent implements OnInit, AfterViewChecked {
  @ViewChild('chatMessages') chatMessages!: ElementRef;
  messages: MessageComponent[] = [];
  newMessage: string = '';
  username: string = 'user';
  
  constructor(private wsClientService: WsClientService) {
  }

  ngOnInit(): void {
    this.wsClientService.connect("ws://localhost:3000")
    this.wsClientService.messages$.subscribe((data) => {
      if(data.type == DataType.MESSAGE){
        this.createMessage(data.username, data.message);
      }
    })
  }
  
  ngAfterViewChecked(): void {
    this.chatMessages.nativeElement.scrollTo(0, 9999);
  }


  onClick(): void {
    if(this.newMessage.length > 0){
      this.wsClientService.sendMessage(this.newMessage);
      this.newMessage = '';
    }
  }

  onEnter(): void {
    if(true){
      this.onClick();
    }
  }

  createMessage(username: string, text: string) {
    const message: MessageComponent = {
      username: username,
      message: text,
    }
    this.messages.push(message);
  }

}

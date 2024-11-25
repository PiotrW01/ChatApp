import { Component, ElementRef, OnInit, ViewChild, AfterViewChecked} from '@angular/core';
import { MessageComponent } from '../message/message.component';
import { WsClientService } from '../ws-client.service';
import { DataType } from '../data-type';
import { DOCUMENT, NgFor } from '@angular/common';
import { FormsModule, NgModel } from '@angular/forms';
import { MessageContainer } from '../message/message-container.component';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [NgFor, FormsModule],
  templateUrl: './chat.component.html',
  styleUrl: './chat.component.css'
})
export class ChatComponent implements OnInit, AfterViewChecked {
  @ViewChild('chatMessages') chatMessages!: ElementRef;
  @ViewChild('chatInput') chatInput!: ElementRef;
  messages: MessageContainer[] = [];
  newMessage: string = '';
  username: string = 'user';
  
  constructor(private wsClientService: WsClientService) {
  }

  ngOnInit(): void {
    this.wsClientService.connect();
    this.wsClientService.messages$.subscribe((data) => {
      if(data.type == DataType.MESSAGE){
        this.createMessage(data.username, data.message);
      }
      else if(data.type == DataType.LOGIN){
        // @ts-ignore
        data.messages.forEach(msg => {
          this.createMessage(msg.username, msg.message);
        });
      }
    })
    addEventListener('keydown', () => {
      // if nothing is focused, focus chat input
      if(document.activeElement?.isEqualNode(document.body)){
        this.chatInput.nativeElement.focus();
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
    let msg = text.split(" ");
    let temp_text = "";
    // create msg container

    const messageContainer: MessageContainer = {
      username: username,
      messages: [],
    }

    msg.forEach((word) => {
      if(word.startsWith(":") && word.endsWith(":")){
        if(temp_text.length > 0){
          temp_text.trimStart();
          const message: MessageComponent = {
            message: temp_text,
            isEmoji: false,
          }
          messageContainer.messages.push(message);
          temp_text = "";
        }
        const emoji = word.substring(1, word.length - 1)
        const message: MessageComponent = {
          message: emoji,
          isEmoji: true,
        }
        messageContainer.messages.push(message);
      } else {
        temp_text += " " + word;
      }
    })
    if(temp_text.length > 0) {
      temp_text.trimStart();
      const message: MessageComponent = {
        message: temp_text,
        isEmoji: false,
      }
      messageContainer.messages.push(message);
    }
    this.messages.push(messageContainer);
  }

}

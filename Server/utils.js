export function isUsernameValid(username){
  if (username.length < 4 || username.length > 16){
    return false;
  }
  username = username.trim();
  username = username.toLowerCase();
  for (let i = 0; i < username.length; i++) {
    if(username.charCodeAt(i) < 97 || username.charCodeAt(i) > 122){
      return false;
    }
  }
  return true;
}

export class DataType {
    static INIT = 0;
    static MESSAGE = 1;
    static LOGIN = 2;
    static USER_CONNECTED = 3;
    static USER_DISCONNECTED = 4; 
}
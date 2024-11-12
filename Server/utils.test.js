import { isUsernameValid } from './utils.js'

test('Validate username', () => {
    expect(isUsernameValid(" aaaaa ")).toBe(true);
    expect(isUsernameValid("aaaaa")).toBe(true);
    
    expect(isUsernameValid("")).toBe(false);
    expect(isUsernameValid(" ")).toBe(false);
    expect(isUsernameValid("x aaabd")).toBe(false);
    expect(isUsernameValid("xabdądc")).toBe(false);
    expect(isUsernameValid("[wadwaa")).toBe(false);
    expect(isUsernameValid("aaa")).toBe(false);
    expect(isUsernameValid("toolongusernameeeeeeeee")).toBe(false);
});
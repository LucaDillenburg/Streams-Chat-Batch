# Chat in Batch using Streams

### Commands
Command name | Command Syntax | Explanation
--- | --- | ---
```create``` | ```create <user> <password>``` | Create a new user
```passwd``` | ```passwd <user> <old_password> <new_password>``` | Change user password
```login``` | ```login <user> <password>``` | Logs in with user <user>
```msg``` | ```msg <user> <msg>``` | Sends message <msg> to <user>
```list``` | ```list``` | List the users that are online
```logout``` | ```logout``` | Logs out
```quit``` | ```quit``` | Logs out if it's still logged in and then quits the chat

### Example
```sh
$ ./chat.sh
prompt> create user password
prompt> login user password
prompt> msg user2 Hello User2
prompt>
[Message from user2]: Hello User1
prompt> msg user2 I have to go
prompt> quit
```

###### :warning: If you don't ```quit``` or ```logout``` the user will still be considered online

Commands supported by the server:
* `/hello <param>` - Prints "Hello <param>"

  Example: `Hello World`
  
* `/help` - Prints all avalable commands

  Example: 
  ```
   /hello <param>                          #Prints 'Hello <param>'
   /time_now                               #Prints the current time
   /generate_num <param1> <param2>         #Prints a randomly generated number between the two <param> values
   /flip_cpin                              #Prints the result of flipping a coin
   /help                                   #Prints all the supported commands
   /get_file                               #Saves a file from server in the current directory
   ```

* `/time_now` - Prints the current time

  Example: `2018-04-25 23:28:08 +0300`
  
* `/generate_num <param1> <param2>` - Prints a randomly generated number between the two <param> values

  Example: 
  ```
  /generate_num 4 8
  
  Your number: 7
  ```
  
* `/coin_flip` - Prints the result of flipping a coin

  Example: 
  ```
  /coin_flip            
  Heads!
  ```
  
* `/get_file` - Saves a file from server in the current directory

  Example: 
  ```
  /get_file
  File saved
  ```

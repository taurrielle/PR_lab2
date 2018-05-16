# LocalChat Protocol

## General overview
The chat application works with UDP packets. So, in order to filter the packets captured by WireShark, I killed all the applications that use the internet and kindly asked all the human users of my network to turn off the WiFi. Then, I applied a filter in order to see only the UDP packets and foundd out that the destination port the application uses id 42424. Then, I started filtering the packets using this: `udp.port == 42424` and I was able analyze the 

Generally, a packet with data like this is recieved:
`4d5455794e6a55774e6a41324f5441314e33786d4d6a4d77595759774d793035596a6b304c54526a4f474d744f474e6d596930785a54557a4e6a517a5a475a6d4f4752384f6d46736248786c656e41775a56684362456c4563485a6962586877596d315663306c456344466a4d6c5a35596d31476446705451576c685745706f5357347750513d3d`

This is the data encoded in hexadecimal. You will have to convert it to a string that will look like this:
`MTUyNjUwNjA2OTA1N3xmMjMwYWYwMy05Yjk0LTRjOGMtOGNmYi0xZTUzNjQzZGZmOGR8OmFsbHxlenAwZVhCbElEcHZibXhwYm1Vc0lEcDFjMlZ5Ym1GdFpTQWlhWEpoSW4wPQ==`

And after this, you will have to decode the Base64 string. The result must look like this:
`1526506069057|f230af03-9b94-4c8c-8cfb-1e53643dff8d|:all|ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAiaXJhIn0=`

## Two Message Types

### 1. New user sign in

When a new user signs in a packet with data similar to the one below should be recieved. The structure of the recieved data is divided into 4 parts:
* `1526506069057` - the time the message was sent in milliseconds (this value equals `Thu May 17 2018 00:27:49`)
* `f230af03-9b94-4c8c-8cfb-1e53643dff8d` - unique user ID
* `:all` -  flag that tells the program the program that the packet needs to be broadcasted in order for all the users that are connected to receive the new user name.
* `ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAiaXJhIn0=` - Base64 encoded json that contains: `{:type :online, :username "ira"}`

If there are any people online, every instance of the program sends a packet containing the following:
`1526506069389|32af54bb-1438-49f8-9233-830805e09012|f230af03-9b94-4c8c-8cfb-1e53643dff8d|ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAiZHNsIn0=`
As we can see, there are 3 parts:
* `1526506069389` - time in milliseconds
* `32af54bb-1438-49f8-9233-830805e09012` - unique user id of the sender
* `f230af03-9b94-4c8c-8cfb-1e53643dff8d` - unique user id of the reciever 
* `ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAiZHNsIn0=` - `{:type :online, :username "dsl"}`


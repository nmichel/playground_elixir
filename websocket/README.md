# Websockex

Nothing but a sandbox to experiment with websockets in Elixir.

## Compile and start

```shell
$ git clone ...
$ mix deps.get
$ mix compile
$ iex -S mix
````

## Simplest oneway use-case

Open the console in the developer tools of your favorite browser, and enter the following 2 lines:

```javascript
var socket = new WebSocket("ws://localhost:6001/ws")
socket.send("hello")
```

Then look in the `iex` console to see your message logged.

## Two-way use-case

Enter the following line after the two previous ones.

```javascript
socket.onmessage = (event) => { console.log(event.data); };
socket.send("hello again")
```

You should see a `hello again` message in the browser console.

## No custom protocol suppor

Custom protocol(s) may be specified when opening a websocket.

```javascript
var socket = new WebSocket("ws://localhost:6001/ws", "proto")
```

or

```javascript
var socket = new WebSocket("ws://localhost:6001/ws", ["proto1", "proto2"])
```

Custom protocol are not (currently) implemented server-side, therefore you'll get an error.

See section about `websocket_init` in [Cowboy Websocket handling documentation](https://ninenines.eu/docs/en/cowboy/1.0/guide/ws_handlers)

## Happy hacking


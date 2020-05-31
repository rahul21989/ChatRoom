var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/', function(req, res){
  res.send('<h1>Server Chat</h1>');
});

http.listen(3000, function(){
  console.log('Listening on *:3000');
});

io.on('connection', (socket) => {
  console.log("keys "+ Object.keys(socket)) // prints the id sent from the client.
  console.log(socket.data) // prints the data sent from the client.

  socket.on('*', function(event, data) {
    console.log('event: ' + event);
    console.log('data: ' + data);
  }) 
  socket.on('newChatMessage', (msg) => {
    console.log('message: ' + msg);
    	socket.emit('newChatMessage', msg)
    	socket.broadcast.emit('newChatMessage', msg)
  });
});

io.on('newChatMessage', function(a){
	console.log('a user connected');
  console.log(a);
});
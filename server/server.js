var io = require('socket.io').listen(5001),
  redis = require('redis').createClient();

redis.subscribe('redis-change');

io.on('connection', function(socket){
  redis.on('message', function(channel, message){
    data = JSON.parse(message);
    console.log(data);
    socket.emit(data.channel, message);
  });
});

//////////////////////////////////////////////////////////////////////
//
// ElmBluetooth.js
// JavaScript runtime code for Elm LocalStorage module.
// Copyright (c) 2025 Bill St. Clair <billstclair@gmail.com>
// Some rights reserved.
// Distributed under the MIT License
// See LICENSE
//
//////////////////////////////////////////////////////////////////////

  
var ElmBluetooth = {};

function init(app, sendPortName='bluetoothSend', receivePortName='bluetoothReceive') {
  console.log('ElmBluetooth.init: ', app, sendPortName, receivePortName);

  if (app && app.ports && app.ports[sendPortName] && app.ports[receivePortName]) {

    ElmBluetooth.app = app;

    // Send to the Elm subscription port.
    var send = app.ports[receivePortName].send;

    // Debugging
    ElmBluetooth.send = send;

    // Received from the Elm send port
    app.ports[sendPortName].subscribe(msg => { dispatch(msg); });
  }

  function makeMsg (name, value) {
    return { msg: name, value: value }
  }

  function error(value) {
    send(makeMsg("error", value));
  }

  function dispatch(msg) {
    if (typeof(msg) != 'object') {
      error("msg is not an object: " + msg);
    } else {
      var value = msg.value;
      switch (msg.msg) {
        case "init": init(value); break;
        default: error("Unknown message type: " + msg.msg);
      }
    }

    function init () {
      if (!navigator.bluetooth) {
        send(makeMsg("init", "unsupported"));
      } else {
        navigator.bluetooth.getAvailability().then(available => {
          if (available) {
            send(makeMsg("init", "available"));
          } else {
            send(makeMsg("init", "unavailable"));
          }
        });
      }
    }
  }

}

ElmBluetooth.init = init;

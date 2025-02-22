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

function init(app, sendPortName='elmBluetoothSend', receivePortName='elmBluetoothReceive') {
  if (app && app.ports && app.ports[sendPortName] && app.ports[receivePortName]) {

    // Send to the Elm subscription port.
    var send = app.ports[receivePortName].send;

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
      switch (msg.name) {
      case "init": init(value); break;
      default: error("Unknown message type: " + msg.name);
      }
    }

    function init () {
      error("init is not yet written.");
    }
  }

}

ElmBluetooth.init = init;

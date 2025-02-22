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

function init (app, sendPortName='bluetoothSend', receivePortName='bluetoothReceive') {
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

  function sendMsg (name, value) {
    send(makeMsg(name, value));
  }

  function error (value) {
    sendMsg("error", value);
  }

  function dispatch (msg) {
    if (typeof(msg) != 'object') {
      error("msg is not an object: " + msg);
    } else {
      var value = msg.value;
      switch (msg.msg) {
        case "init": init(value); break;
        case "requestDevice": requestDevice(value); break;
        default: error("Unknown message type: " + msg.msg);
      }
    }

    function requestDevice () {
      try {
        navigator.bluetooth.requestDevice({acceptAllDevices: true}).then(x => {
          console.log("ElmBluetooth, requestDevice: ", x);
          sendMsg("requestDevice", x);
        });
      } catch (errMsg) {
        console.log("ElmBluetooth, requestDevice error: ", errMsg);
        error(errMsg);
      };
      
    }

    function init () {
      if (!navigator.bluetooth) {
        sendMsg("init", "unsupported");
      } else {
        navigator.bluetooth.getAvailability().then(available => {
          if (available) {
            sendMsg("init", "available");
          } else {
            sendMsg("init", "unavailable");
          }
        });
      }
    }
  }

}

ElmBluetooth.init = init;

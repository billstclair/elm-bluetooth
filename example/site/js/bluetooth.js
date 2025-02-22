var bluetoothAvailable;

function maybeCall(f, val) {
  if (typeof(f) == 'function') {
    f(val);
  }
}

function checkBluetoothAvailability(f) {
  if (navigator.bluetooth) {
    navigator.bluetooth.getAvailability().then(available => {
      if (available) {
        console.log("Bluetooth is available.");
        bluetoothAvailable = true;
        maybeCall(f, true);
      } else {
        console.log("Bluetooth is NOT available.");
        bluetoothAvailable = false;
        maybeCall(f, false);
      }
    });
  }
  else {
    console.log("Bluetooth API not implemented by this browser.");
    bluetoothAvailable = false;
    maybeCall(f, false);
  };
}

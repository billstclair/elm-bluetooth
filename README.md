# WebSockets for Elm 0.19

[billstclair/elm-bluetooth](https://package.elm-lang.org/packages/billstclair/elm-bluetooth/latest) is a library for accessing the JavaScript Bluetooth Web API. It uses ports to do that.

## Using the Package

See `Main.elm` and `PortFunnels.elm` in the the [example/src](https://github.com/billstclair/elm-websocket-client/tree/master/example/src) directory for details. `PortFunnels.elm` exposes a `State` type and an `initialState` constant.

You will usually copy `PortFunnels.elm` into your application's source directory, and, if you use other `PortFunnel` modules, modify it to support all of them. It is a `port module`, and it defines the two ports that are used by `example/site/index.html`, `cmdPort` and `subPort`.

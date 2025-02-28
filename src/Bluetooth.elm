----------------------------------------------------------------------
--
-- Bluetooth.elm
--
-- Access the Bluetooth Web API via ports.
--
-- Copyright (c) 2025 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE
--
----------------------------------------------------------------------
--
-- TODO


module Bluetooth exposing
    ( Config, SentMessage(..), ReceivedMessage(..), InitState(..)
    , init
    , send
    , decodeReceivedMessage
    , initStateToString
    )

{-| The Bluetooth Web API is an experimental API.

Hence, it is supported by only a few browsers. I use
Google Chrome for development.

If the Bluetooth Web API is not available in your browser, `init` will
let you know via the `ReceivedInitialize` message.


## Types

@docs Config, SentMessage, ReceivedMessage, InitState


## Initializing

@docs init


## Sending messages

@docs send


## Receiving messages

@docs decodeReceivedMessage


## Miscelaneous

@docs initStateToString

-}

import Bluetooth.InternalMessage as IM
    exposing
        ( ReceivedMessage(..)
        , SentMessage(..)
        )
import Bluetooth.Types exposing (RequestDeviceOptions)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)
import List.Extra as LE


{-| Configuration.

Returned by `init`. Passed to `send`.

-}
type alias Config msg =
    IM.Config msg


{-| Initialize the JavaScript code.

Will send back a ReceiveMessage.BTReceiveInit.

-}
init : (Value -> Cmd msg) -> ( Config msg, Cmd msg )
init sendPort =
    let
        config =
            IM.makeConfig sendPort
    in
    ( config
    , IM.send config SMInit
    )


{-| Messages sent to the ElmBluetooth JavaScript code.
-}
type SentMessage
    = SendNoop
    | SendRequestDevice RequestDeviceOptions


{-| Send a message to the JavaScript code.
-}
send : Config msg -> SentMessage -> Cmd msg
send config message =
    case message of
        SendNoop ->
            Cmd.none

        SendRequestDevice options ->
            IM.send config (SMRequestDevice options)


{-| Messages received from the JavaScript code.
-}
type ReceivedMessage
    = ReceivedError String
    | ReceivedInitialized InitState
    | ReceivedRequestDevice String


{-| Returned in the ReceivedInitialized message.
-}
type InitState
    = BluetoothAvailable
    | BluetoothUnavailable
    | BluetoothUnsupported


convertInitState : IM.InitState -> InitState
convertInitState initState =
    case initState of
        IM.Available ->
            BluetoothAvailable

        IM.Unavailable ->
            BluetoothUnavailable

        IM.Unsupported ->
            BluetoothUnsupported


{-| Convert an `InitState` to a string for printing.
-}
initStateToString : InitState -> String
initStateToString initState =
    case initState of
        BluetoothAvailable ->
            "BluetoothAvailable"

        BluetoothUnavailable ->
            "BluetoothUnavailable"

        BluetoothUnsupported ->
            "BluetoothUnsupported"


{-| Decode a message received from the port you've subscribed to.
-}
decodeReceivedMessage : Value -> Result String ReceivedMessage
decodeReceivedMessage receivedValue =
    case JD.decodeValue IM.receivedMessageDecoder receivedValue of
        Err err ->
            Err <| JD.errorToString err

        Ok receivedMessage ->
            Ok <|
                case receivedMessage of
                    RMError s ->
                        ReceivedError s

                    RMInit initState ->
                        ReceivedInitialized <| convertInitState initState

                    RMRequestDevice json ->
                        ReceivedRequestDevice json



--
-- Control an initialized interface.
--

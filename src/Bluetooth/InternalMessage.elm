----------------------------------------------------------------------
--
-- InternalMessage.elm
--
-- Messages for the port interface.
--
-- Copyright (c) 2025 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE
--
----------------------------------------------------------------------
--
-- TODO


module Bluetooth.InternalMessage exposing
    ( Config
    , InitState(..)
    , ReceivedMessage(..)
    , SentMessage(..)
    , makeConfig
    , receivedMessageDecoder
    , send
    )

import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline as DP exposing (custom, hardcoded, optional, required)
import Json.Encode as JE exposing (Value)


type alias SendPort msg =
    Value -> Cmd msg


type alias ConfigRecord msg =
    { sendPort : SendPort msg
    }


type Config msg
    = Config (ConfigRecord msg)


type alias WireMessage =
    { msg : String
    , value : Value
    }


makeConfig : SendPort msg -> Config msg
makeConfig sendPort =
    Config { sendPort = sendPort }



-- Sending message to the JavaScript


{-| Send a message to the ElmBluetooth JS code.
-}
send : Config msg -> SentMessage -> Cmd msg
send config message =
    case config of
        Config { sendPort } ->
            sendPort <| encodeSentMessage message


type SentMessage
    = SMInit
    | SMRequestDevice


encodeWireMessage : String -> Value -> Value
encodeWireMessage msg value =
    JE.object
        [ ( "msg", JE.string msg )
        , ( "value", value )
        ]


encodeSentMessage : SentMessage -> Value
encodeSentMessage message =
    case message of
        SMInit ->
            encodeWireMessage "init" JE.null

        SMRequestDevice ->
            encodeWireMessage "requestDevice" JE.null



-- decoding received messages


type InitState
    = Available
    | Unavailable
    | Unsupported


decodeInitStateString : String -> Result String InitState
decodeInitStateString s =
    case String.toLower s of
        "available" ->
            Ok Available

        "unavailable" ->
            Ok Unavailable

        "unsupported" ->
            Ok Unsupported

        _ ->
            Err <| "Unknown InitState string: " ++ s


type ReceivedMessage
    = RMError String
    | RMInit InitState
    | RMRequestDevice String --we'll parse this soon


receivedMessageDecoder : Decoder ReceivedMessage
receivedMessageDecoder =
    (JD.succeed WireMessage
        |> required "msg" JD.string
        |> required "value" JD.value
    )
        |> JD.map wireMessageToReceivedMessage


wireMessageToReceivedMessage : WireMessage -> ReceivedMessage
wireMessageToReceivedMessage wireMessage =
    let
        value =
            wireMessage.value
    in
    case wireMessage.msg of
        "error" ->
            decodeError value

        "init" ->
            decodeInit value

        "requestDevice" ->
            decodeRequestDevice value

        _ ->
            RMError <| "Unknown wire msg: " ++ wireMessage.msg


decodeError : Value -> ReceivedMessage
decodeError value =
    -- Maybe we should distinguish Json decoding errors from
    -- Bluetooth errors, but I don't expect to get any of the former.
    case JD.decodeValue JD.string value of
        Err err ->
            RMError <| JD.errorToString err

        Ok s ->
            RMError s


decodeRequestDevice : Value -> ReceivedMessage
decodeRequestDevice value =
    RMRequestDevice <| JE.encode 2 value


decodeInit : Value -> ReceivedMessage
decodeInit value =
    case JD.decodeValue JD.string value of
        Err err ->
            RMError <| JD.errorToString err

        Ok initStateString ->
            case decodeInitStateString initStateString of
                Err s ->
                    RMError s

                Ok initState ->
                    RMInit initState

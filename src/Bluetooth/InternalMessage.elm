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
    , ReceiveMessage(..)
    , SendMessage(..)
    , makeConfig
    , receiveMessageDecoder
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


send : Config msg -> SendMessage -> Cmd msg
send config message =
    case config of
        Config { sendPort } ->
            sendPort <| encodeSendMessage message


type SendMessage
    = SMInit


encodeSendMessage : SendMessage -> Value
encodeSendMessage message =
    case message of
        SMInit ->
            JE.object
                [ ( "msg", JE.string "init" )
                , ( "value", JE.null )
                ]



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


type ReceiveMessage
    = RMError String
    | RMInit InitState


receiveMessageDecoder : Decoder ReceiveMessage
receiveMessageDecoder =
    (JD.succeed WireMessage
        |> required "msg" JD.string
        |> required "value" JD.value
    )
        |> JD.map wireMessageToReceiveMessage


wireMessageToReceiveMessage : WireMessage -> ReceiveMessage
wireMessageToReceiveMessage wireMessage =
    case wireMessage.msg of
        "init" ->
            decodeInit wireMessage.value

        _ ->
            RMError <| "Unknown wire msg: " ++ wireMessage.msg


decodeInit : Value -> ReceiveMessage
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

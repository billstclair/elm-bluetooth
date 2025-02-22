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


module Bluetooth.InternalMessage exposing (Config, SendMessage(..), makeConfig, send)

import Json.Encode as JE exposing (Value)


type alias SendPort msg =
    Value -> Cmd msg


type alias ReceivePort msg =
    (Value -> msg) -> Sub msg


type alias ConfigRecord msg =
    { sendPort : SendPort msg
    , receivePort : ReceivePort msg
    }


type Config msg
    = Config (ConfigRecord msg)


makeConfig : SendPort msg -> ReceivePort msg -> Config msg
makeConfig sendPort receivePort =
    Config { sendPort = sendPort, receivePort = receivePort }


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
            JE.null

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


type alias ConfigRecord msg =
    { sendPort : SendPort msg
    }


type Config msg
    = Config (ConfigRecord msg)


makeConfig : SendPort msg -> Config msg
makeConfig sendPort =
    Config { sendPort = sendPort }


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

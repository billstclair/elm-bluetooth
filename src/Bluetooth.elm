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
    ( Config
    , init
    )

{-| The Bluetooth Web API is an experimental API.

Hence, Bluetooth-Web-API is supported by only a few browsers. I use
Google Chrome for development.

If the Bluetooth-Web-API is not available in your browser, `init` will
return an error.


# Bluetooth


## Types

@docs Config


## Initializing

@docs init

-}

import Bluetooth.InternalMessage as IM exposing (SendMessage(..))
import Json.Encode as JE exposing (Value)
import List.Extra as LE


type alias Config msg =
    IM.Config msg


init : (Value -> Cmd msg) -> ((Value -> msg) -> Sub msg) -> ( Config msg, Cmd msg )
init sendPort receivePort =
    let
        config =
            IM.makeConfig sendPort receivePort
    in
    ( config
    , IM.send config SMInit
    )

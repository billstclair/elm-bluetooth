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

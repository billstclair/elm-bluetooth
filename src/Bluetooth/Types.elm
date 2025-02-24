----------------------------------------------------------------------
--
-- Types.elm
--
-- Types for Bluetooth
--
-- Copyright (c) 2025 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE
--
----------------------------------------------------------------------


module Bluetooth.Types exposing (RequestDeviceOptions)

{-| Types for elm-bluetooth.
-}

{- The options arguments to requestDevice(options) -}


type alias RequestDeviceOptions =
    List RequestDeviceOption


{-| Represent one of the list of options to `requestDevice(options)`
-}
type RequestDeviceOption
    = RDFilters (List RequestDeviceFilter)
    | RDExclusionFilters (List RequestDeviceFilter)
    | RDOptionalServices (List ServiceName)
    | RSOptionalManufacturerData (List CompanyIdentifier)
    | RSAcceptAllDevices Bool


type alias ServiceName =
    String


type alias CompanyIdentifier =
    Int

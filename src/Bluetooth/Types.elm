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


module Bluetooth.Types exposing
    ( RequestDeviceOptions
    , RequestDeviceOption(..)
    , RequestDeviceFilter(..), ServiceName, CompanyIdentifier
    , GATTService, ManufacturerData(..), ServiceData(..)
    , Byte
    )

{-| Types for elm-bluetooth.

The arg to the `SendRequestDevice` option for `SentMessage`, an arg to
`Bluetooth.send`.

@docs RequestDeviceOptions

which is a list of:

@docs RequestDeviceOption

which has options referencing types:

@docs RequestDeviceFilter, ServiceName, CompanyIdentifier

A `RequestDeviceFilter` has options referencing:

@docs GATTService, ManufacturerData, ServiceData

Referenced by options to `ManufacturerData` and `ServiceData`:

@docs Byte

-}


{-| The argument to `BlueTooth.SendRequestDevice`.
-}
type alias RequestDeviceOptions =
    List RequestDeviceOption


{-| On of the list of options to `requestDevice(options)`.
From [requestDevice](https://developer.mozilla.org/en-US/docs/Web/API/Bluetooth/requestDevice) docs.
-}
type RequestDeviceOption
    = RDOFilters (List RequestDeviceFilter)
    | RDOExclusionFilters (List RequestDeviceFilter)
    | RDOOptionalServices (List ServiceName)
    | RSOOptionalManufacturerData (List CompanyIdentifier)
    | RSOAcceptAllDevices Bool


{-| One of the list of `RequestDeviceOption` `RDOFilters`.
-}
type RequestDeviceFilter
    = RDFServices (List GATTService)
    | RDFName String
    | RDFNamePrefix String
    | RDFManufacturerData (List ManufacturerData)
    | RDFServiceData (List ServiceData)


{-| [GATT assigned services list](https://github.com/WebBluetoothCG/registries/blob/master/gatt_assigned_services.txt)
-}
type alias GATTService =
    String


{-| [Assigned services list}(<https://github.com/WebBluetoothCG/registries/blob/master/gatt_assigned_services.txt>)
-}
type alias ServiceName =
    String


{-| One element of the list of `RequestDeviceFilter`'s `RDFManufacturerData`.
-}
type ManufacturerData
    = MDCompanyIdentifier CompanyIdentifier
    | MDDataPrefix (List Byte)
    | MDMask (List Byte)


{-| [Assigned numbers](https://www.bluetooth.com/specifications/assigned-numbers/)
for company identifiers.
-}
type alias CompanyIdentifier =
    Int


{-| One byte of `ManufacturerData`'s `MDDataPrefix`.
-}
type alias Byte =
    Int


{-| One element of `RequestDeviceFilter`'s `RDFServiceData`.
-}
type ServiceData
    = SDService ServiceName
    | DFDataPrefix (List Byte)
    | DFMask (List Byte)

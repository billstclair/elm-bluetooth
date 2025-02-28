----------------------------------------------------------------------
--
-- EncodeDecode.elm
--
-- Encoders & Decoders for Bluetooth
--
-- Copyright (c) 2025 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE
--
----------------------------------------------------------------------


module Bluetooth.EncodeDecode exposing
    ( encodeRequestDeviceOptions, encodeRequestDeviceOption
    , encodeRequestDeviceFilter, encodeServiceName
    , encodeManufacturerData
    , encodeGattService, encodeServiceData
    , requestDeviceOptionsDecoder, requestDeviceOptionDecoder
    , requestDeviceFilterDecoder, serviceNameDecoder
    , manufacturerDataDecoder
    , gattServiceDecoder, serviceDataDecoder
    )

{-| Encoders & decoders for elm-bluetooth.

User code will likely not need this. Even the elm-bluetooth module
uses only `encodeRequestDeviceOptions`.


# Encoders

@docs encodeRequestDeviceOptions, encodeRequestDeviceOption
@docs encodeRequestDeviceFilter, encodeServiceName
@docs encodeManufacturerData
@docs encodeGattService, encodeServiceData


# Decoders

@docs requestDeviceOptionsDecoder, requestDeviceOptionDecoder
@docs requestDeviceFilterDecoder, serviceNameDecoder
@docs manufacturerDataDecoder
@docs gattServiceDecoder, serviceDataDecoder

-}

import Bluetooth.Types
    exposing
        ( Byte
        , CompanyIdentifier
        , GATTService
        , ManufacturerData(..)
        , RequestDeviceFilter(..)
        , RequestDeviceOption(..)
        , RequestDeviceOptions
        , ServiceData(..)
        , ServiceName
        )
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline as DP exposing (custom, hardcoded, optional, required)
import Json.Encode as JE exposing (Value)


{-| Encode `RequestDeviceOptions`.
-}
encodeRequestDeviceOptions : RequestDeviceOptions -> Value
encodeRequestDeviceOptions options =
    JE.list encodeRequestDeviceOption options


{-| Decoder for `RequestDeviceOptions`.
-}
requestDeviceOptionsDecoder : Decoder RequestDeviceOptions
requestDeviceOptionsDecoder =
    JD.list requestDeviceOptionDecoder


{-| Encode a `RequestDeviceOption`.
-}
encodeRequestDeviceOption : RequestDeviceOption -> Value
encodeRequestDeviceOption option =
    case option of
        RDOFilters filters ->
            JE.object
                [ ( "RDOFilters"
                  , JE.list encodeRequestDeviceFilter filters
                  )
                ]

        RDOExclusionFilters filters ->
            JE.object
                [ ( "RDOExclusionFilters"
                  , JE.list encodeRequestDeviceFilter filters
                  )
                ]

        RDOOptionalServices services ->
            JE.object
                [ ( "RDOOptionalServices"
                  , JE.list encodeServiceName services
                  )
                ]

        RDOOptionalManufacturerData identifiers ->
            JE.object
                [ ( "RDOOptionalManufacturerData"
                  , JE.list JE.int identifiers
                  )
                ]

        RDOAcceptAllDevices accept ->
            JE.object [ ( "AcceptAllDevices", JE.bool accept ) ]


{-| Decoder for `RequestDeviceOption`.
-}
requestDeviceOptionDecoder : Decoder RequestDeviceOption
requestDeviceOptionDecoder =
    JD.oneOf
        [ JD.field "RDOFilters" (JD.list requestDeviceFilterDecoder)
            |> JD.andThen
                (\filters ->
                    JD.succeed <| RDOFilters filters
                )
        , JD.field "RDOExclusionFilters" (JD.list requestDeviceFilterDecoder)
            |> JD.andThen
                (\filters ->
                    JD.succeed <| RDOExclusionFilters filters
                )
        , JD.field "RDOOptionalServices" (JD.list serviceNameDecoder)
            |> JD.andThen
                (\names ->
                    JD.succeed <| RDOOptionalServices names
                )
        , JD.field "RDOOptionalManufacturerData" (JD.list JD.int)
            |> JD.andThen
                (\identifiers ->
                    JD.succeed <|
                        RDOOptionalManufacturerData identifiers
                )
        , JD.field "RDOAcceptAllDevices" JD.bool
            |> JD.andThen
                (\ok ->
                    JD.succeed <|
                        RDOAcceptAllDevices ok
                )
        ]


{-| Encode a `RequestDeviceFilter`.
-}
encodeRequestDeviceFilter : RequestDeviceFilter -> Value
encodeRequestDeviceFilter filter =
    case filter of
        RDFServices services ->
            JE.object [ ( "RDFServices", JE.list encodeGattService services ) ]

        RDFName name ->
            JE.object [ ( "RDFName", JE.string name ) ]

        RDFNamePrefix prefix ->
            JE.object [ ( "RDFNamePrefix", JE.string prefix ) ]

        RDFManufacturerData dataList ->
            JE.object
                [ ( "RDFManufacturerData"
                  , JE.list encodeManufacturerData dataList
                  )
                ]

        RDFServiceData serviceData ->
            JE.object
                [ ( "RDFServiceData"
                  , JE.list encodeServiceData serviceData
                  )
                ]


{-| Decoder for `RequestDeviceFilter`.
-}
requestDeviceFilterDecoder : Decoder RequestDeviceFilter
requestDeviceFilterDecoder =
    JD.oneOf
        [ JD.field "RDFServices" (JD.list gattServiceDecoder)
            |> JD.andThen
                (\services ->
                    JD.succeed <| RDFServices services
                )
        , JD.field "RDFName" JD.string
            |> JD.andThen
                (\name ->
                    JD.succeed <| RDFName name
                )
        , JD.field "RDFNamePrefix" JD.string
            |> JD.andThen
                (\name ->
                    JD.succeed <| RDFNamePrefix name
                )
        , JD.field "RDFManufacturerData" (JD.list manufacturerDataDecoder)
            |> JD.andThen
                (\data ->
                    JD.succeed <| RDFManufacturerData data
                )
        , JD.field "RDFServiceData" (JD.list serviceDataDecoder)
            |> JD.andThen
                (\data ->
                    JD.succeed <| RDFServiceData data
                )
        ]


{-| Encode a `ServiceName`.
-}
encodeServiceName : ServiceName -> Value
encodeServiceName name =
    JE.string name


{-| Decoder for `ServiceName`.
-}
serviceNameDecoder : Decoder ServiceName
serviceNameDecoder =
    JD.string


{-| Encode `ManufacturerData`.
-}
encodeManufacturerData : ManufacturerData -> Value
encodeManufacturerData data =
    case data of
        MDCompanyIdentifier identifier ->
            JE.object [ ( "MDCompanyIdentifier", JE.int identifier ) ]

        MDDataPrefix bytes ->
            JE.object [ ( "MDDataPrefix", JE.list JE.int bytes ) ]

        MDMask bytes ->
            JE.object [ ( "MDMask", JE.list JE.int bytes ) ]


{-| Decoder for `ManufacturerData`.
-}
manufacturerDataDecoder : Decoder ManufacturerData
manufacturerDataDecoder =
    JD.oneOf
        [ JD.field "MDCompanyIdentifier" JD.int
            |> JD.andThen
                (\identifier ->
                    JD.succeed <| MDCompanyIdentifier identifier
                )
        , JD.field "MDDataPrefix" (JD.list JD.int)
            |> JD.andThen
                (\bytes ->
                    JD.succeed <| MDDataPrefix bytes
                )
        , JD.field "MDMask" (JD.list JD.int)
            |> JD.andThen
                (\bytes ->
                    JD.succeed <| MDMask bytes
                )
        ]


{-| Encode `GATTService`.
-}
encodeGattService : GATTService -> Value
encodeGattService service =
    JE.string service


{-| Decoder for `GATTService`
-}
gattServiceDecoder : Decoder GATTService
gattServiceDecoder =
    JD.string


{-| Encode `ServiceData`.
-}
encodeServiceData : ServiceData -> Value
encodeServiceData data =
    case data of
        SDService name ->
            JE.object [ ( "SDService", encodeServiceName name ) ]

        SDDataPrefix bytes ->
            JE.object [ ( "SDDataPrefix", JE.list JE.int bytes ) ]

        SDMask bytes ->
            JE.object [ ( "SDMask", JE.list JE.int bytes ) ]


{-| Decoder for `ServiceData`
-}
serviceDataDecoder : Decoder ServiceData
serviceDataDecoder =
    JD.oneOf
        [ JD.field "SDService" JD.string
            |> JD.andThen
                (\name ->
                    JD.succeed <| SDService name
                )
        , JD.field "SDDataPrefix" (JD.list JD.int)
            |> JD.andThen
                (\bytes ->
                    JD.succeed <| SDDataPrefix bytes
                )
        , JD.field "SDDataMask" (JD.list JD.int)
            |> JD.andThen
                (\bytes ->
                    JD.succeed <| SDMask bytes
                )
        ]

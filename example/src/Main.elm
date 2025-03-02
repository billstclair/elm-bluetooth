port module Main exposing (main)

{-| Bluetooth Example
-}

import Bluetooth exposing (SentMessage(..))
import Bluetooth.Types
    exposing
        ( ManufacturerData(..)
        , RequestDeviceFilter(..)
        , RequestDeviceOption(..)
        , ServiceData(..)
        )
import Browser
import Cmd.Extra exposing (addCmd, addCmds, withCmd, withCmds, withNoCmd)
import Dict exposing (Dict)
import Html exposing (Html, a, button, code, div, h1, input, p, pre, span, text)
import Html.Attributes
    exposing
        ( checked
        , disabled
        , href
        , size
        , style
        , target
        , type_
        , value
        )
import Html.Events exposing (onClick, onInput)
import Json.Encode as JE exposing (Value)



-- Ports
--
-- You need this in any application that uses Bluetooth.
-- See site/index.html for how to initialize site/js/ElmBluetooth.js.
--


port bluetoothSend : Value -> Cmd msg


port bluetoothReceive : (Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    bluetoothReceive BluetoothReceive


type alias Response =
    { sent : String
    , received : String
    }


type alias Model =
    { config : Bluetooth.Config Msg
    , error : Maybe String
    , bluetoothAvailable : Bool
    , initState : Maybe Bluetooth.InitState
    , response : Maybe Response
    }


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        ( config, cmd ) =
            Bluetooth.init bluetoothSend
    in
    { config = config
    , error = Nothing
    , bluetoothAvailable = False
    , initState = Nothing
    , response = Nothing
    }
        |> withCmd cmd


type Msg
    = BluetoothReceive Value
    | Send SentMessage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        mdl =
            { model | error = Nothing }
    in
    case msg of
        Send message ->
            model |> withCmd (Bluetooth.send model.config message)

        BluetoothReceive value ->
            case
                Debug.log "BluetoothReceive" <|
                    Bluetooth.decodeReceivedMessage value
            of
                Err s ->
                    { model | error = Just s }
                        |> withNoCmd

                Ok message ->
                    case message of
                        Bluetooth.ReceivedError s ->
                            { model | error = Just s }
                                |> withNoCmd

                        Bluetooth.ReceivedRequestDevice device ->
                            { model
                                | response =
                                    Just
                                        { sent = "RequestDevice"
                                        , received = device
                                        }
                            }
                                |> withNoCmd

                        Bluetooth.ReceivedInitialized initState ->
                            let
                                err =
                                    "ElmBluetooth Initialized: "
                                        ++ Bluetooth.initStateToString initState
                            in
                            { model
                                | error = Just err
                                , bluetoothAvailable =
                                    initState == Bluetooth.BluetoothAvailable
                                , initState = Just initState
                            }
                                |> withNoCmd



-- VIEW


b : String -> Html Msg
b string =
    Html.b [] [ text string ]


br : Html msg
br =
    Html.br [] []


docp : String -> Html Msg
docp string =
    p [] [ text string ]


view : Model -> Html Msg
view model =
    div
        [ style "width" "40em"
        , style "margin" "auto"
        , style "margin-top" "1em"
        , style "padding" "1em"
        , style "border" "solid"
        ]
        [ h1 [] [ text "Bluetooth Example" ]
        , case model.error of
            Nothing ->
                docp "No error"

            Just s ->
                p [ style "color" "red" ]
                    [ text s ]
        , if not model.bluetoothAvailable then
            p []
                [ case model.initState of
                    Nothing ->
                        text "Waiting for ElmBluetooth.init() to return."

                    Just Bluetooth.BluetoothUnavailable ->
                        text "Bluetooth is not available. In Brave, you can enable it in brave://flags."

                    _ ->
                        text "The Bluetooth Web API is not supported by your browser."
                ]

          else
            viewPage model
        , footer model
        ]


sendRequestDevice : Model -> Msg
sendRequestDevice model =
    Send (SendRequestDevice [ RDOAcceptAllDevices True ])


viewPage : Model -> Html Msg
viewPage model =
    div []
        [ p []
            [ button [ onClick <| sendRequestDevice model ]
                [ text "requestDevice" ]
            ]
        , case model.response of
            Nothing ->
                text ""

            Just { sent, received } ->
                p []
                    [ b "sent: "
                    , text sent
                    , br
                    , pre []
                        [ code [] [ text received ] ]
                    ]
        ]


footer : Model -> Html Msg
footer model =
    p []
        [ b "Package: "
        , a [ href "https://package.elm-lang.org/packages/billstclair/elm-bluetooth/latest" ]
            [ text "billstclair/elm-bluetooth" ]
        , br
        , b "GitHub: "
        , a [ href "https://github.com/billstclair/elm-bluetooth" ]
            [ text "github.com/billstclair/elm-bluetooth" ]
        , br
        , b "Bluetooth API docs: "
        , br
        , div [ style "margin-left" "1em" ]
            [ a [ href "https://developer.mozilla.org/en-US/docs/Web/API/Bluetooth" ]
                [ text "Mozilla's Bluetooth Web API Docs" ]
            , br
            , a [ href "https://developer.chrome.com/docs/capabilities/bluetooth" ]
                [ text "Communicating with Bluetooth Devices over JavaScript" ]
            ]
        ]

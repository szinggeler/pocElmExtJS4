port module Poc exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Array exposing (Array)


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { extPanelLevel : Int
    , title : String
    , btnText : String
    , extvalues : List String
    }


init : ( Model, Cmd Msg )
init =
    ( Model 0 "Hallo Ext" "Ext-Panel erstellen / Titel setzen" [], Cmd.none )



-- UPDATE


type Msg
    = Change String
    | ChangeLevel String
    | Check
    | GreetingFromExtJS (List String)


port settitle : List String -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change newWord ->
            ( { model | title = newWord }, Cmd.none )

        ChangeLevel newLevel ->
            let
                nl =
                    Result.withDefault 0 (String.toInt newLevel)
            in
                ( { model | extPanelLevel = nl }, Cmd.none )

        Check ->
            ( { model | btnText = "Ext-Panel erstellen / Titel setzen" }
            , settitle
                ([ toString model.extPanelLevel
                 , "Panel " ++ toString model.extPanelLevel ++ ": " ++ model.title
                 ]
                )
            )

        GreetingFromExtJS newExtGreetings ->
            ( { model | extvalues = newExtGreetings }, Cmd.none )



-- SUBSCRIPTIONS


port extvalues : (List String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    extvalues GreetingFromExtJS



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div
            [ id "seite" ]
            [ div [ id "kopfbereich" ]
                [ text ("Elm-Header: " ++ toString model.extvalues)
                ]
            , div [ id "spaltelinks" ]
                [ text "Elm-Spalte links"
                , br [] []
                , table []
                    [ tabRow
                        { labTxt = "Level: "
                        , labWidth = "130px"
                        , inputTypeTxt = "number"
                        , inputValueTxt = toString model.extPanelLevel
                        , inputWidth =
                            "150px"
                            --, inputOn = Change
                        }
                    , tabRow
                        { labTxt = "Message to ExtJS: "
                        , labWidth = "130px"
                        , inputTypeTxt = ""
                        , inputValueTxt = model.title
                        , inputWidth =
                            "150px"
                            --, inputOn = Change
                        }
                    ]
                , br [] []
                , button [ onClick Check ]
                    [ text model.btnText ]
                ]
              --, div [ id "spalterechts" ]
              --    [ text "Elm-Spalte rechts" ]
            , div
                [ id ("inhalt" ++ toString model.extPanelLevel)
                , class "inhalt"
                ]
                [ text "Elm-Spalte mitte"
                ]
            , div [ id "fussbereich" ]
                [ text "Elm-Footer:"
                ]
            ]
        ]


tabRow :
    { labTxt : String
    , labWidth : String
    , inputTypeTxt : String
    , inputValueTxt : String
    , inputWidth : String
    }
    -> Html Msg
tabRow params =
    tr []
        [ td [ style [ ( "width", params.labWidth ) ] ]
            [ label [ style [ ( "width", params.labWidth ) ] ]
                [ text params.labTxt ]
            ]
        , td []
            [ input
                [ onInput
                    (if params.inputTypeTxt == "number" then
                        ChangeLevel
                     else
                        Change
                    )
                , type_ params.inputTypeTxt
                , Html.Attributes.min "0"
                , value params.inputValueTxt
                , style [ ( "width", params.inputWidth ) ]
                ]
                []
            ]
        ]

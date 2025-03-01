module GameNight exposing (..)

import BggApi exposing (BggGame)
import Browser
import Html exposing (Html, button, div, h1, h2, header, img, input, main_, p, section, span, text)
import Html.Attributes exposing (class, disabled, placeholder, src, style, value)
import Html.Events exposing (onClick, onInput, onMouseEnter, onMouseLeave)
import Http
import Set exposing (Set)


type Status
    = Initial
    | Loading
    | Loaded
    | Failed String


type alias Model =
    { username : String
    , status : Status
    , games : List BggGame
    , selectedGames : Set String
    , hoveredGame : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { username = ""
      , status = Initial
      , games = []
      , selectedGames = Set.empty
      , hoveredGame = Nothing
      }
    , Cmd.none
    )


type Msg
    = UpdateUsername String
    | SubmitUsername
    | GotGames (Result Http.Error (List BggGame))
    | ToggleGameSelection BggGame
    | ClearSelection
    | HoverGame String
    | UnhoverGame


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateUsername username ->
            ( { model | username = username }, Cmd.none )

        SubmitUsername ->
            ( { model | status = Loading }
            , BggApi.getUserCollection model.username GotGames
            )

        GotGames result ->
            case result of
                Ok games ->
                    ( { model
                        | games = games
                        , status = Loaded
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | status = Failed "Failed to load games." }
                    , Cmd.none
                    )

        ToggleGameSelection game ->
            ( { model
                | selectedGames =
                    if Set.member game.id model.selectedGames then
                        Set.remove game.id model.selectedGames

                    else
                        Set.insert game.id model.selectedGames
              }
            , Cmd.none
            )

        ClearSelection ->
            ( { model | selectedGames = Set.empty }, Cmd.none )

        HoverGame name ->
            ( { model | hoveredGame = Just name }, Cmd.none )

        UnhoverGame ->
            ( { model | hoveredGame = Nothing }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


view : Model -> Html Msg
view model =
    div
        [ style "max-width" "1200px"
        , style "margin" "0 auto"
        , style "padding" "20px"
        , style "font-family" "Arial, sans-serif"
        ]
        [ header
            [ style "text-align" "center"
            , style "margin-bottom" "40px"
            ]
            [ h1 [] [ text "Game Night Selector" ]
            , div
                [ style "margin" "20px 0"
                , style "display" "flex"
                , style "gap" "10px"
                , style "justify-content" "center"
                , style "align-items" "center"
                ]
                [ input
                    [ style "padding" "8px"
                    , style "border-radius" "4px"
                    , style "border" "1px solid #ccc"
                    , placeholder "Enter your BGG username"
                    , value model.username
                    , onInput UpdateUsername
                    ]
                    []
                , button
                    [ style "padding" "8px 16px"
                    , style "border-radius" "4px"
                    , style "border" "none"
                    , style "background" "#4CAF50"
                    , style "color" "white"
                    , style "cursor" "pointer"
                    , onClick SubmitUsername
                    , disabled (model.status == Loading || String.isEmpty (String.trim model.username))
                    ]
                    [ text "Load Games" ]
                ]
            , case model.status of
                Loading ->
                    div
                        [ style "text-align" "center"
                        , style "margin" "20px 0"
                        , style "color" "#666"
                        ]
                        [ text "Loading games..." ]

                Failed error ->
                    div
                        [ style "text-align" "center"
                        , style "margin" "20px 0"
                        , style "color" "#ff4444"
                        ]
                        [ text error ]

                _ ->
                    text ""
            ]
        , main_
            [ style "display" "flex"
            , style "gap" "40px"
            ]
            [ if model.status == Initial then
                div
                    [ style "flex" "2"
                    , style "display" "flex"
                    , style "justify-content" "center"
                    , style "align-items" "center"
                    , style "color" "#666"
                    , style "font-style" "italic"
                    ]
                    [ text "Enter your BGG username to load your games" ]

              else if List.isEmpty model.games && model.status == Loaded then
                div
                    [ style "flex" "2"
                    , style "display" "flex"
                    , style "justify-content" "center"
                    , style "align-items" "center"
                    , style "color" "#666"
                    ]
                    [ text "No games found in your collection" ]

              else
                section
                    [ style "flex" "2"
                    , style "display" "grid"
                    , style "grid-template-columns" "repeat(auto-fill, minmax(250px, 1fr))"
                    , style "gap" "20px"
                    ]
                    (List.map
                        (\game ->
                            div
                                [ style "background"
                                    (if Set.member game.id model.selectedGames then
                                        "#e0f0ff"

                                     else if model.hoveredGame == Just game.name then
                                        "#e8e8e8"

                                     else
                                        "#f5f5f5"
                                    )
                                , style "padding" "20px"
                                , style "border-radius" "8px"
                                , style "cursor" "pointer"
                                , style "transition" "all 0.2s"
                                , style "transform"
                                    (if model.hoveredGame == Just game.name then
                                        "translateY(-2px)"

                                     else
                                        "none"
                                    )
                                , style "border"
                                    (if Set.member game.id model.selectedGames then
                                        "2px solid #4CAF50"

                                     else
                                        "none"
                                    )
                                , onClick (ToggleGameSelection game)
                                , Html.Events.onMouseEnter (HoverGame game.name)
                                , Html.Events.onMouseLeave UnhoverGame
                                ]
                                [ div
                                    [ style "display" "flex"
                                    , style "align-items" "center"
                                    , style "gap" "15px"
                                    , style "margin-bottom" "10px"
                                    ]
                                    [ img
                                        [ style "width" "50px"
                                        , style "height" "50px"
                                        , style "object-fit" "cover"
                                        , style "border-radius" "4px"
                                        , src game.thumbnail
                                        ]
                                        []
                                    , h2
                                        [ style "margin" "0"
                                        , style "font-size" "1.2em"
                                        ]
                                        [ text game.name ]
                                    ]
                                , div
                                    [ style "color" "#666" ]
                                    [ div [] [ text ("Players: " ++ String.fromInt game.minPlayers ++ "-" ++ String.fromInt game.maxPlayers) ]
                                    , div [] [ text ("Play time: " ++ String.fromInt game.playingTime ++ " min") ]
                                    ]
                                ]
                        )
                        model.games
                    )
            , section
                [ style "flex" "1"
                , style "background" "#f5f5f5"
                , style "padding" "20px"
                , style "border-radius" "8px"
                , style "height" "fit-content"
                ]
                [ let
                    selectedGamesCount =
                        Set.size model.selectedGames

                    selectedGamesList =
                        List.filter (\game -> Set.member game.id model.selectedGames) model.games
                  in
                  if selectedGamesCount > 0 then
                    div
                        [ style "display" "flex"
                        , style "flex-direction" "column"
                        , style "gap" "15px"
                        ]
                        [ h2 [] [ text ("Selected Games (" ++ String.fromInt selectedGamesCount ++ ")") ]
                        , div
                            [ style "display" "flex"
                            , style "flex-direction" "column"
                            , style "gap" "20px"
                            ]
                            (List.map
                                (\game ->
                                    div
                                        [ style "display" "flex"
                                        , style "gap" "20px"
                                        , style "padding" "15px"
                                        , style "background" "#fff"
                                        , style "border-radius" "8px"
                                        ]
                                        [ img
                                            [ style "width" "80px"
                                            , style "height" "80px"
                                            , style "object-fit" "cover"
                                            , style "border-radius" "4px"
                                            , src game.thumbnail
                                            ]
                                            []
                                        , div
                                            [ style "color" "#666" ]
                                            [ div [ style "font-weight" "bold" ] [ text game.name ]
                                            , div [] [ text ("Players: " ++ String.fromInt game.minPlayers ++ "-" ++ String.fromInt game.maxPlayers) ]
                                            , div [] [ text ("Play time: " ++ String.fromInt game.playingTime ++ " min") ]
                                            ]
                                        ]
                                )
                                selectedGamesList
                            )
                        , button
                            [ style "background" "#ff4444"
                            , style "color" "white"
                            , style "border" "none"
                            , style "padding" "10px 20px"
                            , style "border-radius" "4px"
                            , style "cursor" "pointer"
                            , style "margin-top" "10px"
                            , onClick ClearSelection
                            ]
                            [ text "Clear All Selections" ]
                        ]

                  else
                    div
                        [ style "color" "#666"
                        , style "font-style" "italic"
                        ]
                        [ text "Select games from the list" ]
                ]
            ]
        ]

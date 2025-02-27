module BggApi exposing (..)

import Http
import Process
import Task
import Xml.Decode as XD exposing (Decoder, int, list, single, string, stringAttr)



-- Types for BGG API


type BggResponse
    = Queued
    | Ready (List BggGame)


type QueueResult
    = Retry
    | Success String
    | Failed Http.Error


type alias BggGame =
    { id : String
    , name : String
    , minPlayers : Int
    , maxPlayers : Int
    , playingTime : Int
    , thumbnail : String
    }



-- API endpoints


apiBaseUrl : String
apiBaseUrl =
    "https://boardgamegeek.com/xmlapi2"



-- HTTP requests


getUserCollection : String -> (Result Http.Error (List BggGame) -> msg) -> Cmd msg
getUserCollection username toMsg =
    let
        url =
            apiBaseUrl ++ "/collection?username=" ++ username ++ "&own=1&stats=1"

        retryAfter delay =
            Process.sleep delay
                |> Task.andThen (\_ -> makeRequest url)
                |> Task.attempt toMsg

        makeRequest : String -> Task.Task Http.Error (List BggGame)
        makeRequest url_ =
            Http.task
                { method = "GET"
                , headers = []
                , url = url_
                , body = Http.emptyBody
                , resolver = Http.stringResolver (handleResponse url_ retryAfter)
                , timeout = Nothing
                }
    in
    makeRequest url
        |> Task.attempt toMsg


handleResponse : String -> (Float -> Cmd msg) -> Http.Response String -> Result Http.Error (List BggGame)
handleResponse url retry response =
    case response of
        Http.BadStatus_ _ body ->
            case decodeQueuedMessage body of
                Just _ ->
                    -- If we get a queued message, retry after 2 seconds
                    Task.perform (\_ -> retry 2000) (Task.succeed ())
                        |> always (Err (Http.BadBody "Request queued, retrying..."))

                Nothing ->
                    Err (Http.BadStatus 429)

        Http.GoodStatus_ _ body ->
            case decodeXmlGames body of
                Ok games ->
                    Ok games

                Err e ->
                    Err (Http.BadBody ("Failed to decode games:" ++ e))

        _ ->
            Err (Http.BadBody "Unexpected response")



-- XML decoders


decodeQueuedMessage : String -> Maybe String
decodeQueuedMessage xml =
    XD.run (XD.path [ "message" ] (single string)) xml
        |> Result.toMaybe


decodeXmlGames : String -> Result String (List BggGame)
decodeXmlGames xml =
    XD.run decodeBggGameList xml


decodeBggGameList : Decoder (List BggGame)
decodeBggGameList =
    XD.path [ "item" ] (XD.list itemDecoder)


itemDecoder : Decoder BggGame
itemDecoder =
    XD.succeed BggGame
        |> XD.andMap (stringAttr "objectid")
        |> XD.andMap (XD.path [ "name" ] (single string))
        |> XD.andMap (XD.path [ "stats" ] (single (stringAttr "minplayers")) |> XD.map (String.toInt >> Maybe.withDefault 1))
        |> XD.andMap (XD.path [ "stats" ] (single (stringAttr "maxplayers")) |> XD.map (String.toInt >> Maybe.withDefault 4))
        |> XD.andMap (XD.path [ "stats" ] (single (stringAttr "playingtime")) |> XD.map (String.toInt >> Maybe.withDefault 30))
        |> XD.andMap (XD.path [ "thumbnail" ] (single string))

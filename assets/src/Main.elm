module Main exposing (main)

import Browser
import Html exposing (Html, div, i, img, p, text)
import Html.Attributes exposing (height, id, src, width)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required)
import RemoteData exposing (WebData)



---- API ----


type alias Path =
    { id : Int
    , next_url : String
    , image : String
    }


initialPath : Path
initialPath =
    { id = 0
    , next_url = "#catalog/0"
    , image = ""
    }


pathDecoder : Decode.Decoder Path
pathDecoder =
    Decode.succeed Path
        |> required "id" Decode.int
        |> required "next_url" Decode.string
        |> optional "image_path" Decode.string ""



---- MODEL ----


type alias Model =
    { total : Int
    , current : Path
    , previous : Path
    , next : Int
    , err : String
    , status : String
    , urls : List String
    }


initialModel : Model
initialModel =
    { total = 0
    , current = initialPath
    , previous = initialPath
    , next = 0
    , err = ""
    , status = "offline"
    , urls = []
    }


init : Flags -> ( Model, Cmd Msg )
init f =
    ( { initialModel | total = f.total }, fetchData initialModel.current.next_url )


fetchData : String -> Cmd Msg
fetchData anchor =
    let
        url =
            String.replace "#" "/api/offline/" anchor
    in
    Http.get
        { url = url
        , expect = Http.expectString (RemoteData.fromResult >> LoadData)
        }



--- UPDATE ---


type Msg
    = LoadData (WebData String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadData response ->
            case response of
                RemoteData.Success s ->
                    let
                        decodedPath =
                            Decode.decodeString pathDecoder s

                        path =
                            case decodedPath of
                                Ok p ->
                                    p

                                Err _ ->
                                    initialPath

                        cmd =
                            if List.length model.urls >= model.total then
                                Cmd.none

                            else
                                fetchData path.next_url

                        urls =
                            path.next_url :: model.urls
                    in
                    ( { model | current = path, next = model.next + 1, err = "", urls = urls }, cmd )

                RemoteData.Failure e ->
                    ( { model | err = errorToString e }, Cmd.none )

                -- )
                _ ->
                    ( model, Cmd.none )


errorToString : Http.Error -> String
errorToString err =
    case err of
        Http.Timeout ->
            "Timeout exceeded"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus status_code ->
            "Status code: " ++ String.fromInt status_code

        Http.BadBody text ->
            "Unexpected response from api: " ++ text

        Http.BadUrl url ->
            "Malformed url: " ++ url



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        perc =
            round ((toFloat (List.length model.urls) / toFloat model.total) * 100.0)

        image =
            if String.isEmpty model.current.image || perc == 100 then
                text ""

            else
                img [ src model.current.image, width 100, height 100 ] []
    in
    div [ id "progress" ]
        [ p [ id "catalog" ]
            [ i [] [ text (String.fromInt perc ++ "%") ]
            ]
        , p [] [ image ]
        , p [ id "status" ] [ text model.status ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- Time.every (1 * 100) GetNext
---- PROGRAM ----


type alias Flags =
    { total : Int
    }


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }

module App exposing (main)

import Browser
import Browser.Events
import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Toasty
import Toasty.Defaults
import Process
import Task



---- MODEL ----


type alias Model =
    { toasties : Toasty.Stack Toasty.Defaults.Toast
    , flag : Bool
    }


type Msg
    = KeyPressed String
    | BtnClicked String
    | ConditionFlipped
    | ToastyMsg (Toasty.Msg Toasty.Defaults.Toast Model)


keyDecoder : Json.Decode.Decoder Msg
keyDecoder =
    Json.Decode.map KeyPressed <|
        Json.Decode.field "key" Json.Decode.string


init : () -> ( Model, Cmd Msg )
init flags =
    ( { toasties = Toasty.initialState, flag = True }
    , Cmd.none
    )


myConfig : Toasty.Config Msg
myConfig =
    Toasty.Defaults.config
        |> Toasty.delay 5000


addToast : Toasty.Defaults.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addToast toast ( model, cmd ) =
    Toasty.addToast myConfig ToastyMsg toast ( model, cmd )


addToastIfUnique : Toasty.Defaults.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addToastIfUnique toast ( model, cmd ) =
    Toasty.addToastIfUnique myConfig ToastyMsg toast ( model, cmd )


addPersistentToast : Toasty.Defaults.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addPersistentToast toast ( model, cmd ) =
    Toasty.addPersistentToast myConfig ToastyMsg toast ( model, cmd )


addConditionalToast : (Model -> Bool) -> Toasty.Defaults.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addConditionalToast condition toast ( model, cmd ) =
    Toasty.addConditionalToast condition myConfig ToastyMsg toast ( model, cmd )


---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPressed keycode ->
            case keycode of
                "s" ->
                    ( model
                    , Cmd.none
                    )
                        |> addToast (Toasty.Defaults.Success "Allright!" "Thing successfully updated")

                "w" ->
                    ( model
                    , Cmd.none
                    )
                        |> addToast (Toasty.Defaults.Warning "Warning!" "Please check this and that.")

                "e" ->
                    ( model
                    , Cmd.none
                    )
                        |> addToast (Toasty.Defaults.Error "Error" "Sorry, something went wrong...")

                "p" ->
                    ( model
                    , Cmd.none
                    )
                        |> addPersistentToast (Toasty.Defaults.Success "Persistent Toast" "This toast will remain visible until clicked.")

                "u" ->
                    ( model
                    , Cmd.none
                    )
                        |> addToastIfUnique (Toasty.Defaults.Success "Unique toast" "Avoid repeated notifications")

                "c" ->
                    ( model
                    , Cmd.none
                    )
                        |> addConditionalToast (\m -> m.flag) (Toasty.Defaults.Success "Conditional toast" "Will be removed when condition is false")

                _ ->
                    ( model
                    , Cmd.none
                    )

        BtnClicked "success" ->
            ( model
            , Cmd.none
            )
                |> addToast (Toasty.Defaults.Success "Allright!" "Thing successfully updated")

        BtnClicked "warning" ->
            ( model
            , Cmd.none
            )
                |> addToast (Toasty.Defaults.Warning "Warning!" "Please check this and that.")

        BtnClicked "error" ->
            ( model
            , Cmd.none
            )
                |> addToast (Toasty.Defaults.Error "Error" "Sorry, something went wrong...")

        BtnClicked "persistent" ->
            ( model
            , Cmd.none
            )
                |> addPersistentToast (Toasty.Defaults.Success "Persistent Toast" "This toast will remain visible until clicked.")

        BtnClicked "unique" ->
            ( model
            , Cmd.none
            )
                |> addToastIfUnique (Toasty.Defaults.Success "Unique toast" "Avoid repeated notifications")

        BtnClicked "conditional" ->
            ( model
            , Task.perform (\() -> ConditionFlipped) (Process.sleep 5000)
            )
                |> addConditionalToast (\m -> m.flag) (Toasty.Defaults.Success "Conditional toast" "Will be removed when condition is false")

        BtnClicked _ ->
            ( model
            , Cmd.none
            )

        ConditionFlipped ->
            ( { model | flag = not model.flag }
            , Cmd.none
            )

        ToastyMsg subMsg ->
            Toasty.update myConfig ToastyMsg subMsg model



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Toasty demo" ]
        , p []
            [ text "Click for adding a "
            , button [ class "btn success", type_ "button", onClick <| BtnClicked "success" ] [ text "success" ]
            , text ", "
            , button [ class "btn warning", type_ "button", onClick <| BtnClicked "warning" ] [ text "warning" ]
            , text ", "
            , button [ class "btn error", type_ "button", onClick <| BtnClicked "error" ] [ text "error" ]
            , text ", "
            , button [ class "btn", type_ "button", onClick <| BtnClicked "persistent" ] [ text "persistent" ]
            , text ", "
            , button [ class "btn", type_ "button", onClick <| BtnClicked "unique" ] [ text "unique" ]
            , text " or "
            , button [ class "btn", type_ "button", onClick <| BtnClicked "conditional" ] [ text "conditional" ]
            , text " toast."
            ]
        , p []
            [ text "Also you can press in your keyboard "
            , kbd [] [ text "[s]" ]
            , text " for success, "
            , kbd [] [ text "[w]" ]
            , text " for warning, "
            , kbd [] [ text "[e]" ]
            , text " for error, "
            , kbd [] [ text "[p]" ]
            , text " for persistent, "
            , kbd [] [ text "[u]" ]
            , text " for unique or "
            , kbd [] [ text "[c]" ]
            , text " for conditional toasts."
            ]
        , p [ class "help small" ] [ text "Click on any toast to remove it." ]
        , p [] [ text "This demo uses ", code [] [ text "Toasty.Defaults" ], text " for styling." ]
        , p []
            [ a [ href "http://package.elm-lang.org/packages/pablen/toasty/latest" ]
                [ text "Toasty at package.elm-lang.org" ]
            ]
        , Toasty.view myConfig Toasty.Defaults.view ToastyMsg model.toasties
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Browser.Events.onKeyPress keyDecoder
        }

module App exposing (..)

import Html.Attributes exposing (..)
import Html exposing (..)
import Toasty.Defaults
import Keyboard
import Toasty
import Char


---- MODEL ----


type alias Model =
    { toasties : Toasty.Stack Toasty.Defaults.Toast
    }


type Msg
    = KeyPressed Keyboard.KeyCode
    | ToastyMsg (Toasty.Msg Toasty.Defaults.Toast)


init : ( Model, Cmd Msg )
init =
    { toasties = Toasty.initialState } ! []


myConfig : Toasty.Config Msg
myConfig =
    Toasty.Defaults.config
        |> Toasty.delay 5000


addToast : Toasty.Defaults.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addToast toast ( model, cmd ) =
    Toasty.addToast myConfig ToastyMsg toast ( model, cmd )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPressed keycode ->
            case Char.fromCode keycode of
                's' ->
                    (model ! [])
                        |> addToast (Toasty.Defaults.Success "Allright!" "Thing successfully updated")

                'w' ->
                    (model ! [])
                        |> addToast (Toasty.Defaults.Warning "Warning!" "Please check this and that.")

                'e' ->
                    (model ! [])
                        |> addToast (Toasty.Defaults.Error "Error" "Sorry, something went wrong...")

                _ ->
                    (model ! [])

        ToastyMsg subMsg ->
            Toasty.update myConfig ToastyMsg subMsg model



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Toasty demo" ]
        , div [] [ text (toString model.toasties) ]
        , p []
            [ text "Press "
            , kbd [] [ text "[s]" ]
            , text " for success, "
            , kbd [] [ text "[w]" ]
            , text " for warning or "
            , kbd [] [ text "[e]" ]
            , text " for error toasts."
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


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Keyboard.presses KeyPressed
        }

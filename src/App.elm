module App exposing (..)

import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html exposing (..)
import MyToasties
import Toasty


---- MODEL ----


type alias Model =
    { toasties : Toasty.Stack MyToasties.Toast Msg
    }


init : ( Model, Cmd Msg )
init =
    { toasties = Toasty.initialState } ! []


addToast : MyToasties.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addToast toast ( model, cmd ) =
    Toasty.addToast MyToasties.config ToastyMsg toast ( model, cmd )



---- UPDATE ----


type Msg
    = NoOp
    | Click
    | ToastyMsg (Toasty.Msg MyToasties.Toast)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Click ->
            ( model, Cmd.none )
                |> addToast (MyToasties.Warning "Damn bro!")

        ToastyMsg subMsg ->
            Toasty.update MyToasties.config ToastyMsg subMsg model



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Toasty example" ]
        , button [ type_ "button", onClick Click ] [ text "Add toast" ]
        , Toasty.view MyToasties.config MyToasties.view model.toasties
        , hr [] []
        , code [] [ text <| toString model ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }

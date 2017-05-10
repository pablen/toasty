module Toasty
    exposing
        ( Stack
        , Config
        , Msg
        , transitionOutDuration
        , transitionOutClass
        , transitionInClass
        , initialState
        , addToast
        , config
        , update
        , delay
        , view
        )

import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html exposing (..)
import Process
import Time
import Task


-- VIEW


view : (a -> Html msg) -> Stack a -> Html msg
view toastView (Stack toasts) =
    div [ class "container" ] <| List.map (\x -> renderToast x toastView) toasts


renderToast : ( Id, a, String ) -> (a -> Html msg) -> Html msg
renderToast ( id, toast, status ) toastView =
    div [ class "item", class status ] [ toastView toast ]



-- MODEL


type Stack a
    = Stack (List ( Id, a, String ))


type Msg a
    = Add a
    | Remove Id
    | TransitionOut Id


type alias Id =
    Int


type Config
    = Config
        { transitionOutDuration : Float
        , transitionOutClass : String
        , transitionInClass : String
        , delay : Float
        }


config : Config
config =
    Config
        { transitionOutDuration = 700
        , transitionOutClass = "animated fadeOutRightBig"
        , transitionInClass = "animated bounceInRight"
        , delay = 4000
        }


transitionOutDuration : Float -> Config -> Config
transitionOutDuration time (Config cfg) =
    Config { cfg | transitionOutDuration = time }


transitionInClass : String -> Config -> Config
transitionInClass className (Config cfg) =
    Config { cfg | transitionInClass = className }


transitionOutClass : String -> Config -> Config
transitionOutClass className (Config cfg) =
    Config { cfg | transitionOutClass = className }


delay : Float -> Config -> Config
delay time (Config cfg) =
    Config { cfg | delay = time }



-- UPDATE


initialState : Stack a
initialState =
    Stack []


update : Config -> (Msg a -> msg) -> Msg a -> { m | toasties : Stack a } -> ( { m | toasties : Stack a }, Cmd msg )
update config tagger msg model =
    let
        (Config cfg) =
            config

        (Stack toasts) =
            model.toasties
    in
        case msg of
            Add toast ->
                addToast config tagger toast ( model, Cmd.none )

            Remove targetId ->
                let
                    newStack =
                        List.filter (\( id, toast, status ) -> id /= targetId) toasts
                in
                    { model | toasties = (Stack newStack) } ! []

            TransitionOut targetId ->
                let
                    newStack =
                        List.map
                            (\( id, toast, status ) ->
                                if (id == targetId) then
                                    ( id, toast, cfg.transitionOutClass )
                                else
                                    ( id, toast, status )
                            )
                            toasts
                in
                    { model | toasties = Stack newStack }
                        ! [ Task.perform (\() -> tagger (Remove targetId)) (Process.sleep <| cfg.transitionOutDuration * Time.millisecond) ]


addToast : Config -> (Msg a -> msg) -> a -> ( { m | toasties : Stack a }, Cmd msg ) -> ( { m | toasties : Stack a }, Cmd msg )
addToast config tagger toast ( model, cmd ) =
    let
        (Config cfg) =
            config

        (Stack toasts) =
            model.toasties

        newId =
            getNewId <| Stack toasts

        newToast =
            ( newId, toast, cfg.transitionInClass )

        newStack =
            toasts ++ [ newToast ]
    in
        { model | toasties = Stack newStack }
            ! ([ cmd, Task.perform (\() -> tagger (TransitionOut newId)) (Process.sleep <| cfg.delay * Time.millisecond) ])


getNewId : Stack a -> Id
getNewId (Stack toasts) =
    let
        ids =
            List.map (\( id, toast, status ) -> id) toasts

        getNext index list =
            if (List.member index list) then
                getNext (index + 1) list
            else
                index
    in
        getNext 0 ids

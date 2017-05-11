module Toasty
    exposing
        ( Config
        , Stack
        , Msg
        , transitionOutDuration
        , transitionOutAttrs
        , transitionInAttrs
        , containerAttrs
        , initialState
        , itemAttrs
        , addToast
        , config
        , update
        , delay
        , view
        )

import Html.Attributes exposing (..)
import Html exposing (..)
import Html.Keyed
import Process
import Time
import Task


-- VIEW


view : Config msg -> (a -> Html msg) -> Stack a msg -> Html msg
view config userView (Stack toasts) =
    let
        (Config cfg) =
            config
    in
        if (List.isEmpty toasts) then
            text ""
        else
            Html.Keyed.ol cfg.containerAttrs <| List.map (\toast -> itemContainer config toast userView) toasts


itemContainer : Config msg -> ( Id, a, List (Html.Attribute msg) ) -> (a -> Html msg) -> ( String, Html msg )
itemContainer (Config cfg) ( id, toast, attrs ) toastView =
    ( toString id
    , li
        (cfg.itemAttrs ++ attrs)
        [ toastView toast ]
    )



-- MODEL


type Stack a msg
    = Stack (List ( Id, a, List (Html.Attribute msg) ))


type Msg a
    = Add a
    | Remove Id
    | TransitionOut Id


type alias Id =
    Int


type Config msg
    = Config
        { transitionOutDuration : Float
        , transitionOutAttrs : List (Html.Attribute msg)
        , transitionInAttrs : List (Html.Attribute msg)
        , containerAttrs : List (Html.Attribute msg)
        , itemAttrs : List (Html.Attribute msg)
        , delay : Float
        }


config : Config msg
config =
    Config
        { transitionOutDuration = 700
        , transitionOutAttrs = [ class "animated fadeOutRightBig" ]
        , transitionInAttrs = [ class "animated bounceInRight" ]
        , containerAttrs = []
        , itemAttrs = []
        , delay = 4000
        }


transitionOutDuration : Float -> Config msg -> Config msg
transitionOutDuration time (Config cfg) =
    Config { cfg | transitionOutDuration = time }


transitionInAttrs : List (Html.Attribute msg) -> Config msg -> Config msg
transitionInAttrs attrs (Config cfg) =
    Config { cfg | transitionInAttrs = attrs }


transitionOutAttrs : List (Html.Attribute msg) -> Config msg -> Config msg
transitionOutAttrs attrs (Config cfg) =
    Config { cfg | transitionOutAttrs = attrs }


containerAttrs : List (Html.Attribute msg) -> Config msg -> Config msg
containerAttrs attrs (Config cfg) =
    Config { cfg | containerAttrs = attrs }


itemAttrs : List (Html.Attribute msg) -> Config msg -> Config msg
itemAttrs attrs (Config cfg) =
    Config { cfg | itemAttrs = attrs }


delay : Float -> Config msg -> Config msg
delay time (Config cfg) =
    Config { cfg | delay = time }



-- UPDATE


initialState : Stack a msg
initialState =
    Stack []


update : Config msg -> (Msg a -> msg) -> Msg a -> { m | toasties : Stack a msg } -> ( { m | toasties : Stack a msg }, Cmd msg )
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
                                    ( id, toast, cfg.transitionOutAttrs )
                                else
                                    ( id, toast, status )
                            )
                            toasts
                in
                    { model | toasties = Stack newStack }
                        ! [ Task.perform (\() -> tagger (Remove targetId)) (Process.sleep <| cfg.transitionOutDuration * Time.millisecond) ]


addToast : Config msg -> (Msg a -> msg) -> a -> ( { m | toasties : Stack a msg }, Cmd msg ) -> ( { m | toasties : Stack a msg }, Cmd msg )
addToast config tagger toast ( model, cmd ) =
    let
        (Config cfg) =
            config

        (Stack toasts) =
            model.toasties

        newId =
            getNewId <| Stack toasts

        newToast =
            ( newId, toast, cfg.transitionInAttrs )

        newStack =
            toasts ++ [ newToast ]
    in
        { model | toasties = Stack newStack }
            ! ([ cmd, Task.perform (\() -> tagger (TransitionOut newId)) (Process.sleep <| cfg.delay * Time.millisecond) ])


getNewId : Stack a msg -> Id
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

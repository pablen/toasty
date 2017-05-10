module Toasty exposing (Stack, Msg, initialState, update, addToast)

import Process
import Time
import Task


-- MODEL


type Stack a
    = Stack (List ( Id, a, String ))


type Msg a
    = Add a
    | Remove Id
    | TransitionOut Id


type alias Id =
    Int



-- UPDATE


initialState : Stack a
initialState =
    Stack []


update : (m -> Stack a) -> (m -> Stack a -> m) -> (Msg a -> msg) -> Msg a -> m -> ( m, Cmd msg )
update getter setter tagger msg model =
    let
        (Stack toasts) =
            getter model
    in
        case msg of
            Add toast ->
                addToast getter setter tagger toast ( model, Cmd.none )

            Remove targetId ->
                let
                    newStack =
                        List.filter (\( id, toast, status ) -> id /= targetId) toasts
                in
                    setter model (Stack newStack) ! []

            TransitionOut targetId ->
                let
                    newStack =
                        List.map
                            (\( id, toast, status ) ->
                                if (id == targetId) then
                                    ( id, toast, "fadeOutRightBig" )
                                else
                                    ( id, toast, status )
                            )
                            toasts
                in
                    setter model (Stack newStack)
                        ! [ Task.perform (\() -> tagger (Remove targetId)) (Process.sleep <| 700 * Time.millisecond) ]


addToast : (m -> Stack a) -> (m -> Stack a -> m) -> (Msg a -> msg) -> a -> ( m, Cmd msg ) -> ( m, Cmd msg )
addToast getter setter tagger toast ( model, cmd ) =
    let
        (Stack toasts) =
            getter model

        newId =
            getNewId <| Stack toasts

        newToast =
            ( newId, toast, "bounceInRight" )

        newStack =
            toasts ++ [ newToast ]
    in
        setter model (Stack newStack)
            ! ([ cmd, Task.perform (\() -> tagger (TransitionOut newId)) (Process.sleep <| 4000 * Time.millisecond) ])


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

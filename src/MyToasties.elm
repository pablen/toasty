module MyToasties exposing (Toast(..), config, view)

import Html.Attributes exposing (..)
import Html exposing (..)
import Toasty.Styles
import Toasty


type Toast
    = Success String
    | Warning String
    | Error String


config : Toasty.Config a
config =
    Toasty.config
        |> Toasty.transitionOutDuration 700
        |> Toasty.transitionOutAttrs Toasty.Styles.transitionOutAttrs
        |> Toasty.transitionInAttrs Toasty.Styles.transitionInAttrs
        |> Toasty.containerAttrs Toasty.Styles.containerAttrs
        |> Toasty.itemAttrs Toasty.Styles.itemAttrs
        |> Toasty.delay 4000


view : Toast -> Html m
view t =
    case t of
        Success str ->
            div [ style [ ( "background-color", "green" ) ] ] [ text str ]

        Warning str ->
            div [ style [ ( "background-color", "orange" ) ] ] [ text str ]

        Error str ->
            div [ style [ ( "background-color", "red" ) ] ] [ text str ]

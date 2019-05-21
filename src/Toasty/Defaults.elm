module Toasty.Defaults exposing (Toast(..), config, view)

{-| This module provides a generic toast type with three variants (success, error and warning)
each one supports a title and optional secondary text.

**You need to load the provided `Defaults.css` file in your project**. `bounceInRight`
and `fadeOutRightBig` animations borrowed from [Animate.css](https://daneden.github.io/animate.css/)
project by Daniel Eden.

See a [demo](http://pablen-toasty-demo.surge.sh/).


# Definition

@docs Toast, config, view

-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Toasty


{-| This theme defines toasts of three variants: "Success", "Warning" and "Error".
Each of them accepts a title and an optional secondary text.
-}
type Toast
    = Success String String
    | Warning String String
    | Error String String


{-| Default theme configuration.
-}
config : Toasty.Config msg
config =
    Toasty.config
        |> Toasty.transitionOutDuration 700
        |> Toasty.transitionOutAttrs transitionOutAttrs
        |> Toasty.transitionInAttrs transitionInAttrs
        |> Toasty.containerAttrs containerAttrs
        |> Toasty.itemAttrs itemAttrs
        |> Toasty.delay 5000
        |> Toasty.check 1000


containerAttrs : List (Html.Attribute msg)
containerAttrs =
    [ style "position" "fixed"
    , style "top" "0"
    , style "right" "0"
    , style "width" "100%"
    , style "max-width" "300px"
    , style "list-style-type" "none"
    , style "padding" "0"
    , style "margin" "0"
    ]


itemAttrs : List (Html.Attribute msg)
itemAttrs =
    [ style "margin" "1em 1em 0 1em"
    , style "max-height" "100px"
    , style "transition" "max-height 0.6s, margin-top 0.6s"
    ]


transitionInAttrs : List (Html.Attribute msg)
transitionInAttrs =
    [ class "animated bounceInRight"
    ]


transitionOutAttrs : List (Html.Attribute msg)
transitionOutAttrs =
    [ class "animated fadeOutRightBig"
    , style "max-height" "0"
    , style "margin-top" "0"
    ]


{-| Default theme view handling the three toast variants.
-}
view : Toast -> Html msg
view toast =
    case toast of
        Success title message ->
            genericToast "toasty-success" title message

        Warning title message ->
            genericToast "toasty-warning" title message

        Error title message ->
            genericToast "toasty-error" title message


genericToast : String -> String -> String -> Html msg
genericToast variantClass title message =
    div
        [ class "toasty-container", class variantClass ]
        [ h1 [ class "toasty-title" ] [ text title ]
        , if String.isEmpty message then
            text ""

          else
            p [ class "toasty-message" ] [ text message ]
        ]

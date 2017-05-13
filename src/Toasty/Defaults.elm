module Toasty.Defaults
    exposing
        ( Toast(..)
        , config
        , view
        )

{-| This package lets you easily show customizable toast notifications in your Elm apps. You
will be able to trigger toasts as a side-effect of model updates by piping your update function
return value through this library 'addToast' function.

# Definition
@docs Toast, config, view
-}

import Html.Attributes exposing (..)
import Html exposing (..)
import Toasty


{-| This theme defines toasts of three variants: "Success", "Warning" and "Error".
Each of them accepts a title and an optional secondary message.
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


containerAttrs : List (Html.Attribute msg)
containerAttrs =
    [ style
        [ ( "position", "fixed" )
        , ( "top", "0" )
        , ( "right", "0" )
        , ( "width", "100%" )
        , ( "max-width", "300px" )
        , ( "list-style-type", "none" )
        , ( "padding", "0" )
        , ( "margin", "0" )
        ]
    ]


itemAttrs : List (Html.Attribute msg)
itemAttrs =
    [ style
        [ ( "margin", "1em 1em 0 1em" )
        , ( "max-height", "100px" )
        , ( "transition", "max-height 0.6s, margin-top 0.6s" )
        ]
    ]


transitionInAttrs : List (Html.Attribute msg)
transitionInAttrs =
    [ class "animated bounceInRight"
    ]


transitionOutAttrs : List (Html.Attribute msg)
transitionOutAttrs =
    [ class "animated fadeOutRightBig"
    , style
        [ ( "max-height", "0" )
        , ( "margin-top", "0" )
        ]
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
        , if (String.isEmpty message) then
            text ""
          else
            p [ class "toasty-message" ] [ text message ]
        ]

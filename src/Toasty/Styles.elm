module Toasty.Styles
    exposing
        ( transitionOutAttrs
        , transitionInAttrs
        , containerAttrs
        , itemAttrs
        )

import Html.Attributes exposing (..)
import Html exposing (..)


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
        , ( "max-height", "30px" )
        , ( "transition", "max-height 0.6s, margin 0.6s" )
        ]
    ]


transitionOutAttrs : List (Html.Attribute msg)
transitionOutAttrs =
    [ class "animated fadeOutRightBig"
    , style
        [ ( "max-height", "0" )
        , ( "margin", "0" )
        ]
    ]


transitionInAttrs : List (Html.Attribute msg)
transitionInAttrs =
    [ class "animated bounceInRight"
    ]

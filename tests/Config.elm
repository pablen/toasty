module Config exposing (all)

import Html.Attributes exposing (..)
import Html exposing (..)
import Test exposing (..)
import Html.Keyed
import Expect
import Toasty


type alias Toast =
    String


type Msg
    = Tagger (Toasty.Msg Toast)


initialModel : { toasties : Toasty.Stack Toast }
initialModel =
    { toasties = Toasty.initialState }


renderToast : Toast -> Html Msg
renderToast toast =
    div [] [ text toast ]


all : Test
all =
    describe "HTML rendering"
        [ test "Initially renders an empty text node" <|
            \() ->
                let
                    view =
                        Toasty.view Toasty.config renderToast Tagger initialModel.toasties
                in
                    Expect.equal view (text "")
        , test "Renders list of toasts after adding toasts" <|
            \() ->
                let
                    ( model, cmd ) =
                        (initialModel ! [])
                            |> Toasty.addToast Toasty.config Tagger "foo"
                            |> Toasty.addToast Toasty.config Tagger "bar"

                    view =
                        Toasty.view Toasty.config renderToast Tagger model.toasties
                in
                    Expect.equal view
                        (Html.Keyed.ol []
                            [ ( "0", li [] [ div [] [ text "foo" ] ] )
                            , ( "1", li [] [ div [] [ text "bar" ] ] )
                            ]
                        )
        , test "Can add custom attributes to list container" <|
            \() ->
                let
                    ( model, cmd ) =
                        (initialModel ! [])
                            |> Toasty.addToast Toasty.config Tagger "foo"

                    myConfig =
                        Toasty.config
                            |> Toasty.containerAttrs [ class "myClass", style [ ( "color", "red" ) ] ]

                    view =
                        Toasty.view myConfig renderToast Tagger model.toasties
                in
                    Expect.equal view
                        (Html.Keyed.ol [ class "myClass", style [ ( "color", "red" ) ] ]
                            [ ( "0", li [] [ div [] [ text "foo" ] ] )
                            ]
                        )
        , test "Can add custom attributes to toast container" <|
            \() ->
                let
                    ( model, cmd ) =
                        (initialModel ! [])
                            |> Toasty.addToast Toasty.config Tagger "foo"

                    myConfig =
                        Toasty.config
                            |> Toasty.itemAttrs [ class "itemClass", style [ ( "color", "blue" ) ] ]

                    view =
                        Toasty.view myConfig renderToast Tagger model.toasties
                in
                    Expect.equal view
                        (Html.Keyed.ol []
                            [ ( "0", li [ class "itemClass", style [ ( "color", "blue" ) ] ] [ div [] [ text "foo" ] ] )
                            ]
                        )
        , test "Can add custom attributes to toast container when transitioning in" <|
            \() ->
                let
                    ( model, cmd ) =
                        (initialModel ! [])
                            |> Toasty.addToast Toasty.config Tagger "foo"

                    myConfig =
                        Toasty.config
                            |> Toasty.transitionInAttrs [ class "fadeIn", style [ ( "color", "green" ) ] ]

                    view =
                        Toasty.view myConfig renderToast Tagger model.toasties
                in
                    Expect.equal view
                        (Html.Keyed.ol []
                            [ ( "0", li [ class "fadeIn", style [ ( "color", "green" ) ] ] [ div [] [ text "foo" ] ] )
                            ]
                        )
        ]

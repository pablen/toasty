module Config exposing (all)

import Test.Html.Selector as Selector
import Test.Html.Query as Query
import Html.Attributes exposing (..)
import Html exposing (..)
import Test exposing (..)
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
                    view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "li" ]
                        |> Expect.all
                            [ Query.index 0 >> Query.has [ Selector.text "foo" ]
                            , Query.index 1 >> Query.has [ Selector.text "bar" ]
                            ]
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
                    -- elm-test can't test style attributess ATM https://github.com/eeue56/elm-html-test/issues/3
                    view
                        |> Query.fromHtml
                        |> Query.has [ Selector.className "myClass" ]
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
                    -- elm-test can't test style attributess ATM https://github.com/eeue56/elm-html-test/issues/3
                    view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "li" ]
                        |> Query.each (Query.has [ Selector.className "itemClass" ])
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
                    -- elm-test can't test style attributess ATM https://github.com/eeue56/elm-html-test/issues/3
                    view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "li" ]
                        |> Query.each (Query.has [ Selector.className "fadeIn" ])
        ]

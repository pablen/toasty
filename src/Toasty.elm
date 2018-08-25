module Toasty exposing
    ( Stack, Msg
    , config, delay, transitionOutDuration, containerAttrs, itemAttrs, transitionInAttrs, transitionOutAttrs, Config
    , view, update, addToast, addToastIf, addToastIfUnique, hasToast, initialState
    )

{-| This package lets you easily show customizable toast notifications in your
Elm apps following The Elm Architecture. You will be able to trigger toasts as
a side-effect of model updates by piping your update function return value
through this library `addToast` function.

While this package lets you configure each part of the rendering and behaviour
of the notification stack, you can use a nice default theme configuration provided
in `Toasty.Defaults`. See a [demo using default styling](http://pablen-toasty-demo.surge.sh/).


## Example


### Setting things up

To use the package, let's look at an example that shows a simple text notification.

First you add the toast stack to your model, wrapping the toast model you want in `Stack`.
You must do it in a field called `toasties`:

    type alias Model =
        { toasties : Toasty.Stack String }

Note that in this example we are modelling our toasts as a simple `String`,
but we can model our toasts however we need.

Add the stack initial state in your `init` function:

    init : ( Model, Cmd Msg )
    init =
        ( { toasties = Toasty.initialState }, Cmd.none )

Then add a message that will handle toasts messages:

    type alias Msg =
        ToastyMsg (Toasty.Msg String)

You can use the default configuration as-is or tweak it to your needs by piping configuration helpers:

    myConfig : Toasty.Config msg
    myConfig =
        Toasty.config
            |> Toasty.transitionOutDuration 100
            |> Toasty.delay 8000

Handle the toasts message in your app update function using the library `update`
function:

    update msg model =
        case msg of
            ToastyMsg subMsg ->
                Toasty.update myConfig ToastyMsg subMsg model

As a last step, render the toast stack in you `view` function. You will need to
provide a special view function that knows how to render your toast model:

    view : Model -> Html Msg
    view model =
        div []
            [ h1 [] [ text "Toasty example" ]
            , Toasty.view myConfig renderToast ToastyMsg model.toasties
            ]

    renderToast : String -> Html Msg
    renderToast toast =
        div [] [ text toast ]


### Triggering toasts

A pretty common scenario is to trigger toasts as side-effect of some other app event,
e.g. show a message when an asynchronous response was received. In order to do that, just
pipe your update function return value through the `addToast` function passing your
configuration, tag and toast.

        update msg model =
            case msg of
                SomeAppMsg ->
                    ( newModel, Cmd.none )
                        |> Toasty.addToast myConfig ToastyMsg "Entity successfully created!"

That's all!


# Definition

@docs Stack, Msg


# Configuration

The notifications appearance and behaviour can be fully customized. To do this,
you need to import the default configuration and tweak it by piping the provided
helper functions.

Note that as you can set container and items HTML attributes the library remains
agnostic about how to style your toasts, enabling you to use inline styles or
classes.

    myConfig : Toasty.Config msg
    myConfig =
        Toasty.config
            |> Toasty.transitionOutDuration 700
            |> Toasty.delay 8000
            |> Toasty.containerAttrs containerAttrs

    containerAttrs =
        [ style "max-width" "300px"
        , style "position" "fixed"
        , style "right" "0"
        , style "top" "0"
        ]

@docs config, delay, transitionOutDuration, containerAttrs, itemAttrs, transitionInAttrs, transitionOutAttrs, Config


# Other functions

@docs view, update, addToast, addToastIf, addToastIfUnique, hasToast, initialState

-}

import Html exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Process
import Random exposing (Seed)
import Task


{-| Represents the stack of current toasts notifications. You can model a toast
to be as complex or simple as you want.

    type alias Model =
        { toasties : Toasty.Stack MyToast
        }


    -- Defines a toast model that has three different variants
    type MyToast
        = Success String
        | Warning String
        | Error String String

-}
type Stack a
    = Stack (List ( Id, Status, a )) Seed


{-| The internal message type used by the library. You need to tag and add it to your app messages.

    type Msg
        = ToastyMsg (Toasty.Msg MyToast)

-}
type Msg a
    = Add a
    | Remove Id
    | TransitionOut Id


{-| The base configuration type.
-}
type Config msg
    = Config
        { transitionOutDuration : Float
        , transitionOutAttrs : List (Html.Attribute msg)
        , transitionInAttrs : List (Html.Attribute msg)
        , containerAttrs : List (Html.Attribute msg)
        , itemAttrs : List (Html.Attribute msg)
        , delay : Float
        }


type alias Id =
    Int


type Status
    = Entered
    | Leaving


{-| Some basic configuration defaults: Toasts are visible for 5 seconds with
no animations or special styling.
-}
config : Config msg
config =
    Config
        { transitionOutDuration = 0
        , transitionOutAttrs = []
        , transitionInAttrs = []
        , containerAttrs = []
        , itemAttrs = []
        , delay = 5000
        }


{-| Changes the amount of time (in milliseconds) to wait after transition out
begins and before actually removing the toast node from the DOM. This lets you
author fancy animations when a toast is removed.
-}
transitionOutDuration : Float -> Config msg -> Config msg
transitionOutDuration time (Config cfg) =
    Config { cfg | transitionOutDuration = time }


{-| Lets you set the HTML attributes to add to the toast container when transitioning in.
-}
transitionInAttrs : List (Html.Attribute msg) -> Config msg -> Config msg
transitionInAttrs attrs (Config cfg) =
    Config { cfg | transitionInAttrs = attrs }


{-| Lets you set the HTML attributes to add to the toast container when transitioning out.
-}
transitionOutAttrs : List (Html.Attribute msg) -> Config msg -> Config msg
transitionOutAttrs attrs (Config cfg) =
    Config { cfg | transitionOutAttrs = attrs }


{-| Lets you set the HTML attributes to add to the toasts stack container. This will help
you style and position the toast stack however you like by adding classes or inline styles.
-}
containerAttrs : List (Html.Attribute msg) -> Config msg -> Config msg
containerAttrs attrs (Config cfg) =
    Config { cfg | containerAttrs = attrs }


{-| Lets you set the HTML attributes to add to each toast container. This will help
you style and arrange the toasts however you like by adding classes or inline styles.
-}
itemAttrs : List (Html.Attribute msg) -> Config msg -> Config msg
itemAttrs attrs (Config cfg) =
    Config { cfg | itemAttrs = attrs }


{-| Changes the amount of time (in milliseconds) the toast will be visible.
After this time, the transition out begins.
-}
delay : Float -> Config msg -> Config msg
delay time (Config cfg) =
    Config { cfg | delay = time }


{-| An empty stack of toasts to initialize your model with.
-}
initialState : Stack a
initialState =
    Stack [] (Random.initialSeed 0)


{-| Handles the internal messages. You need to wire it to your app update function

    update msg model =
        case msg of
            ToastyMsg subMsg ->
                Toasty.update Toasty.config ToastyMsg subMsg model

-}
update : Config msg -> (Msg a -> msg) -> Msg a -> { m | toasties : Stack a } -> ( { m | toasties : Stack a }, Cmd msg )
update (Config cfg) tagger msg model =
    let
        (Stack toasts seed) =
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
            ( { model | toasties = Stack newStack seed }
            , Cmd.none
            )

        TransitionOut targetId ->
            let
                newStack =
                    List.map
                        (\( id, status, toast ) ->
                            if id == targetId then
                                ( id, Leaving, toast )

                            else
                                ( id, status, toast )
                        )
                        toasts
            in
            ( { model | toasties = Stack newStack seed }
            , Task.perform (\_ -> tagger (Remove targetId)) (Process.sleep <| cfg.transitionOutDuration)
            )


{-| Adds a toast to the stack and schedules its removal. It receives and returns
a tuple of type '(model, Cmd msg)' so that you can easily pipe it to your app
update function branches.

    update msg model =
        case msg of
            SomeAppMsg ->
                ( newModel, Cmd.none )
                    |> Toasty.addToast myConfig ToastyMsg (MyToast "Entity successfully created!")

            ToastyMsg subMsg ->
                Toasty.update myConfig ToastyMsg subMsg model

-}
addToast : Config msg -> (Msg a -> msg) -> a -> ( { m | toasties : Stack a }, Cmd msg ) -> ( { m | toasties : Stack a }, Cmd msg )
addToast (Config cfg) tagger toast ( model, cmd ) =
    let
        (Stack toasts seed) =
            model.toasties

        ( newId, newSeed ) =
            getNewId seed
    in
    ( { model | toasties = Stack (toasts ++ [ ( newId, Entered, toast ) ]) newSeed }
    , Cmd.batch [ cmd, Task.perform (\() -> tagger (TransitionOut newId)) (Process.sleep <| cfg.delay) ]
    )


{-| Similar to `addToast` but also receives a condition parameter `List toast -> Bool`
so that the toast will only be added if the condition returns `True`.
-}
addToastIf : Config msg -> (Msg a -> msg) -> (List a -> Bool) -> a -> ( { m | toasties : Stack a }, Cmd msg ) -> ( { m | toasties : Stack a }, Cmd msg )
addToastIf cfg tagger condition toast ( model, cmd ) =
    let
        (Stack toasts seed) =
            model.toasties

        shouldAddToast =
            toasts
                |> List.map (\( id, st, t ) -> t)
                |> condition
    in
    if shouldAddToast then
        addToast cfg tagger toast ( model, cmd )

    else
        ( model
        , Cmd.none
        )


{-| Similar to `addToast` but only effectively adds the toast if it's not already
present in the stack. This is a convenience `addToastIf` function using
`not << List.member toast` as a `condition` parameter.
-}
addToastIfUnique : Config msg -> (Msg a -> msg) -> a -> ( { m | toasties : Stack a }, Cmd msg ) -> ( { m | toasties : Stack a }, Cmd msg )
addToastIfUnique cfg tagger toast ( model, cmd ) =
    addToastIf cfg tagger (not << List.member toast) toast ( model, cmd )


{-| Figure out whether a stack contains a specific toast. Similar to `List.member`.
-}
hasToast : a -> Stack a -> Bool
hasToast toast (Stack toasts _) =
    toasts
        |> List.map (\( _, _, t ) -> t)
        |> List.member toast


{-| Renders the stack of toasts. You need to add it to your app view function and
give it a function that knows how to render your toasts model.

    view model =
        div []
            [ h1 [] [ text "Toasty example" ]
            , Toasty.view myConfig (\txt -> div [] [ text txt ]) ToastyMsg model.toasties
            ]

-}
view : Config msg -> (a -> Html msg) -> (Msg a -> msg) -> Stack a -> Html msg
view cfg toastView tagger (Stack toasts seed) =
    let
        (Config c) =
            cfg
    in
    if List.isEmpty toasts then
        text ""

    else
        Html.Keyed.ol c.containerAttrs <| List.map (\toast -> itemContainer cfg tagger toast toastView) toasts


getNewId : Seed -> ( Id, Seed )
getNewId seed =
    Random.step (Random.int Random.minInt Random.maxInt) seed


itemContainer : Config msg -> (Msg a -> msg) -> ( Id, Status, a ) -> (a -> Html msg) -> ( String, Html msg )
itemContainer (Config cfg) tagger ( id, status, toast ) toastView =
    let
        attrs =
            case status of
                Entered ->
                    cfg.transitionInAttrs

                Leaving ->
                    cfg.transitionOutAttrs
    in
    ( String.fromInt id, li (cfg.itemAttrs ++ attrs ++ [ onClick (tagger <| TransitionOut id) ]) [ toastView toast ] )

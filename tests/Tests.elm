module Tests exposing (all)

import Config
import Test exposing (..)


all : Test
all =
    describe "Toasty Test Suite"
        [ Config.all
        ]

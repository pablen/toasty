module Tests exposing (..)

import Config
import Test exposing (..)


all : Test
all =
    describe "Toasty Test Suite"
        [ Config.all
        ]

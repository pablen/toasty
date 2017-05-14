module Tests exposing (..)

import Test exposing (..)
import Config


all : Test
all =
    describe "Toasty Test Suite"
        [ Config.all
        ]

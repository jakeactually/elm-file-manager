port module FileManager.Port exposing (..)

import FileManager.Vec exposing (Bound)

port getBounds : () -> Cmd msg
port boundsGotten : (List Bound -> msg) -> Sub msg

port upload : String -> Cmd msg
port filesAmount : (Int -> msg) -> Sub msg
port progress : (Int -> msg) -> Sub msg
port cancel : () -> Cmd msg
port uploaded : (() -> msg) -> Sub msg

port download : List String -> Cmd msg

port open : (() -> msg) -> Sub msg
port close : List String -> Cmd msg

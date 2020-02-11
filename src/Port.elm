port module Port exposing (..)

port onOpen : (() -> msg) -> Sub msg
port close : List String -> Cmd msg
port download : List String -> Cmd msg

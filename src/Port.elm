port module Port exposing (..)

port onOpen : (() -> msg) -> Sub msg
port close : List String -> Cmd msg
port download : List String -> Cmd msg

port upload : String -> Cmd msg
port onFilesAmount : (Int -> msg) -> Sub msg
port onProgress : (Int -> msg) -> Sub msg
port onUploaded : (() -> msg) -> Sub msg

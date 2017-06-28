port module Port exposing (..)

import Vec exposing (Bound)

port askName : String -> Cmd msg
port rename : (String -> msg) -> Sub msg

port getBounds : () -> Cmd msg
port boundsGotten : (List Bound -> msg) -> Sub msg

port upload : String -> Cmd msg
port uploaded : (String -> msg) -> Sub msg

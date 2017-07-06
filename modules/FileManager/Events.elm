module FileManager.Events exposing (..)

import Json.Decode as Decode
import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions)
import FileManager.Vec exposing (..)

onMouseDown : (Vec2 -> Bool -> msg) -> Attribute msg
onMouseDown function  =
  onWithOptions "mousedown" (op True False) <| Decode.map3 (\a b c -> function (Vec2 a b) c)
    (Decode.field "clientX" Decode.int)
    (Decode.field "clientY" Decode.int)
    (Decode.field "ctrlKey" Decode.bool)

onMouseMove : (Vec2 -> msg) -> Attribute msg
onMouseMove function =
  onWithOptions "mousemove" (op True True) <| Decode.map2 (\x y -> function <| Vec2 x y)
    (Decode.field "clientX" Decode.int)
    (Decode.field "clientY" Decode.int)

onMouseUp : msg -> Attribute msg
onMouseUp function  =
  onWithOptions "mouseup" (op True False)  <| Decode.succeed function

onContextMenu : msg -> Attribute msg
onContextMenu function  =
  onWithOptions "contextmenu" (op True True)  <| Decode.succeed function

onChange : msg -> Attribute msg
onChange function =
  on "change" <| Decode.succeed function

op : Bool -> Bool -> { stopPropagation : Bool, preventDefault : Bool }
op b1 b2 = { stopPropagation = b1, preventDefault = b2 }

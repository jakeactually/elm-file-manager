module Events exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Html exposing (Attribute)
import Html.Events exposing (on, custom)
import Vec exposing (..)

onMouseDown : (Vec2 -> Bool -> msg) -> Attribute msg
onMouseDown function =
  custom "mousedown" <| options True False <| Decode.map3 (\a b c -> function (Vec2 a b) c)
    (Decode.field "clientX" Decode.float)
    (Decode.field "clientY" Decode.float)
    (Decode.field "ctrlKey" Decode.bool)

onMouseMove : (Vec2 -> msg) -> Attribute msg
onMouseMove function =
  custom "mousemove" <| options True True <| Decode.map2 (\x y -> function <| Vec2 x y)
    (Decode.field "clientX" Decode.float)
    (Decode.field "clientY" Decode.float)

onMouseUp : msg -> Attribute msg
onMouseUp message =
  custom "mouseup" <| options True False <| Decode.succeed message

onContextMenu : msg -> Attribute msg
onContextMenu message =
  custom "contextmenu" <| options True True <| Decode.succeed message

onChange : msg -> Attribute msg
onChange message =
  on "change" <| Decode.succeed message

onDragEnter : msg -> Attribute msg
onDragEnter message =
  on "dragenter" <| Decode.succeed message

onDragLeave : msg -> Attribute msg
onDragLeave message =
  on "dragleave" <| Decode.succeed message

onDragOver : msg -> Attribute msg
onDragOver message =
  custom "dragover" <| options False True <| Decode.succeed message

onDrop : msg -> Attribute msg
onDrop message =
  custom "drop" <| options False True <| Decode.succeed message

options : Bool -> Bool -> Decoder msg -> Decoder
    { message : msg
    , stopPropagation : Bool
    , preventDefault : Bool
    }
options stopPropagation preventDefault = Decode.map (\message ->
    { message = message
    , stopPropagation = stopPropagation
    , preventDefault = preventDefault
    })

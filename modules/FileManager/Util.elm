module FileManager.Util exposing (..)

import Html exposing (Attribute, Html, button, i, text)
import Html.Attributes exposing (class, title, type_)
import Html.Events exposing (onClick)
import FileManager.Model exposing (Msg)
import Array exposing (Array, fromList, get, toList)
import List exposing (drop, indexedMap, filter, map, map2, member, take)

-- List

(!!) : List a -> Int -> Maybe a
(!!) list index = get index <| fromList list

set : Int -> a -> List a -> List a
set index item list = toList <| Array.set index item <| fromList list

remove : Int -> List a -> List a
remove index list = take index list ++ drop (index + 1) list

zip : List a -> List b -> List (a, b)
zip = map2 (,)

indexedZip : List a -> List (Int, a)
indexedZip = indexedMap (,)

swap : Int -> Int -> List a -> List a
swap index1 index2 list = toList <| arraySwap index1 index2 <| fromList list

arraySwap : Int -> Int -> Array a -> Array a
arraySwap index1 index2 array =
  let
    maybe1 = get index1 array
    maybe2 = get index2 array
  in case (maybe1, maybe2) of
    (Just item1, Just item2) -> Array.set index1 item2 <| Array.set index2 item1 array
    _ -> array

-- Maybe

isJust : Maybe a -> Bool
isJust maybe = case maybe of
  Just _ -> True
  Nothing -> False

-- Component

button : List (Attribute msg) -> List (Html msg) -> Html msg
button atts childs = Html.button (type_ "button" :: atts) childs

icon : String -> String -> Msg -> Html Msg
icon text_ title_ msg = button [ type_ "button", class "icon", title title_, onClick msg ]
  [ i [ class "material-icons" ] [ text text_ ]
  ]

icon2 : String -> Html Msg
icon2 text_ =  i [ class "material-icons" ] [ text text_ ]

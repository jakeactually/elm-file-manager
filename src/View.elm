module View exposing (..)

import Events exposing (..)
import Html exposing (Attribute, Html, a, br, div, form, h1, i, input, img, label, strong, text, textarea)
import Html.Attributes exposing (attribute, action, class, draggable, id, hidden, href, method, multiple, src, style, target, title, type_, value)
import Html.Events exposing (onClick, onDoubleClick, onInput)
import List exposing (head, indexedMap, isEmpty, length, map, member, range, repeat, reverse, tail)
import Model exposing (..)
import Maybe exposing (andThen, withDefault)
import String exposing (fromInt, fromFloat, join, split)
import Svg exposing (svg, path, circle)
import Svg.Attributes exposing (cx, cy, d, width, height, fill, r, viewBox)
import Util exposing (button, isJust)
import Vec exposing (..)

view : Model -> Html Msg
view model = if model.open
  then div [ class "fm-simple-screen" ]
    [  div
      [ class "fm-main"
      , onMouseMove (\_ -> None)
      ]
      [ bar model.dir model.load
      , files model
      , div [ class "fm-control" ]
        [ button [ class "alert", onClick <| EnvMsg Close ] [ text "Cancelar" ]
        , button [ onClick <| EnvMsg Accept ] [ text "Aceptar" ]
        ]
      , if model.showBound then renderHelper model.bound else div [] []
      , if model.drag then renderCount model.pos2 model.selected else div [] []
      , if model.showContextMenu
          then contextMenu model.pos1 model.caller (not <| isEmpty model.clipboardFiles) (length model.selected > 1) model.filesAmount
          else div [] []
      , if model.showNameDialog then nameDialog model.name <| not <| isJust model.caller else div [] []
      ]
    ]
  else div [] []

bar : String -> Bool -> Html Msg
bar dir load = div [ class "fm-bar" ]
  [ arrowIcon <| EnvMsg <| GetLs <| back dir
  , div [ class "fm-text" ] [ text dir ]
  , if load
      then div [ class "fm-loader" ]
      [ svg [ width "25", height "25" ]
        [ circle [ cx "50%", cy "50%", r "40%" ] []
        ]
      ]
      else div [] []
  ]

files : Model -> Html Msg
files model = div
  [ class "fm-files"
  , class <| if model.drag then "fm-drag" else ""
  , onMouseDown (\x y -> EnvMsg <| MouseDown Nothing x y)
  , onMouseMove <| EnvMsg << MouseMove
  , onMouseUp <| EnvMsg <|  MouseUp Nothing
  , onDragEnter ShowDrop
  , onContextMenu <| EnvMsg <| ContextMenu Nothing
  ]
  [ div [ class "fm-wrap" ]
    [ div [ class "fm-fluid" ]
      <| indexedMap (renderFile model) model.files
      ++ reverse (map (renderUploading model.progress) (range 0 <| model.filesAmount - 1))
    ]
  , if model.showDrop
    then div [ class "fm-drop", onDragLeave HideDrop, onDragOver None, onDrop HideDrop ] []
    else div [] []
  ]

arrowIcon : Msg -> Html Msg
arrowIcon msg = button [ class "fm-arrow" ]
  [
    svg
    [ attribute "height" "24"
    , viewBox "0 0 24 24"
    , attribute "width" "24"
    , attribute "xmlns" "http://www.w3.org/2000/svg"
    , onClick msg
    ]
    [ path [ d "M0 0h24v24H0z", fill "none" ] []
    , path [ d "M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z", fill "#ffffff" ] []
    ]
  ]

back : String -> String
back route = "/" ++ (join "/" <| withDefault [] <| andThen tail <| tail <| reverse <| split "/" route)

renderUploading : Int -> Int -> Html Msg
renderUploading progress i = div [ class "fm-file fm-upload" ]
  [ div [ class "fm-thumb" ]
    [ if i == 0 then div [ class "fm-progress", style "width" (toPx <| toFloat progress) ] [] else div [] []
    ]
  , div [ class "fm-name" ] []
  ]

renderFile : Model -> Int -> File -> Html Msg
renderFile { api, thumbnailsUrl, dir, selected, clipboardDir, clipboardFiles } i file = div
  [ id <| "fm-file-" ++ fromInt i, class <| "fm-file"
      ++ (if member file selected then " fm-selected" else "")
      ++ (if dir == clipboardDir && member file clipboardFiles then " fm-cut" else "")
  , title file.name
  , onMouseDown <| (\x y -> EnvMsg <| MouseDown (Just file) x y)
  , onMouseUp <| EnvMsg <| MouseUp <| Just file
  , onContextMenu <| EnvMsg <| ContextMenu <| Just file
  , onDoubleClick <| if file.isDir then EnvMsg <| GetLs <| dir ++ file.name ++ "/" else Download
  ]
  [ renderThumb thumbnailsUrl api dir file
  , div [ class "fm-name" ] [ text file.name ]
  ]

renderThumb : String -> String -> String -> File -> Html Msg
renderThumb thumbApi api dir { name, isDir } = if isDir
  then div [ class "fm-thumb" ] [ fileIcon ]
  else renderFileThumb api thumbApi <| dir ++ name

fileIcon : Html Msg
fileIcon = svg [ attribute "height" "48", viewBox "0 0 24 24", attribute "width" "48", attribute "xmlns" "http://www.w3.org/2000/svg" ]
  [ path [ d "M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z", fill "#ffb900" ]
      []
  , path [ d "M0 0h24v24H0z", fill "none" ]
      []
  ]

renderFileThumb : String -> String -> String -> Html Msg
renderFileThumb api thumbApi fullName = if member (getExt fullName) ["jpg", "jpeg", "png", "PNG"]
  then div [ class "fm-thumb" ]
    [ img [ src <| thumbApi ++ fullName, draggable "false" ] []
    ]
  else div [ class "fm-thumb" ] [ folderIcon ]

folderIcon : Html Msg
folderIcon = svg [ attribute "height" "48", viewBox "0 0 24 24", attribute "width" "48", attribute "xmlns" "http://www.w3.org/2000/svg" ]
  [ path [ d "M6 2c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6H6zm7 7V3.5L18.5 9H13z", fill "#0078d4" ]
      []
  , path [ d "M0 0h24v24H0z", fill "none" ]
      []
  ]

getExt : String -> String
getExt name = withDefault "" <| head <| reverse <| split "." name

renderHelper : Bound -> Html Msg
renderHelper b = div
  [ class "fm-helper"
  , style "left" (toPx b.x)
  , style "top" (toPx b.y)
  , style "width" (toPx b.width)
  , style "height" (toPx b.height)
  ] []

toPx : Float -> String
toPx n = fromFloat n ++ "px"

renderCount : Vec2 -> List File -> Html Msg
renderCount (Vec2 x y) selected = div
  [ class "fm-count"
  , style "left" (toPx <| x + 5)
  , style "top" (toPx <| y - 25)
  ]
  [ text <| fromInt <| length <| selected
  ]

contextMenu : Vec2 -> Maybe File -> Bool -> Bool -> Int -> Html Msg
contextMenu (Vec2 x y) maybe paste many filesAmount = if filesAmount > 0
  then div [ class "fm-context-menu", style "left" (toPx x), style "top" (toPx y) ]
      [ button [ class "div white cancel", onClick Cancel ] [ text "Cancel" ]
      ]
  else div [ class "fm-context-menu", style "left" (toPx x), style "top" (toPx y) ] <| case maybe of
    Just file ->
      [ button [ class "div white", onClick Download ] [ text "Download" ]
      , button (if many then [ class "div white disabled" ] else [ class "div white", onClick OpenNameDialog ]) [ text "Rename" ]
      , button [ class "div white", onClick Cut ] [ text "Cut" ]
      , button (if paste && file.isDir then [ class "div white", onClick Paste ] else [ class "div white disabled" ]) [ text "Paste" ]
      , button [ class "div white", onClick Delete ] [ text "Delete" ]
      ]
    Nothing ->
      [ label [] 
          [ input [ class "fm-file-input", type_ "file", multiple True, onChange Upload ] []
          , text "Upload"
          ]
      , button [ class "div white", onClick <| OpenNameDialog ] [ text "New folder" ]
      , button (if paste then [ class "div white", onClick Paste ] else [ class "div white disabled" ]) [ text "Paste" ]
      ]

nameDialog : String -> Bool -> Html Msg
nameDialog name new = div [ class "fm-screen" ]
  [ div [ class "fm-modal" ]
      [ label []
          [ strong [] [ text "Name" ]
          , br [] []
          , input [ type_ "text", value name, onInput Name ] []
          ]
      , div []
          [ button [ class "fm-button", onClick CloseNameDialog ] [ text "Cancel" ]
          , button [ class "fm-button", onClick <| if new then NewDir else Rename ] [ text "Ok" ]
          ]
      ]
  ]

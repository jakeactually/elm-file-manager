module Main.View exposing (..)

import Events exposing (..)
import Html exposing (Attribute, Html, a, button, div, form, h1, i, input, img, label, text, textarea)
import Html.Attributes exposing (action, class, id, href, method, multiple, src, style, target, title, type_, value)
import Html.Events exposing (onClick, onDoubleClick, onInput)
import Http exposing (encodeUri)
import List exposing (head, indexedMap, isEmpty, length, map, member, range, repeat, reverse, tail)
import Main.Model exposing (..)
import Maybe exposing (andThen, withDefault)
import String exposing (join, split)
import Util exposing (icon, icon2, isJust)
import Vec exposing (..)

view : Model -> Html Msg
view model = div []
  [ div [ id "route" ]
      [ icon "arrow_back" "Regresar" <| EnvMsg <| GetLs <| back model.dir
      , div [ class "text" ] [ text model.dir ]
      ]
  , div
      [ id "files"
      , class <| if model.drag then "drag" else ""
      , onMouseDown (\x y -> EnvMsg <| MouseDown Nothing x y)
      , onMouseMove <| EnvMsg << MouseMove
      , onMouseUp <| EnvMsg <|  MouseUp Nothing
      , onContextMenu <| EnvMsg <| ContextMenu Nothing
      ]
      [ div [] <| reverse (map (renderUploading model.progress) (range 0 <| model.filesAmount - 1)) ++ indexedMap (renderFile model) model.files
      , div [] [ text <| toString model ]
      ]
  , renderHelper model
  , renderCount model
  , if model.showContextMenu
      then contextMenu model.pos1 model.caller (not <| isEmpty model.clipboardFiles) (length model.selected > 1) model.filesAmount
      else div [] []
  , if model.showNameDialog then nameDialog model.name <| not <| isJust model.caller else div [] []
  ]

back : String -> String
back route = "/" ++ (join "/" <| withDefault [] <| andThen tail <| tail <| reverse <| split "/" route)

renderUploading : Int -> Int -> Html Msg
renderUploading progress i = div [ class "file" ]
  [ div [ class "thumb uploading" ]
    [ if i == 0 then div [ class "bar", style [("width", toPx progress)] ] [] else div [] []
    ]
  , div [ class "name" ] []
  ]

renderFile : Model -> Int -> File -> Html Msg
renderFile { api, dir, selected, clipboardDir, clipboardFiles } i file = div
  [ class <| "file"
      ++ (if member file selected then " selected" else "")
      ++ (if dir == clipboardDir && member file clipboardFiles then " cut" else "")
  , title file.name
  , onMouseDown <| (\x y -> EnvMsg <| MouseDown (Just file) x y)
  , onMouseUp <| EnvMsg <| MouseUp <| Just file
  , onContextMenu <| EnvMsg <| ContextMenu <| Just file
  , onDoubleClick <| if file.isDir then EnvMsg <| GetLs <| dir ++ file.name ++ "/" else Download
  ]
  [ div [ class "thumb" ]
    [ renderThumb api dir file
    ]
  , div [ class "name" ] [ text file.name ]
  ]

renderThumb : String -> String -> File -> Html Msg
renderThumb api dir { name, isDir } = if isDir
  then div [ class "icon-thumb icon-folder" ]
    [ img [ src "folder.png" ] []
    ]
  else renderFileThumb api dir name

renderFileThumb : String -> String -> String -> Html Msg
renderFileThumb api dir file = if member (getExt file) ["jpg", "jpeg", "png", "PNG"]
  then div
    [ class "full bg"
    , style [ ("backgroundImage", "url(\"" ++ api ++ "?req=thumb&dir=" ++ dir ++ "&image=" ++ encodeUri file ++ "\")") ]
    ] []
  else div [ class "icon-thumb icon-file" ]
    [ img [ src "file.png" ] []
    ]

getExt : String -> String
getExt name = withDefault "" <| head <| reverse <| split "." name

renderHelper : Model -> Html Msg
renderHelper model = if model.showBound
 then div
  [ id "helper"
  , let b = model.bound in style [ ("left", toPx b.x), ("top", toPx b.y), ("width", toPx b.w), ("height", toPx b.h) ]
  ] []
 else div [] []

toPx : Int -> String
toPx n = toString n ++ "px"

renderCount : Model -> Html Msg
renderCount model = if model.drag
 then div
  [ id "count"
  , let (Vec2 x y) = model.pos2 in style [ ("left", toPx <| x + 5), ("top", toPx <| y - 25) ]
  ]
  [ text <| toString <| length <| model.selected
  ]
 else div [] []

contextMenu : Vec2 -> Maybe File -> Bool -> Bool -> Int ->Html Msg
contextMenu (Vec2 x y) maybe paste many filesAmount = if filesAmount > 0
  then div [ id "context-menu", style [("left", toPx x), ("top", toPx y)] ]
      [ button [ class "div white cancel", onClick Cancel ] [ icon2 "cancel", text "Cancelar" ]
      ]
  else div [ id "context-menu", style [("left", toPx x), ("top", toPx y)] ] <| case maybe of
    Just file ->
      [ button [ class "div white", onClick Download ] [ icon2 "file_download", text "Descargar" ]
      , button [ class <| "div white" ++ if many then " disabled" else "", onClick <| if many then None else OpenNameDialog ] [ icon2 "mode_edit", text "Cambiar nombre" ]
      , button [ class "div white", onClick Cut ] [ icon2 "content_cut", text "Cortar" ]
      , button [ class <| "div white" ++ if paste && file.isDir then "" else " disabled", onClick <| if paste && file.isDir then Paste else None ] [ icon2 "content_paste", text "Pegar" ]
      , button [ class "div white", onClick Delete ] [ icon2 "delete", text "Eliminar" ]
      ]
    Nothing ->
      [ label [ class "button white", onChange Upload ] 
          [ input [ id "file-input", type_ "file", multiple True ] []
          , icon2 "file_upload", text "Subir"
          ]
      , button [ class "div white", onClick <| OpenNameDialog ] [ icon2 "create_new_folder", text "Nueva carpeta" ]
      , button [ class <| "div white" ++ if paste then "" else " disabled", onClick <| if paste then Paste else None ] [ icon2 "content_paste", text "Pegar" ]
      ]

nameDialog : String -> Bool -> Html Msg
nameDialog name new = div [ class "screen" ]
  [ div [ class "modal" ]
      [ label []
          [ div [ class "name" ] [ text "Nombre" ]
          , input [ type_ "text", value name, onInput Name ] []
          ]
      , div []
          [ button [ class "min alert right", onClick CloseNameDialog ] [ text "Cancelar" ]
          , button [ class "min", onClick <| if new then NewDir else Rename ] [ text "Aceptar" ]
          ]
      ]
  ]
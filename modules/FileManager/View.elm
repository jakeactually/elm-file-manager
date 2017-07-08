module FileManager.View exposing (..)

import FileManager.Events exposing (..)
import Html exposing (Attribute, Html, a, button, div, form, h1, i, input, img, label, text, textarea)
import Html.Attributes exposing (action, class, id, href, method, multiple, src, style, target, title, type_, value)
import Html.Events exposing (onClick, onDoubleClick, onInput)
import Http exposing (encodeUri)
import List exposing (head, indexedMap, isEmpty, length, map, member, range, repeat, reverse, tail)
import FileManager.Model exposing (..)
import Maybe exposing (andThen, withDefault)
import String exposing (join, split)
import Svg exposing (svg, circle)
import Svg.Attributes exposing (width, height, cx, cy, r)
import FileManager.Util exposing (icon, icon2, isJust)
import FileManager.Vec exposing (..)

view : Model -> Html Msg
view model = div
  [ id "file-manager"
  , style [("display", if model.open then "grid" else "none")]
  , onMouseMove (\_ -> None)
  ]
  [ div [ id "bar" ]
      [ icon "arrow_back" "Regresar" <| EnvMsg <| GetLs <| back model.dir
      , div [ class "text" ] [ text model.dir ]
      , if model.load
          then svg [ width "25", height "25" ]
            [ circle [ cx "50%", cy "50%", r "40%"] []
            ]
          else div [] []
      ]
  , div
      [ id "files"
      , class <| if model.drag then "drag" else ""
      , onMouseDown (\x y -> EnvMsg <| MouseDown Nothing x y)
      , onMouseMove <| EnvMsg << MouseMove
      , onMouseUp <| EnvMsg <|  MouseUp Nothing
      , onContextMenu <| EnvMsg <| ContextMenu Nothing
      ]
      <| div [ id "drop"] []
      :: reverse (map (renderUploading model.progress) (range 0 <| model.filesAmount - 1))
      ++ indexedMap (renderFile model) model.files
  , div [ id "control" ]
    [ button [ type_ "button", class "alert right", onClick <| EnvMsg Close ] [ text "Cancelar" ]
    , button [ type_ "button", onClick <| EnvMsg Accept ] [ text "Aceptar" ]
    ]
  , if model.showBound then renderHelper model.bound else div [] []
  , if model.drag then renderCount model.pos2 model.selected else div [] []
  , if model.showContextMenu
      then contextMenu model.pos1 model.caller (not <| isEmpty model.clipboardFiles) (length model.selected > 1) model.filesAmount
      else div [] []
  , if model.showNameDialog then nameDialog model.name <| not <| isJust model.caller else div [] []
  ]

back : String -> String
back route = "/" ++ (join "/" <| withDefault [] <| andThen tail <| tail <| reverse <| split "/" route)

renderUploading : Int -> Int -> Html Msg
renderUploading progress i = div [ class "file upload" ]
  [ div [ class "thumb" ]
    [ if i == 0 then div [ id "progress", style [("width", toPx progress)] ] [] else div [] []
    ]
  , div [ class "name" ] []
  ]

renderFile : Model -> Int -> File -> Html Msg
renderFile { fileApi, thumbService, dir, selected, clipboardDir, clipboardFiles } i file = div
  [ class <| "file"
      ++ (if member file selected then " selected" else "")
      ++ (if dir == clipboardDir && member file clipboardFiles then " cut" else "")
  , title file.name
  , onMouseDown <| (\x y -> EnvMsg <| MouseDown (Just file) x y)
  , onMouseUp <| EnvMsg <| MouseUp <| Just file
  , onContextMenu <| EnvMsg <| ContextMenu <| Just file
  , onDoubleClick <| if file.isDir then EnvMsg <| GetLs <| dir ++ file.name ++ "/" else Download
  ]
  [ renderThumb thumbService fileApi dir file
  , div [ class "name" ] [ text file.name ]
  ]

renderThumb : String -> String -> String -> File -> Html Msg
renderThumb thumbService fileApi dir { name, isDir } = if isDir
  then div [ class "thumb icon-folder" ]
    [ img [ src "/assets/images/folder.png" ] []
    ]
  else renderFileThumb fileApi thumbService <| dir ++ name

renderFileThumb : String -> String -> String -> Html Msg
renderFileThumb fileApi thumbService fullName = if member (getExt fullName) ["jpg", "jpeg", "png", "PNG"]
  then div
    [ class "thumb bg"
    , style [ ("backgroundImage", "url(\"" ++ thumbService ++ encodeUri fullName ++ "\")") ]
    ] []
  else div [ class "thumb icon-file" ]
    [ img [ src "/assets/images/file.png" ] []
    ]

getExt : String -> String
getExt name = withDefault "" <| head <| reverse <| split "." name

renderHelper : Bound -> Html Msg
renderHelper b = div
  [ id "helper"
  , style [ ("left", toPx b.x), ("top", toPx b.y), ("width", toPx b.w), ("height", toPx b.h) ]
  ] []

toPx : Int -> String
toPx n = toString n ++ "px"

renderCount : Vec2 -> List File -> Html Msg
renderCount (Vec2 x y) selected = div [ id "count", style [ ("left", toPx <| x + 5), ("top", toPx <| y - 25) ] ]
  [ text <| toString <| length <| selected
  ]

contextMenu : Vec2 -> Maybe File -> Bool -> Bool -> Int ->Html Msg
contextMenu (Vec2 x y) maybe paste many filesAmount = if filesAmount > 0
  then div [ id "context-menu", style [("left", toPx x), ("top", toPx y)] ]
      [ button [ class "div white cancel", onClick Cancel ] [ icon2 "cancel", text "Cancelar" ]
      ]
  else div [ id "context-menu", style [("left", toPx x), ("top", toPx y)] ] <| case maybe of
    Just file ->
      [ button [ class "div white", onClick Download ] [ icon2 "file_download", text "Descargar" ]
      , button (if many then [ class "div white disabled" ] else [ class "div white", onClick OpenNameDialog ]) [ icon2 "mode_edit", text "Cambiar nombre" ]
      , button [ class "div white", onClick Cut ] [ icon2 "content_cut", text "Cortar" ]
      , button (if paste && file.isDir then [ class "div white", onClick Paste ] else [ class "div white disabled" ]) [ icon2 "content_paste", text "Pegar" ]
      , button [ class "div white", onClick Delete ] [ icon2 "delete", text "Eliminar" ]
      ]
    Nothing ->
      [ label [] 
          [ input [ id "file-input", type_ "file", multiple True, onChange Upload ] []
          , icon2 "file_upload"
          , text "Subir"
          ]
      , button [ class "div white", onClick <| OpenNameDialog ] [ icon2 "create_new_folder", text "Nueva carpeta" ]
      , button (if paste then [ class "div white", onClick Paste ] else [ class "div white disabled" ]) [ icon2 "content_paste", text "Pegar" ]
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
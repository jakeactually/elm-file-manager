module FileManager.Env exposing (..)

import FileManager.Action exposing (..)
import List exposing (filter, map, member)
import FileManager.Model exposing (..)
import FileManager.Port exposing (close, getBounds)
import Tuple exposing (first, second)
import FileManager.Util exposing (..)
import FileManager.Vec exposing (..)

handleEnvMsg : EnvMsg -> Model -> (Model, Cmd Msg)
handleEnvMsg msg model = case msg of
  Open () -> ({ model | open = True }, Cmd.none)
  Close -> ({ model | open = False, selected = [] }, close [])
  Accept -> ({ model | open = False, selected = [] }, close <| map ((++) model.dir << .name) model.selected)
  MouseDown maybe pos1 ctrl ->
    ( { model
      | mouseDown = True
      , ctrl = ctrl
      , caller = maybe
      , pos1 = pos1
      , selected = case maybe of
          Just file -> if member file model.selected
            then if ctrl then filter ((/=) file) model.selected else model.selected
            else if ctrl then file :: model.selected else [file]
          Nothing -> []
      , showContextMenu = False
      }
      , getBounds ()
    )
  BoundsGotten bounds -> ({ model | bounds = bounds }, Cmd.none)
  MouseMove pos2 ->
    ( { model
      | pos2 = pos2
      , showBound = model.mouseDown && (not << isJust) model.caller
      , bound = toBound model.pos1 pos2
      , drag = model.mouseDown && isJust model.caller && isFar model.pos1 pos2 && model.filesAmount <= 0
      }
      , Cmd.none
    )
  MouseUp maybe ->
    ( { model
      | mouseDown = False
      , selected = if model.showBound
          then map second <| filter (touchesBound model.bound << first) <| zip model.bounds model.files
          else case maybe of
            Just file -> if model.drag || model.ctrl then model.selected else [file]
            Nothing -> []
      , selectedBin = model.selected
      }
      , case maybe of
          Just file -> if model.drag && file.isDir && (not << member file) model.selected
            then move model.fileApi model.dir model.selected <| "/" ++ file.name ++ "/"
            else Cmd.none
          Nothing -> Cmd.none
    )
  ContextMenu maybe ->
    ( { model
      | showContextMenu = case maybe of
          Just file -> not <| model.dir == model.clipboardDir && member file model.clipboardFiles
          Nothing -> True
      , selected = case maybe of
          Just _ -> model.selectedBin
          Nothing -> []
      }
      , Cmd.none
    )
  GetLs dir -> ({ model | dir = dir, files = [], load = True }, getLs model.fileApi dir)
  LsGotten result -> case result of
    Ok files -> ({ model | files = files, selected = [], load = False }, Cmd.none)
    Err _ -> (model, Cmd.none)
  Refresh result -> case result of
    Ok () -> (model, getLs model.fileApi model.dir)
    Err _ -> (model, Cmd.none)

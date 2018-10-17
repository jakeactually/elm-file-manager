module Env exposing (..)

import Action exposing (..)
import Browser.Dom exposing (getElement)
import Debug exposing (toString)
import List exposing (filter, indexedMap, map, member, reverse)
import Model exposing (..)
import Platform.Cmd exposing (batch)
import Port exposing (close)
import Task exposing (sequence)
import Tuple exposing (first, second)
import Util exposing (..)
import Vec exposing (..)

handleEnvMsg : EnvMsg -> Model -> (Model, Cmd Msg)
handleEnvMsg msg model = case msg of
  Open () -> ({ model | open = True }, Cmd.none)
  Close -> ({ model | open = False, selected = [] }, close [])
  Accept -> ({ model | open = False, selected = [] }, close <| reverse <| map ((++) model.dir << .name) model.selected)
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
      , getBounds model.files
    )
  GetBounds result -> case result of
    Ok(elements) -> ({ model | bounds = map .element elements }, Cmd.none)
    Err e -> (model, Cmd.none)
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
      , load = case maybe of
          Just file -> if model.drag && file.isDir && (not << member file) model.selected
            then True
            else False
          Nothing -> False
      }
      , case maybe of
          Just file -> if model.drag && file.isDir && (not << member file) model.selected
            then move model.api model.jwtToken model.dir model.selected <| "/" ++ file.name ++ "/"
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
  GetLs dir -> ({ model | dir = dir, files = [], load = True }, getLs model.api model.jwtToken dir)
  LsGotten result -> case result of
    Ok files -> ({ model | files = files, selected = [], load = False }, Cmd.none)
    Err _ -> (model, Cmd.none)
  Refresh result -> case result of
    Ok () -> (model, getLs model.api model.jwtToken model.dir)
    Err _ -> (model, Cmd.none)

getBounds : List File -> Cmd Msg
getBounds files = Task.attempt (EnvMsg << GetBounds)
  <| sequence
  <| indexedMap (\i _ -> getElement <| "fm-file-" ++ toString i) files

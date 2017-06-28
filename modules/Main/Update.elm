module Main.Update exposing (..)

import Action exposing (..)
import Env exposing (handleEnvMsg)
import List exposing (head, indexedMap, map, map2, filter, isEmpty, member)
import Main.Model exposing (..)
import Maybe exposing (withDefault, andThen)
import Port exposing (..)
import Vec exposing (..)

init : Flags -> (Model, Cmd Msg)
init { api_, dir_ } = (,)
  { api = api_
  , dir = dir_
  , pos1 = Vec2 0 0
  , pos2 = Vec2 0 0
  , mouseDown = False
  , ctrl = False
  , caller = Nothing
  , showBound = False
  , bound = newBound
  , showContextMenu = False
  , files = []
  , bounds = []
  , selected = []
  , selectedBin = []
  , drag = False
  , clipboardDir = ""
  , clipboardFiles = []
  , showNameDialog = False
  , name = ""
  }
  <| getLs api_ dir_

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  EnvMsg msg -> handleEnvMsg msg model
  Upload -> ({ model | showContextMenu = False }, upload model.dir)
  Uploaded name -> ({ model | files = { name = name, isDir = False } :: model.files }, Cmd.none)
  OpenNameDialog ->
    ( { model
      | showNameDialog = True
      , name = case model.caller of
          Just file -> file.name
          Nothing -> ""
      , showContextMenu = False
      }
      , Cmd.none
    )
  CloseNameDialog -> ({ model | showNameDialog = False }, Cmd.none)
  Name name -> ({ model | name = name }, Cmd.none)
  NewDir -> ({ model | showNameDialog = False }, newDir model.api model.dir model.name)
  Rename ->
    ( { model
      | showNameDialog = False
      },
      case model.caller of
        Just file -> Action.rename model.api model.dir file.name model.name
        Nothing -> Cmd.none
    )
  Cut -> ({ model | clipboardDir = model.dir, clipboardFiles = model.selected, showContextMenu = False }, Cmd.none)
  Paste ->
    ( { model
      | clipboardFiles = []
      , showContextMenu = False
      }
      , case model.caller of
          Just file -> if file.isDir
            then move model.api model.clipboardDir model.clipboardFiles <| model.dir ++ file.name ++ "/"
            else Cmd.none
          Nothing -> Cmd.none
    )
  Delete -> ({ model | showContextMenu = False }, delete model.api model.dir model.selected)
  None -> (model, Cmd.none)

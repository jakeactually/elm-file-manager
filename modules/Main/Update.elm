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
  , open = False
  , load = False
  , pos1 = Vec2 0 0
  , pos2 = Vec2 0 0
  , mouseDown = False
  , ctrl = False
  , caller = Nothing
  , files = []
  , showBound = False
  , bound = newBound
  , bounds = []
  , selected = []
  , drag = False
  , showContextMenu = False
  , selectedBin = []
  , filesAmount = 0
  , progress = 0
  , showNameDialog = False
  , name = ""
  , clipboardDir = ""
  , clipboardFiles = []
  }
  <| getLs api_ dir_

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  EnvMsg msg -> handleEnvMsg msg model
  Upload -> ({ model | showContextMenu = False }, upload model.dir)
  FilesAmount amount -> ({ model | filesAmount = amount }, Cmd.none)
  Progress progress -> ({ model | progress = progress }, Cmd.none)
  Cancel -> (model, cancel ())
  Uploaded () -> ({ model | filesAmount = model.filesAmount - 1 }, getLs model.api model.dir)
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
  NewDir -> ({ model | showNameDialog = False, load = True }, newDir model.api model.dir model.name)
  Download -> ({ model | showContextMenu = False }, download <| map ((++) model.dir << .name) <| filter (not << .isDir) model.selected)
  Rename ->
    ( { model
      | showNameDialog = False
      , load = True
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
      , load = True
      }
      , case model.caller of
          Just file -> if file.isDir
            then move model.api model.clipboardDir model.clipboardFiles <| model.dir ++ file.name ++ "/"
            else Cmd.none
          Nothing -> move model.api model.clipboardDir model.clipboardFiles model.dir
    )
  Delete -> ({ model | showContextMenu = False, load = True }, delete model.api model.dir model.selected)
  None -> (model, Cmd.none)

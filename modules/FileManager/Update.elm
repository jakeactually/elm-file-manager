module FileManager.Update exposing (..)

import FileManager.Action exposing (..)
import FileManager.Env exposing (handleEnvMsg)
import List exposing (head, indexedMap, map, map2, filter, isEmpty, member)
import FileManager.Model exposing (..)
import Maybe exposing (withDefault, andThen)
import FileManager.Port exposing (..)
import FileManager.Vec exposing (..)

init : Flags -> (Model, Cmd Msg)
init { fileApi, thumbService, csrf, dir } = (,)
  { fileApi = fileApi
  , thumbService = thumbService
  , csrf = csrf
  , dir = dir
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
  <| getLs fileApi dir

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  EnvMsg msg -> handleEnvMsg msg model
  Upload -> ({ model | showContextMenu = False }, upload model.dir)
  FilesAmount amount -> ({ model | filesAmount = amount }, Cmd.none)
  Progress progress -> ({ model | progress = progress }, Cmd.none)
  Cancel -> (model, cancel ())
  Uploaded () -> ({ model | filesAmount = model.filesAmount - 1 }, getLs model.fileApi model.dir)
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
  NewDir -> ({ model | showNameDialog = False, load = True }, newDir model.fileApi model.csrf model.dir model.name)
  Download -> ({ model | showContextMenu = False }, download <| map ((++) model.dir << .name) <| filter (not << .isDir) model.selected)
  Rename ->
    ( { model
      | showNameDialog = False
      , load = True
      },
      case model.caller of
        Just file -> FileManager.Action.rename model.fileApi model.csrf model.dir file.name model.name
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
            then move model.fileApi model.csrf model.clipboardDir model.clipboardFiles <| model.dir ++ file.name ++ "/"
            else Cmd.none
          Nothing -> move model.fileApi model.csrf model.clipboardDir model.clipboardFiles model.dir
    )
  Delete -> ({ model | showContextMenu = False, load = True }, delete model.fileApi model.csrf model.dir model.selected)
  None -> (model, Cmd.none)

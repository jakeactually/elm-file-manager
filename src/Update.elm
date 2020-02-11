module Update exposing (..)

import Action exposing (..)
import Browser.Navigation exposing (reload)
import Env exposing (handleEnvMsg)
import File.Select
import List exposing (head, indexedMap, map, map2, filter, isEmpty, member)
import Http
import Model exposing (..)
import Maybe exposing (withDefault, andThen)
import Port exposing (..)
import Vec exposing (..)

init : Flags -> (Model, Cmd Msg)
init flags = (initModel flags, let { api, jwtToken, dir } = flags in getLs api jwtToken dir)

initModel : Flags -> Model
initModel { api, thumbnailsUrl, jwtToken, dir } =
  { api = api
  , thumbnailsUrl = thumbnailsUrl
  , jwtToken = jwtToken
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
  , showDrop = False
  , filesAmount = 0
  , progress = Http.Receiving { received = 0, size = Just 0 }
  , showNameDialog = False
  , name = ""
  , clipboardDir = ""
  , clipboardFiles = []
  }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  EnvMsg message -> handleEnvMsg message model
  ChooseFiles -> (model, File.Select.files [] GotFiles)
  ShowDrop -> ({ model | showDrop = True }, Cmd.none)
  HideDrop -> ({ model | showDrop = False }, Cmd.none)
  -- Upload -> ({ model | showContextMenu = False }, upload model.dir)
  GotFiles file files -> ({ model | showContextMenu = False }, Action.upload model.jwtToken model.dir file)
  FilesAmount amount -> ({ model | filesAmount = amount }, Cmd.none)
  Progress progress -> ({ model | progress = progress }, Cmd.none)
  Cancel -> (model, reload)
  Uploaded result -> case result of
    Ok () -> ({ model | filesAmount = model.filesAmount - 1 }, getLs model.api model.jwtToken model.dir)
    Err _ -> (model, Cmd.none)
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
  NewDir -> ({ model | showNameDialog = False, load = True }, newDir model.api model.jwtToken model.dir model.name)
  Download -> ({ model | showContextMenu = False }, download <| map ((++) model.dir << .name) <| filter (not << .isDir) model.selected)
  Rename ->
    ( { model
      | showNameDialog = False
      , load = True
      },
      case model.caller of
        Just file -> Action.rename model.api model.jwtToken model.dir file.name model.name
        Nothing -> Cmd.none
    )
  Cut -> ({ model | clipboardDir = model.dir, clipboardFiles = model.selected, showContextMenu = False }, Cmd.none)
  Paste -> if model.dir == model.clipboardDir
    then ({ model | clipboardFiles = [], showContextMenu = False }, Cmd.none)
    else
      ( { model
      | clipboardFiles = []
      , showContextMenu = False
      , load = True
      }
      , case model.caller of
          Just file -> if file.isDir
            then move model.api model.jwtToken model.clipboardDir model.clipboardFiles <| model.dir ++ file.name ++ "/"
            else Cmd.none
          Nothing -> move model.api model.jwtToken model.clipboardDir model.clipboardFiles model.dir
      )
  Delete -> ({ model | showContextMenu = False, load = True }, delete model.api model.jwtToken model.dir model.selected)
  None -> (model, Cmd.none)

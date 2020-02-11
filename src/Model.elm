module Model exposing (..)

import Browser.Dom exposing (Element)
import File exposing (File)
import Http exposing (Error)
import Vec exposing (..)

type alias Flags =
  { api: String
  , thumbnailsUrl: String
  , jwtToken: String
  , dir: String
  }

type alias Model =
  { api: String
  , thumbnailsUrl: String
  , jwtToken: String
  , dir: String
  , open: Bool
  , load: Bool
  , pos1: Vec2
  , pos2: Vec2
  , mouseDown: Bool
  , ctrl: Bool
  , caller: Maybe Path
  , files: List Path
  , showBound: Bool
  , bound: Bound
  , bounds: List Bound
  , selected: List Path
  , drag: Bool
  , showContextMenu: Bool
  , selectedBin: List Path
  , showDrop: Bool
  , filesAmount: Int
  , progress: Http.Progress
  , showNameDialog: Bool
  , name: String
  , clipboardDir: String
  , clipboardFiles: List Path
  }

type alias Path =
  { name: String
  , isDir: Bool
  }

type Msg
  = EnvMsg EnvMsg
  | ChooseFiles
  | ShowDrop
  | HideDrop
  | GotFiles File (List File)
  | FilesAmount Int
  | Progress Http.Progress
  | Cancel
  | Uploaded (Result Http.Error ())
  | OpenNameDialog
  | CloseNameDialog
  | Name String
  | NewDir
  | Download
  | Rename
  | Cut
  | Paste
  | Delete
  | None

type EnvMsg
  = Open ()
  | Close
  | Accept
  | MouseDown (Maybe Path) Vec2 Bool
  | GetBounds (Result Browser.Dom.Error (List Element))
  | MouseMove Vec2
  | MouseUp (Maybe Path) Int
  | GetLs String
  | LsGotten (Result Error (List Path)) 
  | Refresh (Result Error ())

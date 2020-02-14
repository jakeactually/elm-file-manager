module Model exposing (..)

import Browser.Dom exposing (Element)
import File exposing (File)
import Http exposing (Error)
import Vec exposing (..)

type alias Flags =
  { api: String
  , thumbnailsUrl: String
  , downloadsUrl: String
  , jwtToken: String
  , dir: String
  }

type alias Model =
  { api: String
  , thumbnailsUrl: String
  , downloadsUrl: String 
  , jwtToken: String
  , dir: String
  , open: Bool
  , load: Bool
  , pos1: Vec2
  , pos2: Vec2
  , mouseDown: Bool
  , ctrl: Bool
  , caller: Maybe FileMeta
  , files: List FileMeta
  , showBound: Bool
  , bound: Bound
  , bounds: List Bound
  , selected: List FileMeta
  , drag: Bool
  , showContextMenu: Bool
  , selectedBin: List FileMeta
  , showDrop: Bool
  , filesAmount: Int
  , progress: Http.Progress
  , showNameDialog: Bool
  , name: String
  , clipboardDir: String
  , clipboardFiles: List FileMeta
  , uploadQueue: List File
  }

type alias FileMeta =
  { name: String
  , isDir: Bool
  }

type Msg
  = EnvMsg EnvMsg
  | ChooseFiles
  | ShowDrop
  | HideDrop
  | GotFiles File (List File)
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
  | MouseDown (Maybe FileMeta) Vec2 Bool
  | GetBounds (Result Browser.Dom.Error (List Element))
  | MouseMove Vec2
  | MouseUp (Maybe FileMeta) Int
  | GetLs String
  | LsGotten (Result Error (List FileMeta)) 
  | Refresh (Result Error ())

module Model exposing (..)

import Browser.Dom exposing (Element)
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
  , caller: Maybe File
  , files: List File
  , showBound: Bool
  , bound: Bound
  , bounds: List Bound
  , selected: List File
  , drag: Bool
  , showContextMenu: Bool
  , selectedBin: List File
  , showDrop: Bool
  , filesAmount: Int
  , progress: Int
  , showNameDialog: Bool
  , name: String
  , clipboardDir: String
  , clipboardFiles: List File
  }

type alias File =
  { name: String
  , isDir: Bool
  }

type Msg
  = EnvMsg EnvMsg
  | ShowDrop
  | HideDrop
  | Upload
  | FilesAmount Int
  | Progress Int
  | Cancel
  | Uploaded ()
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
  | MouseDown (Maybe File) Vec2 Bool
  | GetBounds (Result Browser.Dom.Error (List Element))
  | MouseMove Vec2
  | MouseUp (Maybe File)
  | ContextMenu (Maybe File)
  | GetLs String
  | LsGotten (Result Error (List File)) 
  | Refresh (Result Error ())

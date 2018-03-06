module FileManager.Model exposing (..)

import Http exposing (Error)
import FileManager.Vec exposing (..)

type alias Flags =
  { fileApi: String
  , thumbService: String
  , jwt: String
  , dir: String
  }

type alias Model =
  { fileApi: String
  , thumbService: String
  , jwt: String
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
  | BoundsGotten (List Bound)
  | MouseMove Vec2
  | MouseUp (Maybe File)
  | ContextMenu (Maybe File)
  | GetLs String
  | LsGotten (Result Error (List File)) 
  | Refresh (Result Error ())

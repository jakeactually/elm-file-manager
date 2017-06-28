module Main.Model exposing (..)

import Http exposing (Error)
import Vec exposing (..)

type alias Flags =
  { api_ : String
  , dir_ : String
  }

type alias Model =
  { api : String
  , dir : String
  , pos1 : Vec2
  , pos2 : Vec2
  , mouseDown : Bool
  , ctrl : Bool
  , caller : Maybe File
  , showBound : Bool
  , bound : Bound
  , showContextMenu : Bool
  , files : List File
  , bounds : List Bound
  , selected : List File
  , selectedBin : List File
  , drag : Bool
  , clipboardDir : String
  , clipboardFiles : List File
  , showNameDialog : Bool
  , name : String
  }

type alias File =
  { name : String
  , isDir : Bool
  }

type Msg
  = EnvMsg EnvMsg
  | Upload
  | Uploaded String
  | OpenNameDialog
  | CloseNameDialog
  | Name String
  | NewDir
  | Rename
  | Cut
  | Paste
  | Delete
  | None

type EnvMsg
  = MouseDown (Maybe File) Vec2 Bool
  | BoundsGotten (List Bound)
  | MouseMove Vec2
  | MouseUp (Maybe File)
  | ContextMenu (Maybe File)
  | GetLs String
  | LsGotten (Result Error (List File)) 
  | Refresh (Result Error ())

module Action exposing (..)

import Json.Decode as Decode
import Http exposing (encodeUri)
import List exposing (head, map)
import Main.Model exposing (..)
import Maybe exposing (andThen, withDefault)
import String exposing (join)
import Util exposing ((!!))

getLs : String -> String -> Cmd Msg
getLs api dir = Http.send (EnvMsg << LsGotten) <| Http.get (api ++ "?req=ls&dir=" ++ dir) <| Decode.list fileDecoder

fileDecoder : Decode.Decoder File
fileDecoder = Decode.map2 (\x y -> { name = x, isDir = y })
  (Decode.field "name" Decode.string)
  (Decode.field "isDir" Decode.bool)

move : String -> String -> List File -> String -> Cmd Msg
move api srcDir files dstDir
   = Http.send (EnvMsg << Refresh)
  <| Http.get (api ++ "?req=move&srcDir=" ++ encodeUri srcDir ++ "&files=" ++ encodeFiles files ++ "&dstDir=" ++ encodeUri dstDir)
  <| Decode.succeed ()

getOne : String -> List Int -> List File -> String
getOne dir idxs files = withDefault dir <| Maybe.map (\x -> dir ++ x.name ++ "/") <| andThen ((!!) files) <| head idxs

encodeFiles : List File -> String
encodeFiles files = join "," <| map (encodeUri << .name) files

delete : String -> String -> List File -> Cmd Msg
delete api dir files
   =  Http.send (EnvMsg << Refresh)
  <|  Http.get (api ++ "?req=delete&dir=" ++ encodeUri dir ++ "&files=" ++ encodeFiles files)
  <|  Decode.succeed ()

newDir : String -> String -> String -> Cmd Msg
newDir api dir newDir
   =  Http.send (EnvMsg << Refresh)
  <|  Http.get (api ++ "?req=newDir&dir=" ++ encodeUri dir ++ "&newDir=" ++ encodeUri newDir)
  <|  Decode.succeed ()

rename : String -> String -> String -> String -> Cmd Msg
rename api dir oldName newName
   =  Http.send (EnvMsg << Refresh)
  <|  Http.get (api ++ "?req=rename&dir=" ++ encodeUri dir ++ "&oldName=" ++ encodeUri oldName ++ "&newName=" ++ encodeUri newName)
  <|  Decode.succeed ()

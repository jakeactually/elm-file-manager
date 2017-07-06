module FileManager.Action exposing (..)

import Json.Decode as Decode
import Http exposing (Body, encodeUri, stringBody)
import List exposing (head, map)
import FileManager.Model exposing (..)
import String exposing (join)

getLs : String -> String -> Cmd Msg
getLs api dir
   = Http.send (EnvMsg << LsGotten)
  <| Http.get (api ++ "?req=ls&dir=" ++ dir)
  <| Decode.list fileDecoder

fileDecoder : Decode.Decoder File
fileDecoder = Decode.map2 (\x y -> { name = x, isDir = y })
  (Decode.field "name" Decode.string)
  (Decode.field "isDir" Decode.bool)

move : String -> String -> List File -> String -> Cmd Msg
move api srcDir files dstDir
   = Http.send (EnvMsg << Refresh)
  <| Http.post api (url <| "req=move&srcDir=" ++ encodeUri srcDir ++ "&files=" ++ encodeFiles files ++ "&dstDir=" ++ encodeUri dstDir)
  <| Decode.succeed ()

url : String -> Body
url string = stringBody "application/x-www-form-urlencoded" string

encodeFiles : List File -> String
encodeFiles files = join "," <| map (encodeUri << .name) files

delete : String -> String -> List File -> Cmd Msg
delete api dir files
   =  Http.send (EnvMsg << Refresh)
  <|  Http.post  api (url <| "req=delete&dir=" ++ encodeUri dir ++ "&files=" ++ encodeFiles files)
  <|  Decode.succeed ()

newDir : String -> String -> String -> Cmd Msg
newDir api dir newDir
   =  Http.send (EnvMsg << Refresh)
  <|  Http.post api (url <| "req=newDir&dir=" ++ encodeUri dir ++ "&newDir=" ++ encodeUri newDir)
  <|  Decode.succeed ()

rename : String -> String -> String -> String -> Cmd Msg
rename api dir oldName newName
   =  Http.send (EnvMsg << Refresh)
  <|  Http.post api (url <| "req=rename&dir=" ++ encodeUri dir ++ "&oldName=" ++ encodeUri oldName ++ "&newName=" ++ encodeUri newName)
  <|  Decode.succeed ()

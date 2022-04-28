#! /usr/bin/env runhaskell
import Control.Applicative
import Control.Monad
import Data.List
import Data.Maybe
import System.Directory
import System.Environment
import Text.Regex.Posix
import Text.Printf

main = do
   args <- getArgs
   current <- getCurrentDirectory
   let root = fromMaybe current $ listToMaybe args
   gatherNamespaces root

gatherNamespaces root = do
   files <- xqyFiles 100 root 
   modules <- mapM (processModule $ length root) files
   mapM_ display $ nub modules
   where
      display ("","","") = return ()
      display (mod, file, url) = printf "%s %s %s\n" mod file url

xqyFiles 0     root = return []
xqyFiles depth root = do
   isDir <- doesDirectoryExist root
   if isDir
      then do
         allSub <- getDirectoryContents root `catch` (const $ return [])
         let validSub = mapMaybe valid allSub
         (nub . concat) <$> mapM (xqyFiles $ depth - 1) validSub 
      else 
         return $ if ".xqy" `isSuffixOf` root
            then [root]
            else []
   where
      valid dir | (dir `notElem` ["..", "."]) = Just (rootDir ++ dir)
                | otherwise                   = Nothing
      rootDir | "/" `isSuffixOf` root = root
              | otherwise             = root ++ "/"

processModule len fName = do
   let fileSansRoot = drop len fName
   let regex = "module\\s*namespace\\s*(\\w*)\\s*=\\s*\"([^\"]*)\"\\s*;\\s*$"
   contents <- readFile fName `catch` (const $ return "")
   return $ fromMaybe ("", "", "") $ do
      (_,_,_, [moduleName, url]) <- Just $ contents =~ regex :: Maybe Result
      return (moduleName, fileSansRoot, url) 

type Result = (String, String, String, [String])

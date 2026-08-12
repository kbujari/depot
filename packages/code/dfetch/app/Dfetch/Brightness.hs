module Dfetch.Brightness
  ( Brightness(..)
  , fetchBrightness
  , allBs
  ) where

import           System.Directory (listDirectory)
import           System.FilePath  ((</>))

basePath :: FilePath
basePath = "/sys/class/backlight/"

data Brightness = Brightness
  { bright    :: Int
  , maxbright :: Int
  } deriving Show

backlights :: IO [String]
backlights = listDirectory basePath

fetchBrightness :: String -> IO Brightness
fetchBrightness device = Brightness
  <$> (read <$> readFile (path </> "brightness"))
  <*> (read <$> readFile (path </> "max_brightness"))
  where
    path = basePath </> device

allBs :: IO [Brightness]
allBs = backlights >>= mapM fetchBrightness

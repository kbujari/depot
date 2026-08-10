module Dfetch.Brightness where

import System.FilePath ((</>))
import System.Directory (listDirectory)
import Data.List (isPrefixOf)

basePath :: FilePath
basePath = "/sys/class/backlight/"

module Dfetch.Battery
  ( Battery(..)
  , allBatteries
  ) where

import System.FilePath ((</>))
import System.Directory (listDirectory)
import Data.List (isPrefixOf)

basePath :: FilePath
basePath = "/sys/class/power_supply/"

data Battery = Battery
  {name :: String, capacity :: Int} deriving (Show)

getCapacity :: String -> IO Battery
getCapacity name = Battery <$> pure name <*> capacity
  where
    path = basePath </> name </> "capacity"
    capacity = read <$> readFile path

findBatteries :: IO [String]
findBatteries = filter ("BAT" `isPrefixOf`) <$> listDirectory basePath

allBatteries :: IO [Battery]
allBatteries = findBatteries >>= traverse getCapacity

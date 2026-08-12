module Dfetch.Battery
  ( Battery(..)
  , allBatteries
  ) where

import           Data.List        (isPrefixOf)
import           System.Directory (listDirectory)
import           System.FilePath  ((</>))

basePath :: FilePath
basePath = "/sys/class/power_supply/"

data Battery = Battery
  { name       :: String
  , capacity   :: Int
  , energy     :: Double
  , energyFull :: Double
  } deriving (Show, Eq)

getCapacity :: String -> IO Battery
getCapacity bName = Battery
  <$> pure bName
  <*> (read <$> readFile (path </> "capacity"))
  <*> (read <$> readFile (path </> "energy_now"))
  <*> (read <$> readFile (path </> "energy_full"))
  where
    path = basePath </> bName

findBatteries :: IO [String]
findBatteries = filter ("BAT" `isPrefixOf`) <$> listDirectory basePath

-- | Fetch all batteries from the running system
allBatteries :: IO [Battery]
allBatteries = findBatteries >>= mapM getCapacity

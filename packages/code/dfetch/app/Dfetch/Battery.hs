module Dfetch.Battery
  ( Battery(..)
  , allBatteries
  , renderBat
  ) where

import           Data.List        (isPrefixOf)
import           GHC.Float        (double2Int)
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

renderBat :: [Battery] -> String
renderBat bs = unlines $
  [ "Battery" , "======="] <> map render bs
  where
    totalEnergy = sum . map (energyFull) $ bs
    calcEnergy =
      show . double2Int . (* 100) . (/ totalEnergy) . energyFull

    render b = mconcat $
      [ "\t"
      , name b
      , ": "
      , show (capacity b)
      , "%,\t"
      , calcEnergy b
      , "% of total energy"
      ]

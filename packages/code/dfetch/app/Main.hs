module Main (main) where

import Dfetch.Battery (allBatteries)
import Dfetch.Brightness (allBs)

main :: IO ()
main = do
  bats <- allBatteries
  backlights <- allBs
  print bats
  print backlights

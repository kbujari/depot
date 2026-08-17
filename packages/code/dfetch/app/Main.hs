module Main (main) where

import Dfetch.Battery (renderBat, allBatteries)
import Dfetch.Brightness (allBs)

main :: IO ()
main = do
  bats <- renderBat <$> allBatteries
  backlights <- allBs
  putStrLn bats
  print backlights

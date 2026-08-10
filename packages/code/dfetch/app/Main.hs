module Main (main) where

import Dfetch.Battery (allBatteries)

main :: IO ()
main = do
  bs <- allBatteries
  print bs

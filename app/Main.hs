module Main where

import DependentBayes.Types

main :: IO ()
main = do
  putStrLn "singleton-bayes demo"
  case parseMode "adaptive" of
    Just someMode ->
      withSomeMode someMode $ \s -> do
        putStrLn $ "Selected mode: " ++ renderMode s
        putStrLn $ "Latent space: " ++ latentSpaceName s
    Nothing ->
      putStrLn "Could not parse a mode."


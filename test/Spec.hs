module Main where

import DependentBayes.Types
import System.Exit (exitFailure)

check :: Bool -> String -> IO ()
check True _ = pure ()
check False msg = do
  putStrLn msg
  exitFailure

main :: IO ()
main = do
  case parseMode "static" of
    Just someMode ->
      withSomeMode someMode $ \s -> do
        check (renderMode s == "static") "singleton round-trip failed for static"
        check (latentSpaceName s == "scalar latent") "latent space name mismatch for static"
    Nothing -> check False "failed to parse static mode"

  case parseMode "adaptive" of
    Just someMode ->
      withSomeMode someMode $ \s -> do
        check (renderMode s == "adaptive") "singleton round-trip failed for adaptive"
        check (latentSpaceName s == "pair latent") "latent space name mismatch for adaptive"
    Nothing -> check False "failed to parse adaptive mode"

  putStrLn "singleton-bayes spec passed"


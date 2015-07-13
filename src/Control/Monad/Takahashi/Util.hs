{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Control.Monad.Takahashi.Util where
import Control.Monad.State
import Control.Monad.Skeleton
import Data.List(isPrefixOf)

stateSandbox :: MonadState s m => m a -> m a
stateSandbox f = do
  tmp <- get 
  res <- f
  put tmp
  return res

sub :: Eq a => [a] -> [a] -> [a] -> [a]
sub _ _ [] = []
sub x y str@(s:ss)
  | isPrefixOf x str = y ++ drop (length x) str
  | otherwise = s:sub x y ss

interpret :: forall instr m b. Monad m => (forall a. instr a -> m a) -> Skeleton instr b -> m b
interpret f p = run $ unbone p
  where
    run :: MonadView instr (Skeleton instr) a -> m a
    run (Return x) = return x
    run (v :>>= n) = f v >>= run . unbone . n

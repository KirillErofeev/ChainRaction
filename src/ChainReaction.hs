--{-# language AllowAmbiguousTypes #-}
{-# language NamedFieldPuns #-}
module ChainReaction where

import Graphics.Gloss
import Graphics.Gloss.Interface.IO.Game
import Data.Map (Map, adjust, empty, fromList, foldrWithKey, insert, (!))
import Data.Maybe (isJust)
import qualified Data.Map as Map ((!))

compute = (field <$>) . analysis $ startGame

class ChainReaction c where
    neighborhood :: c -> (Int, Int) -> [(Int, Int)] 
    doReaction :: c -> c
    whoIsWinner :: c -> Maybe Player 
    indexes :: c -> [(Int, Int)]
    makeAllMoves :: c -> [c]

newtype Player = Player {isAmI :: Bool}

instance Eq Player where
    Player a == Player b = a == b

instance Show Player where
    show (Player a) = show a

data Game2d = Game {field :: (Map (Int, Int) (Player, Int)), whoseTurn :: Player
    ,  fieldWidth :: Int, fieldHeight :: Int, inCycle :: Maybe Player} 

showField game@(Game {field, inCycle}) = isEnd (whoIsWinner game) ++ foldrWithKey showField' [] field where
    showField' _ (_, 0) s = "" ++ s 
    showField' index (Player True, n) s  = show index ++ " - <<<" ++ show n ++ ">>>\n" ++ s 
    showField' index (Player False, n) s = show index ++ " - >>>" ++ show n ++ "<<<\n" ++ s 
    isEnd Nothing        = ""
    isEnd (Just player)  = show player ++ "win!"
    isInCycle Nothing    = ""
    inInCycle (Just player) = "Cycle by " ++ show player ++ "\n"

next (Player b) = Player $ not b
startGame = Game (fromList $ zip (indexes (Game empty (Player False) 2 2 Nothing)) (repeat (Player True, 0))) (Player True) 2 2 Nothing

makeMove game@(Game {field, fieldWidth, fieldHeight, whoseTurn}) (i,j) 
    | (i >= fieldWidth) || (j >= fieldHeight) = error "Out of field"
    | fst (field ! (i,j)) /= whoseTurn       = error "Occupied cell"
    | otherwise = doReaction $ game {field = newField, whoseTurn = next whoseTurn} where
        newField = adjust adjustElem (i,j) field
        adjustElem (player, n) = (whoseTurn, n+1)

instance ChainReaction Game2d where
    doReaction game = fst $ doReactionSafe game []

    makeAllMoves game@(Game {field, whoseTurn}) = ((\game -> game {whoseTurn = next whoseTurn}) .
                                                  doReaction                                    . 
                                                   (\f -> game {field = f}))                      <$> newField where
        newField = ($ field) <$> (adjust ((+1) <$> ) <$> (filter indexesFilter $ indexes game))
        indexesFilter i = case field Map.! i of 
            (_     , 0)        -> True
            (Player player, _) -> player 

    neighborhood (Game {fieldWidth, fieldHeight}) (i,j) = filter nf [(i+1,j), (i-1, j), (i,j+1), (i,j-1)] where
        nf (i,j) = (i < fieldWidth) && (j < fieldHeight)

    whoIsWinner (Game {field, inCycle})  | isJust inCycle = inCycle
                                         | otherwise      = fst $ foldr winFold (Nothing, 0) field where
                                             winFold (player, n) (Nothing, k)     | (n>0)             = (Nothing , k+n) 
                                            winFold (player, n) (Nothing, False)  | (k <= 1)             = (Just player, True) 
                                            winFold (player, n) (Nothing, False)  | True              = (Nothing, False) 
                                            winFold (player, n) (Just player0, _) | player == player0 = (Just player, True) 
                                                                                  | otherwise         = (Nothing, True)

    indexes (Game {fieldWidth, fieldHeight}) = [(i,j) | i <- [0..fieldWidth-1], j <- [0..fieldHeight-1]]

doReactionSafe :: Game2d -> [Map (Int, Int) (Player, Int)] -> (Game2d, [Map (Int, Int) (Player, Int)])
doReactionSafe game@(Game {field, fieldWidth, fieldHeight, whoseTurn, inCycle}) pastFields 
    | field `elem` pastFields = (game {inCycle = Just whoseTurn}, pastFields)
    | isJust inCycle          = (game, pastFields) 
    | otherwise               = let
            isReacted _       _         (Just x)                                = Just x
            isReacted index (player, n) Nothing | n > 3                         = Just index
                                                | n == 2 && isCorner game index = Just index
                                                | n == 3 && isEdge   game index = Just index
                                                | otherwise                     = Nothing
                in case foldrWithKey isReacted Nothing field of
        Nothing    -> (game, pastFields) 
        Just index@(i,j) -> doReactionSafe (game {field = newField}) (field:pastFields) where
            updateNeighbors (_, n) = (whoseTurn, n+1)
            updateNeighborhood field = foldr ($) field (adjust updateNeighbors <$> neighborhood game index)
            newField = updateNeighborhood . insert index (Player True, 0) $ field

isEdge   (Game {fieldWidth, fieldHeight}) (i,j) |  i == 0 || i == fieldWidth-1  ||  j == 0 || j == fieldHeight-1  = True
                                                | otherwise                                                       = False
isCorner (Game {fieldWidth, fieldHeight}) (i,j) | (i == 0 || i == fieldWidth-1) && (j == 0 || j == fieldHeight-1) = True
                                                | otherwise                                                       = False

--0, AlterierCaveDark, Dark, Dark2, DimRed, DimGrey, DimGreens, DimGreen

analysis :: (ChainReaction c) => c -> [c]
analysis game = case whoIsWinner game of 
    Just _  -> [] 
    Nothing -> makeAllMoves game >>= filterAnalysis where
      filterAnalysis move = case analysis move of
              [] -> [move]
              _  -> []

--class Field (field index) where
--    element :: field -> index -> Int
--    get

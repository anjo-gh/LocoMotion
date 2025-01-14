module AST (
  AST,
  Statement(..),
  Expression(..),
  emptyAST,
  parseAST,
  expressionPosition
  ) where

import Prelude
import Data.List (List(..),(:))
import Data.Tuple (Tuple(..))
import Parsing (Position(..),position, ParseError,runParser)
import Parsing.Combinators (chainl1, choice, lookAhead, try, (<|>), many, option)
import Parsing.String (eof)
import Data.Foldable (foldl)
import Data.Either (Either(..))


import TokenParser (P, boolean, commaSep, identifier, integer, number, parens, reserved, reservedOp, semiSep, stringLiteral, whiteSpace, naturalOrFloat)


type AST = List Statement

data Statement =
  Assignment Position String Expression |
  Action Expression | -- Action doesn't need to record Position since the contained Expression will have the Position
  EmptyStatement Position

instance Eq Statement where
  eq (Assignment p1 s1 e1) (Assignment p2 s2 e2) = p1 == p2 && s1 == s2 && e1 == e2
  eq (Action e1) (Action e2) = e1 == e2
  eq (EmptyStatement p1) (EmptyStatement p2) = p1 == p2
  eq _ _ = false

instance Show Statement where
  show (Assignment p k e) = "Assignment (" <> show p <> ") " <> show k <> " (" <> show e <> ")"
  show (Action e) = "Action (" <> show e <> ")"
  show (EmptyStatement p) = "EmptyStatement (" <> show p <> ")"

emptyAST :: AST
emptyAST = EmptyStatement (Position { column: 1, index: 0, line: 1 }) : Nil

parseAST :: String -> Either ParseError AST
parseAST x = runParser x ast

data Expression =
  Dancer Position | Floor Position | Camera Position | Osc Position | Range Position | Clear Position |
  Ambient Position | Directional Position | Hemisphere Position |
  Point Position | RectArea Position | Spot Position |
  LiteralNumber Position Number |
  LiteralString Position String |
  LiteralInt Position Int |
  LiteralBoolean Position Boolean |
  This Position String | -- eg. this.x would be This "x"
  SemiGlobal Position String | -- eg. x would be SemiGlobal "x"
  Transformer Position (List (Tuple String Expression)) |
  Application Position Expression Expression |
  Sum Position Expression Expression |
  Difference Position Expression Expression |
  Product Position Expression Expression |
  Divide Position Expression Expression

instance Eq Expression where
  eq (Dancer p1) (Dancer p2) = p1 == p2
  eq (Floor p1) (Floor p2) = p1 == p2
  eq (Camera p1) (Camera p2) = p1 == p2
  eq (Osc p1) (Osc p2) = p1 == p2
  eq (Range p1) (Range p2) = p1 == p2
  eq (Clear p1) (Clear p2) = p1 == p2
  eq (Ambient p1) (Ambient p2) = p1 == p2
  eq (Directional p1) (Directional p2) = p1 == p2
  eq (Hemisphere p1) (Hemisphere p2) = p1 == p2
  eq (Point p1) (Point p2) = p1 == p2
  eq (RectArea p1) (RectArea p2) = p1 == p2
  eq (Spot p1) (Spot p2) = p1 == p2
  eq (LiteralNumber p1 x1) (LiteralNumber p2 x2) = p1 == p2 && x1 == x2
  eq (LiteralString p1 x1) (LiteralString p2 x2) = p1 == p2 && x1 == x2
  eq (LiteralInt p1 x1) (LiteralInt p2 x2) = p1 == p2 && x1 == x2
  eq (LiteralBoolean p1 x1) (LiteralBoolean p2 x2) = p1 == p2 && x1 == x2
  eq (This p1 x1) (This p2 x2) = p1 == p2 && x1 == x2
  eq (SemiGlobal p1 x1) (SemiGlobal p2 x2) = p1 == p2 && x1 == x2
  eq (Transformer p1 x1) (Transformer p2 x2) = p1 == p2 && x1 == x2
  eq (Application p1 x1a x1b) (Application p2 x2a x2b) = p1 == p2 && x1a == x2a && x1b == x2b
  eq (Sum p1 x1a x1b) (Sum p2 x2a x2b) = p1 == p2 && x1a == x2a && x1b == x2b
  eq (Difference p1 x1a x1b) (Difference p2 x2a x2b) = p1 == p2 && x1a == x2a && x1b == x2b
  eq (Product p1 x1a x1b) (Product p2 x2a x2b) = p1 == p2 && x1a == x2a && x1b == x2b
  eq (Divide p1 x1a x1b) (Divide p2 x2a x2b) = p1 == p2 && x1a == x2a && x1b == x2b
  eq _ _ = false

instance Show Expression where
  show (LiteralNumber p x) = "LiteralNumber (" <> show p <> ") " <> show x
  show (LiteralString p x) = "(LiteralString (" <> show p <> ") " <> show x <> ")"
  show (LiteralInt p x) = "LiteralInt (" <> show p <> ") " <> show x
  show (LiteralBoolean p x) = "LiteralBoolean (" <> show p <> ") " <> show x
  show (This p x) = "This (" <> show p <> ") " <> show x
  show (SemiGlobal p x) = "SemiGlobal (" <> show p <> ") " <> show x
  show (Application p e1 e2) = "Application (" <> show p <> ") (" <> show e1 <> ") (" <> show e2 <> ")"
  show (Transformer p x) = "Transformer (" <> show p <> ") (" <> show x <> ")"
  show (Dancer p) = "Dancer (" <> show p <> ")"
  show (Floor p) = "Floor (" <> show p <> ")"
  show (Camera p) = "Camera (" <> show p <> ")"
  show (Osc p) = "Osc (" <> show p <> ")"
  show (Range p) = "Range (" <> show p <> ")"
  show (Clear p) = "Clear (" <> show p <> ")"
  show (Ambient p) = "Ambient (" <> show p <> ")"
  show (Directional p) = "Directional (" <> show p <> ")"
  show (Hemisphere p) = "Hemisphere (" <> show p <> ")"
  show (Point p) = "Point (" <> show p <> ")"
  show (RectArea p) = "RectArea (" <> show p <> ")"
  show (Spot p) = "Spot (" <> show p <> ")"
  show (Sum p e1 e2) = "Sum (" <> show p <> ") (" <> show e1 <> ") (" <> show e2 <> ")"
  show (Difference p e1 e2) = "Difference (" <> show p <> ") (" <> show e1 <> ") (" <> show e2 <> ")"
  show (Product p e1 e2) = "Product (" <> show p <> ") (" <> show e1 <> ") (" <> show e2 <> ")"
  show (Divide p e1 e2) = "Divide (" <> show p <> ") (" <> show e1 <> ") (" <> show e2 <> ")"

expressionPosition :: Expression -> Position
expressionPosition (LiteralNumber p _) = p
expressionPosition (LiteralString p _) = p
expressionPosition (LiteralInt p _) = p
expressionPosition (LiteralBoolean p _) = p
expressionPosition (This p _) = p
expressionPosition (SemiGlobal p _) = p
expressionPosition (Application p _ _) = p
expressionPosition (Transformer p _) = p
expressionPosition (Dancer p) = p
expressionPosition (Floor p) = p
expressionPosition (Camera p) = p
expressionPosition (Osc p) = p
expressionPosition (Range p) = p
expressionPosition (Clear p) = p
expressionPosition (Ambient p) = p
expressionPosition (Directional p) = p
expressionPosition (Hemisphere p) = p
expressionPosition (Point p) = p
expressionPosition (RectArea p) = p
expressionPosition (Spot p) = p
expressionPosition (Sum p _ _) = p
expressionPosition (Difference p _ _) = p
expressionPosition (Product p _ _) = p
expressionPosition (Divide p _ _) = p


-- parsing:

ast :: P AST
ast = do
  whiteSpace
  xs <- semiSep statement
  eof
  pure $ xs

statement :: P Statement
statement = try assignment <|> try action <|> emptyStatement

assignment :: P Statement
assignment = do
  p <- position
  k <- identifier
  reservedOp "="
  v <- expression
  pure $ Assignment p k v

action :: P Statement
action = Action <$> expression

emptyStatement :: P Statement
emptyStatement = do
  p <- position
  lookAhead whiteSpace
  lookAhead eof <|> lookAhead (reservedOp ";")
  pure $ EmptyStatement p

expression :: P Expression
expression = do
  _ <- pure unit
  chainl1 expression' additionSubtraction

additionSubtraction :: P (Expression -> Expression -> Expression)
additionSubtraction = do
  p <- position
  choice [
    reservedOp "+" $> Sum p,
    reservedOp "-" $> Difference p
    ]

expression' :: P Expression
expression' = do
  _ <- pure unit
  chainl1 expression'' multiplicationDivision

multiplicationDivision :: P (Expression -> Expression -> Expression)
multiplicationDivision = do
  p <- position
  choice [
    reservedOp "*" $> Product p,
    reservedOp "/" $> Divide p
    ]

expression'' :: P Expression
expression'' = do
  _ <- pure unit
  choice [
    try application,
    argument
    ]

application :: P Expression
application = do
  _ <- pure unit
  p <- position
  f <- argument
  firstArg <- argument
  otherArgs <- many argument
  pure $ foldl (Application p) (Application p f firstArg) otherArgs

argument :: P Expression
argument = do
  _ <- pure unit
  p <- position
  choice [
    parens expression,
    try transformer,
    try intOrNumber,
    try $ LiteralString p <$> stringLiteral,
    try $ LiteralBoolean p <$> boolean,
    try (Dancer p <$ reserved "dancer"),
    try (Floor p <$ reserved "floor"),
    try (Camera p <$ reserved "camera"),
    try (Osc p <$ reserved "osc"),
    try (Range p <$ reserved "range"),
    try (Clear p <$ reserved "clear"),
    try (Ambient p <$ reserved "ambient"),
    try (Directional p <$ reserved "directional"),
    try (Hemisphere p <$ reserved "hemisphere"),
    try (Point p <$ reserved "point"),
    try (RectArea p <$ reserved "rectarea"),
    try (Spot p <$ reserved "spot"),
    try thisRef,
    semiGlobalRef
  ]

intOrNumber :: P Expression
intOrNumber = do
  p <- position
  isPositive <- option true (false <$ reservedOp "-")
  x <- naturalOrFloat
  case x of
    Left i -> if isPositive then (pure $ LiteralInt p i) else (pure $ LiteralInt p (i*(-1)))
    Right f -> if isPositive then (pure $ LiteralNumber p f) else (pure $ LiteralNumber p (f*(-1.0)))

transformer :: P Expression
transformer = do
  _ <- pure unit
  p <- position
  reservedOp "{"
  xs <- commaSep modifier
  reservedOp "}"
  pure $ Transformer p xs

modifier :: P (Tuple String Expression)
modifier = do
  k <- identifier
  (reservedOp "=" <|> reservedOp ":")
  e <- expression
  pure $ Tuple k e

thisRef :: P Expression
thisRef = do
  p <- position
  reserved "this"
  reservedOp "."
  This p <$> identifier

semiGlobalRef :: P Expression
semiGlobalRef = SemiGlobal <$> position <*> identifier

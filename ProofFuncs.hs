module ProofFuncs where
import Data.List
import ProofTypes

math :: (Int -> Int -> Int) -> String -> String -> String -> Stmt String
math f sym x y =
        let (xn, yn) = (
              reads x :: [
                 (Int, String)
                 ]
              ,
              reads y :: [(Int, String)]) in
        case xn of
          [(xint, _)] ->
           case yn of
             [(yint , _)] -> Var (show $ f xint yint)
             _ -> Op sym (Var x) (Var y)
          _ -> Op sym (Var x) (Var y)

strToLst :: Stmt String -> [Stmt String]
strToLst stmt =
  case stmt of
    (Op "." x y) ->
      strToLst x ++ strToLst y
    Var x -> [Var x]
    Free y -> [Free y]
    other -> [other]

lstToStmt :: [Stmt String] -> Stmt String
lstToStmt x =
  case x of
    [x1] -> x1
    (x1 : xs) -> Op "." x1 (lstToStmt xs)

stringOrder :: Stmt String -> Stmt String
stringOrder stmt =
  case stmt of
    (Op "." _ _) -> lstToStmt $ strToLst stmt
    x -> x

collapseFuncs :: Stmt String -> [Stmt String]
collapseFuncs stmt =
        case stmt of
                (Var x) -> [stmt]
                (Free x) -> [stmt]
                (Op op (Var x) (Var "NOP")) -> case op of
		  "-" -> [Var $ "-" ++ x]
                  _ -> [stmt]
                (Op op (Var x) (Var y)) -> case op of
                        "+" -> [math (+) "+" x y]
                        "-" -> [math (-) "-" x y]
                        "*" -> [math (*) "*" x y]
                        "." -> [stringOrder stmt]
                        _ -> [stmt]
                (Op "." x y) -> [stringOrder stmt]
                (Op op lhs rhs) -> nub $
                                          [
                                            Op op x y
                                          |
                                            x <- collapseFuncs lhs,
                                            y <- collapseFuncs rhs
                                          ] ++
                                          [
                                            Op op x rhs
                                          |
                                            x <- collapseFuncs lhs
                                          ] ++
                                          [
                                            Op op lhs y
                                          |
                                            y <- collapseFuncs rhs
                                          ] ++ [stmt]


f2Expr :: Expr String -> [Expr String]
f2Expr expr =
  let once = fExpr expr in
  concat [fExpr x | x <- once]

fExpr :: Expr String -> [Expr String]
fExpr expr =
        let stmt =
              body expr in
        [Expr (_id expr)
         x (justification expr) |
         x <- collapseFuncs stmt
        ]

fExprs :: [Expr String] -> [Expr String]
fExprs exprs = -- exprs
        concat [ fExpr x | x <- exprs ]

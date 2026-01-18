{- |
Module      : Test
Description : Haskell LSP test file
Test: hover over functions, go to definition, find references, type classes.
-}
module Test where

import Data.Maybe (fromMaybe)

-- | A person with a name and age.
data Person = Person
  { personName :: String
  , personAge :: Int
  , personEmail :: Maybe String
  }
  deriving (Show, Eq)

-- | Create a new Person.
mkPerson :: String -> Int -> Person
mkPerson name age =
  Person
    { personName = name
    , personAge = age
    , personEmail = Nothing
    }

-- | Set the person's email.
withEmail :: String -> Person -> Person
withEmail email person = person {personEmail = Just email}

-- | Greet another person.
greet :: Person -> Person -> String
greet self other =
  "Hello " ++ personName other ++ ", I'm " ++ personName self ++ "!"

-- | Check if person is an adult (18+).
isAdult :: Person -> Bool
isAdult person = personAge person >= 18

-- | Filter a list of people to only adults.
findAdults :: [Person] -> [Person]
findAdults = filter isAdult

-- | Get all names from a list of people.
getNames :: [Person] -> [String]
getNames = map personName

-- | A type class for entities that can be greeted.
class Greetable a where
  greeting :: a -> String

instance Greetable Person where
  greeting person = "Hi, I'm " ++ personName person ++ "!"

-- | Display a person's info.
displayPerson :: Person -> String
displayPerson person =
  personName person
    ++ " (age "
    ++ show (personAge person)
    ++ ")"
    ++ maybe "" (\e -> ", email: " ++ e) (personEmail person)

-- | Main function for testing.
main :: IO ()
main = do
  let alice = withEmail "alice@example.com" $ mkPerson "Alice" 30
      bob = mkPerson "Bob" 17
      charlie = mkPerson "Charlie" 25
      people = [alice, bob, charlie]
      adults = findAdults people

  putStrLn $ greet alice bob
  putStrLn $ "Alice: " ++ displayPerson alice
  putStrLn $ "Adults: " ++ show (getNames adults)
  putStrLn $ greeting alice

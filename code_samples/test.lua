-- Lua LSP test file
-- Test: hover over functions, go to definition, find references

---@class Person
---@field name string
---@field age number
local Person = {}
Person.__index = Person

---Create a new Person
---@param name string The person's name
---@param age number The person's age
---@return Person
function Person.new(name, age)
  local self = setmetatable({}, Person)
  self.name = name
  self.age = age
  return self
end

---Greet another person
---@param other Person The other person to greet
---@return string
function Person:greet(other)
  return string.format("Hello %s, I'm %s!", other.name, self.name)
end

---Check if person is adult
---@return boolean
function Person:is_adult()
  return self.age >= 18
end

-- Test usage
local alice = Person.new("Alice", 30)
local bob = Person.new("Bob", 25)

print(alice:greet(bob))
print("Alice is adult:", alice:is_adult())

-- Test nixCats integration
if nixCats then
  print("Running in nixCats environment")
  print("Have nerd font:", nixCats("have_nerd_font"))
end

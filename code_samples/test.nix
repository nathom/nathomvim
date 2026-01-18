# Nix LSP test file
# Test: hover over functions, go to definition, find references
{
  pkgs ? import <nixpkgs> { },
}:
let
  # A function to create a person attrset
  mkPerson =
    {
      name,
      age,
      email ? null,
    }:
    {
      inherit name age email;

      # Check if person is an adult
      isAdult = age >= 18;

      # Generate a greeting
      greet =
        other:
        "Hello ${other.name}, I'm ${name}!";
    };

  # Create some people
  alice = mkPerson {
    name = "Alice";
    age = 30;
    email = "alice@example.com";
  };

  bob = mkPerson {
    name = "Bob";
    age = 17;
  };

  charlie = mkPerson {
    name = "Charlie";
    age = 25;
  };

  # Filter to only adults
  people = [
    alice
    bob
    charlie
  ];
  adults = builtins.filter (p: p.isAdult) people;

  # A derivation example
  myScript = pkgs.writeShellScriptBin "greet" ''
    echo "${alice.greet bob}"
  '';

  # List manipulation examples
  names = map (p: p.name) people;
  adultNames = map (p: p.name) adults;

in
{
  inherit
    alice
    bob
    charlie
    adults
    myScript
    ;

  # Expose some computed values
  greeting = alice.greet bob;
  allNames = names;
  adultCount = builtins.length adults;

  # A shell for development
  shell = pkgs.mkShell {
    packages = [
      myScript
      pkgs.hello
    ];
  };
}

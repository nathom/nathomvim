"""Python LSP test file.

Test: hover over functions, go to definition, find references, type hints.
"""

from dataclasses import dataclass
from typing import Optional


@dataclass
class Person:
    """A person with a name and age."""

    name: str
    age: int
    email: Optional[str] = None

    def greet(self, other: "Person") -> str:
        """Greet another person.

        Args:
            other: The other person to greet.

        Returns:
            A greeting string.
        """
        return f"Hello {other.name}, I'm {self.name}!"

    def is_adult(self) -> bool:
        """Check if person is an adult (18+)."""
        return self.age >= 18

    def send_email(self, message: str) -> bool:
        """Send an email to this person.

        Args:
            message: The message to send.

        Returns:
            True if email was sent, False if no email address.
        """
        if self.email is None:
            return False
        print(f"Sending to {self.email}: {message}")
        return True


def find_adults(people: list[Person]) -> list[Person]:
    """Filter a list of people to only adults.

    Args:
        people: List of Person objects.

    Returns:
        List of Person objects who are adults.
    """
    return [p for p in people if p.is_adult()]


if __name__ == "__main__":
    alice = Person("Alice", 30, "alice@example.com")
    bob = Person("Bob", 17)
    charlie = Person("Charlie", 25)

    print(alice.greet(bob))

    people = [alice, bob, charlie]
    adults = find_adults(people)
    print(f"Adults: {[p.name for p in adults]}")

    alice.send_email("Hello!")
    bob.send_email("This won't work")

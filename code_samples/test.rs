//! Rust LSP test file.
//!
//! Test: hover over functions, go to definition, find references, traits.

use std::fmt;

/// A person with a name and age.
#[derive(Debug, Clone)]
pub struct Person {
    name: String,
    age: u32,
    email: Option<String>,
}

impl Person {
    /// Create a new Person.
    ///
    /// # Arguments
    /// * `name` - The person's name
    /// * `age` - The person's age
    pub fn new(name: impl Into<String>, age: u32) -> Self {
        Self {
            name: name.into(),
            age,
            email: None,
        }
    }

    /// Set the person's email.
    pub fn with_email(mut self, email: impl Into<String>) -> Self {
        self.email = Some(email.into());
        self
    }

    /// Greet another person.
    pub fn greet(&self, other: &Person) -> String {
        format!("Hello {}, I'm {}!", other.name, self.name)
    }

    /// Check if person is an adult (18+).
    pub fn is_adult(&self) -> bool {
        self.age >= 18
    }

    /// Get the person's name.
    pub fn name(&self) -> &str {
        &self.name
    }
}

impl fmt::Display for Person {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} (age {})", self.name, self.age)
    }
}

/// A trait for entities that can be greeted.
pub trait Greetable {
    /// Return a greeting for this entity.
    fn greeting(&self) -> String;
}

impl Greetable for Person {
    fn greeting(&self) -> String {
        format!("Hi, I'm {}!", self.name)
    }
}

/// Filter a slice of people to only adults.
pub fn find_adults(people: &[Person]) -> Vec<&Person> {
    people.iter().filter(|p| p.is_adult()).collect()
}

fn main() {
    let alice = Person::new("Alice", 30).with_email("alice@example.com");
    let bob = Person::new("Bob", 17);
    let charlie = Person::new("Charlie", 25);

    println!("{}", alice.greet(&bob));
    println!("Alice: {}", alice);

    let people = vec![alice.clone(), bob, charlie];
    let adults = find_adults(&people);
    println!(
        "Adults: {:?}",
        adults.iter().map(|p| p.name()).collect::<Vec<_>>()
    );
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_adult() {
        let adult = Person::new("Test", 18);
        let minor = Person::new("Test", 17);

        assert!(adult.is_adult());
        assert!(!minor.is_adult());
    }
}

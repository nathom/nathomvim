// Package main is a Go LSP test file.
//
// Test: hover over functions, go to definition, find references, interfaces.
package main

import (
	"fmt"
	"strings"
)

// Person represents a person with a name and age.
type Person struct {
	Name  string
	Age   int
	Email *string
}

// NewPerson creates a new Person.
func NewPerson(name string, age int) *Person {
	return &Person{
		Name: name,
		Age:  age,
	}
}

// WithEmail sets the person's email and returns the person for chaining.
func (p *Person) WithEmail(email string) *Person {
	p.Email = &email
	return p
}

// Greet returns a greeting for another person.
func (p *Person) Greet(other *Person) string {
	return fmt.Sprintf("Hello %s, I'm %s!", other.Name, p.Name)
}

// IsAdult returns true if the person is 18 or older.
func (p *Person) IsAdult() bool {
	return p.Age >= 18
}

// String implements the Stringer interface.
func (p *Person) String() string {
	return fmt.Sprintf("%s (age %d)", p.Name, p.Age)
}

// Greeter is an interface for entities that can greet.
type Greeter interface {
	Greet(other *Person) string
}

// FindAdults filters a slice of people to only those who are adults.
func FindAdults(people []*Person) []*Person {
	var adults []*Person
	for _, p := range people {
		if p.IsAdult() {
			adults = append(adults, p)
		}
	}
	return adults
}

// GetNames returns a slice of names from a slice of people.
func GetNames(people []*Person) []string {
	names := make([]string, len(people))
	for i, p := range people {
		names[i] = p.Name
	}
	return names
}

func main() {
	email := "alice@example.com"
	alice := &Person{Name: "Alice", Age: 30, Email: &email}
	bob := NewPerson("Bob", 17)
	charlie := NewPerson("Charlie", 25)

	fmt.Println(alice.Greet(bob))
	fmt.Println("Alice:", alice)

	people := []*Person{alice, bob, charlie}
	adults := FindAdults(people)

	adultNames := GetNames(adults)
	fmt.Printf("Adults: %s\n", strings.Join(adultNames, ", "))

	// Test interface
	var greeter Greeter = alice
	fmt.Println(greeter.Greet(charlie))
}

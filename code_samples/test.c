/**
 * @file test.c
 * @brief C LSP test file
 *
 * Test: hover over functions, go to definition, find references, structs.
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NAME_LEN 64
#define MAX_EMAIL_LEN 128

/**
 * @brief A person with a name and age.
 */
typedef struct {
  char name[MAX_NAME_LEN];
  int age;
  char email[MAX_EMAIL_LEN];
  bool has_email;
} Person;

/**
 * @brief Initialize a Person struct.
 *
 * @param person Pointer to Person to initialize
 * @param name The person's name
 * @param age The person's age
 */
void person_init(Person *person, const char *name, int age) {
  strncpy(person->name, name, MAX_NAME_LEN - 1);
  person->name[MAX_NAME_LEN - 1] = '\0';
  person->age = age;
  person->has_email = false;
  person->email[0] = '\0';
}

/**
 * @brief Set the person's email.
 *
 * @param person Pointer to Person
 * @param email The email address
 */
void person_set_email(Person *person, const char *email) {
  strncpy(person->email, email, MAX_EMAIL_LEN - 1);
  person->email[MAX_EMAIL_LEN - 1] = '\0';
  person->has_email = true;
}

/**
 * @brief Generate a greeting from one person to another.
 *
 * @param self The person doing the greeting
 * @param other The person being greeted
 * @param buffer Output buffer for the greeting
 * @param buffer_size Size of the output buffer
 * @return Number of characters written (excluding null terminator)
 */
int person_greet(const Person *self, const Person *other, char *buffer,
                 size_t buffer_size) {
  return snprintf(buffer, buffer_size, "Hello %s, I'm %s!", other->name,
                  self->name);
}

/**
 * @brief Check if a person is an adult (18+).
 *
 * @param person Pointer to Person
 * @return true if adult, false otherwise
 */
bool person_is_adult(const Person *person) { return person->age >= 18; }

/**
 * @brief Display a person's information.
 *
 * @param person Pointer to Person to display
 */
void person_display(const Person *person) {
  printf("%s (age %d)", person->name, person->age);
  if (person->has_email) {
    printf(", email: %s", person->email);
  }
  printf("\n");
}

/**
 * @brief Count the number of adults in an array of people.
 *
 * @param people Array of Person structs
 * @param count Number of people in the array
 * @return Number of adults
 */
int count_adults(const Person *people, size_t count) {
  int adults = 0;
  for (size_t i = 0; i < count; i++) {
    if (person_is_adult(&people[i])) {
      adults++;
    }
  }
  return adults;
}

int main(void) {
  Person alice, bob, charlie;
  char greeting[256];

  person_init(&alice, "Alice", 30);
  person_set_email(&alice, "alice@example.com");

  person_init(&bob, "Bob", 17);
  person_init(&charlie, "Charlie", 25);

  person_greet(&alice, &bob, greeting, sizeof(greeting));
  printf("%s\n", greeting);

  printf("Alice: ");
  person_display(&alice);

  Person people[] = {alice, bob, charlie};
  size_t num_people = sizeof(people) / sizeof(people[0]);

  printf("Number of adults: %d\n", count_adults(people, num_people));

  return 0;
}

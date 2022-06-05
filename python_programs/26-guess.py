# import random
from random import randint
import time

# Setting GLOBAL variables to determine how many attempts have each level:
EASY_LEVEL = 10
HARD_LEVEL = 5


# Setting difficulty:
def set_difficulty():
    global level        # it will take the (correct) parameter ENTERED by the USER
    if level == "e":
        return EASY_LEVEL
    else:
        return HARD_LEVEL


# It will check if the number is or not the same for ANY level of difficulty:
def checking_number(number):
    global to_guess     # it will take RANDOM number generated at the BEGINNING of the game
    if number == to_guess:
        return 1
    elif number < to_guess:
        return print("Sorry, too low.")
    elif number > to_guess:
        return print("Sorry, too high.")


play = True
while play:
    print("\nWelcome to the Number Guessing Game!")
    time.sleep(1)
    print("\nI'm thinking of a number between 1 and 50.")
    # to_guess = random.randint(1, 50)
    to_guess = randint(1, 5)

    while True:
        level = input("\nPlease choose the level of difficulty: press 'e' (easy) or 'h' (hard)?: ").lower()
        if level not in ("e", "h"):
            continue
        else:
            # Because we entered a right level, it will execute the function "SET_DIFFICULTY" into "attempts":
            attempts = set_difficulty()

        while attempts > 0:
            print(f"\nYou have {attempts} attempt/s remaining to guess the number.")

            # Entering the number to the function "GUESSING":
            result = checking_number(number=int(input("Please, make a guess: ")))

            if result == 1:
                print(f"\nCongratulations! You entered the right number ({to_guess}).")
                break
            else:
                attempts -= 1
                print("Please, guess again.")

        if attempts == 0:
            print("\nYou run out of attempts. You lost :(")

        break

    # Asking to play again:
    while True:
        again = input("\nDo you want to play again? (y/n): ").lower()
        if again not in ("y", "n"):
            print("\n")
            continue
        else:
            if again == "y":
                print("\n=======================================================================")
                break  # will return to the beginning of the game
            else:
                print("See you next time :)")
                play = False
                break  # will exit the game

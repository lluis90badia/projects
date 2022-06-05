from random import randint


def random_guess():                 # Generating RANDOM number
    x = randint(1, 2)
    return x


def choices(entry):
    # global to_guess
    num = 0
    if entry in ("l", "w", "g"):
        num = 1
    elif entry in ("r", "s", "b"):
        num = 2
    if num != random_guess():       # we enter the RANDOM number from the function RANDOM
        return num - 2
    else:
        return num + 1


def game(lr):
    num_guess = random_guess()
    result = choices(choice)       # we enter the RESULT from the function CHOICES (if it's RIGHT or LEFT)
    if result < 2:
        return 0
    else:
        return 1


# Game
play = True
while play:
    print("Welcome to Treasure Island!\n")
    print("Your mission is to find the treasure.\n")

    while True:
        choice = input("You\'re at a cross road. Where do you want to go? Type 'l' (left) or 'r' (right): ").lower()
        if choice not in ('l', 'r'):
            continue
        else:
            if game(choice) != 1:
                print("You got attacked by an angry trout. Game Over :(")
                break
            else:
                choice = input("\nYou\'ve come to a lake. There is an island in the middle of the lake. "\
                               "Type 'w' to wait for a boat. Type 's' to swim across: ").lower()
                if choice not in ('w', 's'):
                    continue
                else:
                    if game(choice) != 1:
                        print("You got attacked by an angry trout. Game Over :(")
                        break
                    else:
                        choice = input("\nYou\'ve arrived at the island unharmed. "\
                                       "There is a house with 2 doors. One green and one blue. "\
                                       "Which colour do you choose (g/b)?: ").lower()
                        if choice not in ('g', 'b'):
                            continue
                        else:
                            if game(choice) != 1:
                                print("It's a room full of fire. Game Over :(")
                                break
                            else:
                                print("Congratulations! You found the treasure.")
                                break
                        break
                break
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
                print("\nSee you next time :)")
                play = False
                break  # will exit the game

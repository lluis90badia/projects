import random
import time
from random import randint

play = True
while play:
    print("\nWelcome to the PyPassword Generator!\n")
    time.sleep(2)
    password = []

    # 1) Letters
    while True:
        letters = int(input("How many letters would you like in your password? "))
        alphabet = ["a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F", "g", "G",
                    "h", "H", "i", "I", "j", "J", "k", "K", "l", "L", "m", "M", "n", "N",
                    "o", "O", "p", "P", "q", "Q", "r", "R", "s", "S", "t", "T", "u", "U",
                    "v", "V", "w", "W", "x", "X", "y", "Y", "z", "Z"]
        if letters < 1:
            continue
        else:
            for letter in range(0, letters):
                password.append(random.choice(alphabet))    # adding characters to the list
            while True:
                symbols = int(input("How many symbols would you like in your password? "))
                sym_list = ["!", "|", "@", "#", "$", "%", "&", "/", "(", ")", "=", "?",
                            "¿", "¡", "*", "[", "]", "{", "}", ";", ",", ":", ".", "-",
                            "_", "<", ">", "+"]
                if symbols < 0:
                    continue
                else:

                    # 2) Symbols:
                    for symbol in range(0, symbols):
                        password.append(random.choice(sym_list))    # adding characters to the list
                    while True:
                        numbers = int(input("How many numbers would you like in your password? "))
                        if numbers < 0:
                            continue
                        else:

                            # 3) Numbers:
                            for number in range(0, numbers):
                                random_numbers = randint(0, 9)
                                password.append(str(random_numbers))  # adding characters to the list

                            # GENERATING PASSWORD:
                            print(f"\nHere is your password generated: {''.join(random.sample(password, len(password)))}")
                            # or
                            final_password = ""     # STRING variable
                            for char in password:
                                final_password += char  # it will append the letters from LIST to STRING
                            print(f"Here's an alternative one generated: {final_password}")

                            break       # exit from NUMBERS
                    break           # exit from SYMBOLS
            break           # exit from LETTERS

    # Asking to play again:
    while True:
        again = str(input("\nDo you want to generate another password? (y/n): ").lower())
        if again not in ("y", "n"):
            print("\n")
            continue
        else:
            if again == "y":
                break  # will return to the beginning of the game
            else:
                print("See you next time :)")
                play = False
                break  # will exit the game

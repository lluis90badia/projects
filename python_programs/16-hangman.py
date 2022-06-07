import time
from random import choice

play = True
while play:

    print("\nWelcome to the Hangman game!\n")
    time.sleep(1)

    end_of_game = False
    while not end_of_game:

        alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
                    "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

        # Choosing the level of difficulty:
        while True:
            level = input("Please enter the level of difficulty: 1, 2 or 3: ")
            if level not in ("1", "2", "3"):
                continue
            else:
                if level == "1":
                    lives = 5
                elif level == "2":
                    lives = 4
                else:
                    lives = 3
                break

        # We pass the level number and the function returns a random word from the level chosen:
        def choosing_word(num_level):
            dict_words = {"1": ["APPLE", "MUSIC", "PENCIL", "BALL", "TABLE", "GUITAR", "WINDOW"],
                          "2": ["LANDSCAPE", "COMPUTER", "PICTURE", "NEWSPAPER", "PYTHON", "SUITCASE", "LIGHTNING"],
                          "3": ["JUKEBOX", "KEYHOLE", "UNKNOWN", "TWENTY", "BOXCAR", "COPYRIGHT", "POSTGRESQL"]}
            chosen_dict = dict_words[num_level]
            chosen_word = choice(chosen_dict)
            return chosen_word

        # We save the random word into a variable. Therefore, we can convert it to blank (in the next function):
        word_to_guess = choosing_word(level)
        # print(f"\nPsst!.. the word to guess is: {word_to_guess}")

        # Converting the random word to blank and save it into a variable:
        def blank_word(word):
            display = []
            for _ in range(len(word)):
                display += "_"
            return display

        spaces_to_guess = blank_word(word_to_guess)
        print(spaces_to_guess)

        # Function to check if the letter entered is or not in the word to guess. It will run
        # until we guess ALL the letters, or we RUN OUT of lives:
        def guessing():
            global lives
            blanks = len(spaces_to_guess)

            while lives > 0 or blanks == 0:
                print(f"\n{lives} remaining.")
                letter = input("Please, enter a character: ").upper()

                # letter which is not in the alphabet list:
                if letter not in alphabet:
                    lives -= 1
                    print("Wrong character :(")
                    if lives == 0:
                        return 0
                else:
                    for char in range(len(word_to_guess)):
                        character = word_to_guess[char]

                        # letter from the alphabet IS in the word to guess:
                        if character == letter:
                            spaces_to_guess[char] = character
                            blanks -= 1
                            if blanks == 0:
                                return 1
                            else:
                                print(f"{' '.join(spaces_to_guess)}")

                        # letter from the alphabet is NOT in the word to guess:
                        elif letter not in word_to_guess:
                            lives -= 1
                            print("Wrong character :(")
                            if lives == 0:
                                return 0
                            else:
                                break

                # To remove the letter, first we find the position of the letter entered
                # and then replace it by "_" through the position, so the list keep
                # the original positions. Therefore, the player cannot use it again:
                if letter in alphabet:
                    position = alphabet.index(letter)
                    alphabet.remove(letter)
                    alphabet.insert(position, "_")


    # end_of_game = False
    # while not end_of_game:
        result = guessing()
        if result == 0:
            print("\nSorry, you lost :(")
            end_of_game = True
        else:
            print(f"\nThe word was {word_to_guess}. Congratulations! :)")
            end_of_game = True

    # Asking to play again:
    while True:
        again = str(input("\nDo you want to play again? (y/n): ").lower())
        if again not in ("y", "n"):
            continue
        else:
            if again == "y":
                print("\n==========================================================================\n")
                break  # will return to the beginning of the game
            else:
                print("See you next time :)")
                play = False
                break  # will exit the game

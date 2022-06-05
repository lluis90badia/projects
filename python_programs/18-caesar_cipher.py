'''
def greet(name):
    print(f"\nHello {name}! Welcome to the function 'greet'.")
    print("This is just an example to start creating simple functions with inputs")
    print(f"See you araound {name}! :)")

greet(name = str(input("Please enter your name: "))) # or greet("Lluis")

name ---<<<> PARAMETER: is the name of the argument data, and we use the parameter inside the
                        function to refer to it and use it.
"Lluis" ---> ARGUMENT: piece of data that it will pass over to the function, in this case 'greet'.


        TO IMPORT A FUNCTION IN ANOTHER PY FILE, THE NAME PY FILE WHERE CONTAINS
        THE FUNCTION, CANNOT CONTAIN NUMBERS!!!

                EX. 18-caesar_cipher ----> ERROR
                    caesar_cipher -------> CORRECT

        TO CALL ALL THE PY FILE (THAT CONTAINS ONE OR MORE FUNCTIONS) IN ANOTHER FILE:

                import name_of_file  ----> without '.py'

        TO CALL A SPECIFIC FUNCTION IN ANOTHER FILE:

                from name_of_file import name_function

---------------------------------------------------------------------------------------

def greet2(name, location):
    print(f"Hello {name}!")
    print(f"How's the weather in {location}?")

greet2(name = str(input("Please enter your name: ")),
       location = str(input("Please enter a location: "))
       )

       it is the same:

def greet2():
    name = str(input("Please enter your name: "))
    location = str(input("Please enter a location: "))
    print(f"Hello {name}")
    print(f"How's the weather in {location}")

greet2()

-----------------------------------------------------------------

import math

def paint(height, weight):
    coverage = 5
    num_cans = math.ceil((height * weight) / 5)
    print(f"You will need {num_cans} cans to paint that wall")

paint(height = float(input("Please enter the height of the wall: ")),
      weight = float(input("Please enter the weight of the wall: "))
      )
'''

def encrypt():

    import time
    play = True

    while play:
        print("\nWelcome to the Caesar Cipher game!\n")
        time.sleep(1)

        alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
                    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
                    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "!", "@", "#",
                    "$", "%", "&", "/", "(", ")", "=", "?", "¿", "¡", "|", "-", "_",
                    ".", ":", ",", ";", "*", "[", "]", " ", "{", "}"]

        while True:
            direction = str(input("Please type 'encode' to encrypt or 'decode' to decrypt: "))
            if direction not in ("encode", "decode"):
                continue
            else:
                # encode
                if direction == "encode":
                    text = str(input("Please type your message:\n")).lower()
                    while True:
                        shift = int(input("Please type the shift number: "))
                        if shift < 1:
                            continue
                        else:
                            # We will get the remainder that will be less than 63:
                            shift = shift % 63
                            new_text = ""
                            for letter in text:
                                # if the letter after applying shift will have to go back to the beginning:
                                if alphabet.index(letter) + shift < alphabet.index(alphabet[-1]):
                                    position = alphabet.index(letter) + shift
                                    new_letter = alphabet[position]
                                    new_text += new_letter
                                else:
                                    # subtracting the shift after gone to end with the remaining:
                                    remaining = shift - (alphabet.index(alphabet[-1]) - alphabet.index(letter))
                                    position = alphabet.index("a") + (remaining - 1)
                                    new_letter = alphabet[position]
                                    new_text += new_letter
                            print(f"The coded text is: {new_text}")
                            break
                # decode
                else:
                    text = str(input("Please type your message:\n")).lower()
                    while True:
                        shift = int(input("Please type the shift number: "))
                        if shift < 1:
                            continue
                        else:
                            # We will get the remainder that will be less than 63:
                            shift = shift % 63
                            new_text = ""
                            for letter in text:
                                # if the letter after applying shift will have to go back to the beginning:
                                if alphabet.index(letter) - shift >= alphabet.index(alphabet[0]):
                                    position = alphabet.index(letter) - shift
                                    new_letter = alphabet[position]
                                    new_text += new_letter
                                else:
                                    # subtracting the shift after gone to end with the remaining:
                                    remaining = shift - alphabet.index(letter)
                                    position = alphabet.index("}") - (remaining - 1)
                                    new_letter = alphabet[position]
                                    new_text += new_letter
                            print(f"The decoded text is: {new_text}")
                            break
                    break
                break

        # Asking to play again:
        while True:
            again = str(input("\nDo you want to play again? (y/n): ").lower())
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


encrypt()

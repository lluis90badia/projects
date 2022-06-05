from random import randint
import time

play = True
while play:         # will continue the game if the user say 'yes' at the end of the game.
    print("\nWelcome to the Lucky game!\n")
    time.sleep(1)
    print("The game consists to choose 3 numbers between 1 and 3. Good luck!\n")
    numbers_player = []

    # 1) The player enters three numbers:
    for x in range(3):
        while True:
            player = int(input("Please enter a number between 1 and 3: "))
            if player < 1 or player > 3:
                continue
            else:
                numbers_player.append(player)
                break

    # 2) The computer chooses three random numbers between 1 and 5:
    numbers_computer = []
    for number in range(0, 3):
        numbers_computer.append(randint(1, 3))

    # 3) Checking if the numbers match:
    if numbers_player[0] == numbers_computer[0] and numbers_player[1] == numbers_computer[1] and numbers_player[2] == numbers_computer[2]:
        print("\nCongratulations! Today's your lucky day :)")
    else:
        print(f"\n{numbers_computer}: Sorry, I'm sure next time you'll have more luck")

    # 4) Asking the player to play again:
    while True:
        again = str(input("\nDo you want to play again? (y/n): "))
        if again not in ("y", "n"):
            print("\n")
            continue
        else:
            if again == "y":
                break           # will return to the beginning of the game
            else:
                print("See you next time :)")
                play = False
                break           # will exit the game

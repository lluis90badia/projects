import time
players = []


# Clearing the screen after player input:
def clear_screen():
    clear = "\n" * 20
    print(clear)


# Adding the name of the player and its bid:
def player():
    new_bid = {}
    print("\n")
    new_bid["player"] = str(input("Please enter your name: "))
    while True:
        new_bid["bid"] = float(input("Please enter your bid: €"))
        if new_bid["bid"] <= 0:
            continue
        else:
            players.append(new_bid)
            clear_screen()
            break


# Game
play = True
while play:
    print("\nWelcome to the Auction game!")
    time.sleep(1)

    # Player input:
    player()

    # Asking if there is another player to bid:
    while True:
        next_player = str(input("Are there any other bidders? (y/n): "))
        if next_player not in ("y", "n"):
            continue
        else:
            if next_player == "y":
                player()
                continue
            else:
                winner = sorted(players, key=lambda players: players["bid"], reverse=True)

                # In case the top 2 (at least) have the same bid:
                if winner[0]['bid'] == winner[1]['bid']:
                    print("Sorry, but more than one player have the same bid :(")

                else:
                    print(f"\nThe winner is {winner[0]['player']} with a bid of {round(winner[0]['bid'], 2)}€. Congratulations :)")
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

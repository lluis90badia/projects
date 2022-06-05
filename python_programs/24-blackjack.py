import time
import random

cards = {"A": 11, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
         "10": 10, "J": 10, "Q": 10, "K": 10}

play = True
while play:
    print("\nWelcome to the Blackjack game!")
    time.sleep(1)

    player = []
    dealer = []
    player_amount = 0
    dealer_amount = 0

    # Resetting the value for the Ace card:
    cards["A"] = 11

    # Player:
    for card in range(2):
        x = random.choice(list(cards))
        player.append(x)
        player_amount += cards[x]

    if player == ["A", "10"] or player == ["10", "A"] \
            or player == ["A", "J"] or player == ["J", "A"] or player == ["A", "Q"] \
            or player == ["Q", "A"] or player == ["A", "K"] or player == ["K", "A"]:
        print(f"\nYour cards are: {player}. {player_amount}, blackjack!")
        break
    elif player == ["A", "A"]:
        player_amount = 12
    else:
        print(f"\nYour cards are: {player}. Current score: {player_amount}")

    # Dealer:
    y = random.choice(list(cards))
    dealer.append(y)
    dealer_amount += cards[y]
    print(f"\nDealer's first card: {dealer}")

    # Player next move(s):
    # is_over = False
    while True and player_amount <= 21:
        again = input("\nPlease type 'y' to get another card, type 'n' to pass: ")
        if again not in ("y", "n"):
            continue
        else:
            # is_over = False
            if again == "y":
                next_card = random.choice(list(cards))
                player.append(next_card)
                if next_card == "A" and player_amount + cards[next_card] > 21:
                    cards["A"] = 1
                player_amount += cards[next_card]
                if player_amount == 21:
                    print(f"\nYour cards are: {player}. {player_amount}, blackjack!")
                    # is_over = True
                    break
                elif player_amount < 21:
                    print(f"\nYour cards are: {player}. Current score: {player_amount}")
                elif player_amount > 21:
                    print(f"\nYour cards are: {player}. Score: {player_amount}.\nDealer won, you went over :(")
                    # is_over = True
                    break
            else:
                break
        # break

    # Dealer's next move:
    if player_amount > 21:
        break
    else:
        while dealer_amount < 17:
            dealer_card = random.choice(list(cards))
            dealer.append(dealer_card)
            if dealer_card == "A" and player_amount + cards[dealer_card] > 21:
                cards["A"] = 1
            dealer_amount += cards[dealer_card]
        print(f"\nDealer's cards: {dealer}")

        # Giving the choice (randomly) to the dealer in case wants to risk:
        if dealer_amount in (17, 18, 19) and player_amount in (18, 19, 20):
            choice = random.randint(0, 1)
            if choice == 1:
                another_card = random.choice(list(cards))
                dealer.append(another_card)
                if dealer_card == "A" and player_amount + cards[dealer_card] > 21:
                    cards["A"] = 1
                dealer_amount += cards[another_card]
            else:
                pass
        elif player_amount == 21 and dealer_amount < 21:
            another_card = random.choice(list(cards))
            dealer.append(another_card)
            dealer_amount += cards[another_card]

        # Final result:
        if dealer_amount > 21:
            print(f"\nThe dealer went over ({dealer_amount}). Congratulations! You won :)")
        elif player_amount > dealer_amount:
            print(f"\n{player_amount} vs {dealer_amount}. Congratulations! You won :)")
        elif player_amount == 21 and dealer_amount == 21:
            if len(player) > len(dealer):
                print(f"\n{player_amount} vs {dealer_amount}. Congratulations! You won :)")
            elif len(dealer) > len(player):
                print(f"\n{player_amount} vs {dealer_amount}. Sorry, you lost :(")
            else:
                print(f"\n{player_amount} vs {dealer_amount}. It's a draw!")
        elif player_amount == dealer_amount:
            print(f"\n{player_amount} vs {dealer_amount}. It's a draw!")
        else:
            print(f"\n{player_amount} vs {dealer_amount}. Sorry, you lost :(")

    # Asking to play again:
    while True:
        again = str(input("\nDo you want to play again? (y/n): ").lower())
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

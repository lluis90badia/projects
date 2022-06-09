import menu as m
import time

money = 0


# Printing report:
def report(trigger):
    print("\nHere is the current state of the resources:")
    print(f"Water:\t{m.resources['water']}ml")
    print(f"Milk:\t{m.resources['milk']}ml")
    print(f"Coffee:\t{m.resources['coffee']}g")
    print(f"Money:\t{money}€")


# TODO: Create flag "off" to END the program:
off = False
while not off:

    # TODO: Ask user "what would you like? (espresso / latte / cappuccino)":
    print("\nHello! Thank you for choosing our Advance Coffee Machine 2.0.")
    time.sleep(1)
    print("\nHere is our menu:\n- Espresso (1.5€)\n- Latte (2.5€)\n- Cappuccino (3€)")
    time.sleep(1)

    while True:
        order = input("\nWhat would you like? (press 'exit' for exit):\n").lower()
        if order not in ("espresso", "latte", "cappuccino", "report", "exit"):
            print("Flavour not available")
            continue
        else:
            if order == "exit":
                print("\nSee you next time :)")
                off = True
                break
            elif order == "report":
                report(order)
            else:

                # TODO: Checking if there are enough resources to prepare the order:
                def enough_res(flavour):
                    for item in m.MENU[flavour]["ingredients"]:
                        if m.MENU[flavour]["ingredients"][item] > m.resources[item]:
                            print(f"Sorry, there is not enough {item}. Please try a different one.")
                            return 0
                    return 1

                # Function to ask and collect the coins:
                def is_transaction_successful(coins_list, coffee):
                    sum_count = ((coins_list[0] * 0.01) + (coins_list[1] * 0.05) + (coins_list[2] * 0.1)
                                 + (coins_list[3] * 0.25))
                    change = sum_count - m.MENU[coffee]["cost"]
                    if change < 0:
                        print("\nSorry, that's not enough money. Money refunded")
                        return 0
                    elif change == 0:
                        print(f"\nProceeding... Here is your {coffee.title()}. Enjoy!")
                        return 1        # accepted
                    else:
                        print(f"\nHere is {round(change,2)}€ in change. Proceeding... Here is your {coffee.title()}. Enjoy!")
                        return 2        # accepted

                # Preparing the flavour (subtracting from resources) or rejecting the order:
                result = enough_res(order)
                coins = []
                list_coins = ["pennies", "nickles", "dimes", "quarters"]
                if result == 1:

                    # Asking the number of coins:
                    for coin in list_coins:
                        while True:
                            cash = int(input(f"\nHow many {coin} do you want to introduce? "))
                            if cash < 0:
                                continue
                            else:
                                coins.append(cash)
                                break

                    # Passing arguments to the function to check if there is enough money to order:
                    result2 = is_transaction_successful(coins, order)

                    # (MAKING FLAVOUR) Subtracting resources depending on the amount of money entered:
                    if result2 in (1, 2):
                        # espresso:
                        espresso_ingredients = ["water", "coffee"]
                        if order == "espresso":
                            for item in espresso_ingredients:
                                m.resources[item] -= m.MENU[order]["ingredients"][item]
                        # latte or cappuccino:
                        else:
                            for item in m.MENU[order]["ingredients"]:
                                m.resources[item] -= m.MENU[order]["ingredients"][item]
                        money += m.MENU[order]["cost"]

                # In case there are not enough resources:
                else:
                    if order == "espresso":
                        print("\nWe regret to inform that the machine is currently out of order because of lack of "
                              "resources.\nUntil then, enjoy your day :)")
                        off = True
                        break           # exit the program
                    else:
                        pass            # option to try another flavour

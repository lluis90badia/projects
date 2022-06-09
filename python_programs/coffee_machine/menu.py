"""
Coffee machine with 3 flavours:
- Espresso      (50 ml water, 18g coffee)                   price: 1.50€
- Latte         (200ml water, 24g coffee, 150ml milk)       price: 2.50€
- Cappuccino    (250ml water, 24g coffee, 100ml milk)       price: 3€

The machine can store MAX these resources:
- 300ml water
- 200ml milk
- 100g coffee

And operates with these coins:
penny =  0.01
nickel = 0.05
dime = 0.1
quarter = 0.25

Program requirements:
- print report: the resources left (water, milk, coffee and money) after or before to order
- check if there are sufficient resources BEFORE the order (if not, return a warning)
- processing coins (counting the SUM of how many of each coin we introduce)
    please insert coins
    how many quarters?
    how many dimes?
    how many nickles?
    how many pennies?
- check if transaction successful?
        if not enough ---> sorry, that's not enough money. Money refunded.
        if yes --> here is your {flavour}, Enjoy!
        in case to enter more money, we have to subtract the remaining and return the change.
"""

MENU = {
    "espresso": {
        "ingredients": {
            "water": 50,
            "coffee": 18
        },
        "cost": 1.5
    },
    "latte": {
        "ingredients": {
            "water": 200,
            "coffee": 24,
            "milk": 150
        },
        "cost": 2.5
    },
    "cappuccino": {
        "ingredients": {
            "water": 250,
            "coffee": 24,
            "milk": 100
        },
        "cost": 3.0
    }
}

resources = {
    "water": 300,
    "milk": 200,
    "coffee": 100
}

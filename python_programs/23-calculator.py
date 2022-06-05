import time

print("\nWelcome to the Calculator 5.0!")
time.sleep(1)


def add(n1, n2):
    if n1.is_integer() is True:
        return int(n1) + n2
    elif n2.is_integer() is True:
        return n1 + int(n2)
    else:
        return n1 + n2


def subtract(n1, n2):
    if n1.is_integer() is True:
        return int(n1) - n2
    elif n2.is_integer() is True:
        return n1 - int(n2)
    else:
        return n1 - n2


def multiply(n1, n2):
    if n1.is_integer() is True:
        return int(n1) * n2
    elif n2.is_integer() is True:
        return n1 * int(n2)
    else:
        return n1 * n2


def division(n1, n2):
    if n2 == 0:
        print("The divisor cannot be 0.")
        while True:
            no_zero = float(input("Please enter a value different than 0: "))
            if no_zero == 0:
                continue
            else:
                return n1 / no_zero
    else:
        return n1 / n2


def modulus(n1, n2):
    return n1 % n2


operations = {"+": add, "-": subtract, "*": multiply, "/": division, "%": modulus}


def calculator():       # This is a RECURSION (a function that it calls ITSELF,
                        # where the program it will reset

    # Entering the numbers and the operator:
    first_num = float(input("\nPlease enter your first value: "))
    for operator in operations:
        print(operator)

    # Adding a flag in case they want to make another calculation:
    next_operation = True
    while next_operation:

        while True:
            symbol = input("Please pick an operation: ")
            if symbol not in ("+", "-", "*", "/"):
                continue
            else:
                second_num = float(input("Please enter the next value: "))

                # It will calculate the operation based on the symbol selected and the numbers entered:
                calculation_function = operations[symbol]
                result = calculation_function(first_num, second_num)
                print(f"The result is: {result}")

                # Asking for another calculation, reset or exit the program:
                while True:
                    next_move = input(f"Please type 'y' to continue calculating with the previous "
                                      f"result, 'n' to reset or 'exit' to exit the program: ")
                    if next_move not in ("y", "n", "exit"):
                        continue
                    else:
                        if next_move == "y":
                            first_num = result
                        elif next_move == "n":
                            next_operation = False
                            calculator()        # it will reset the program without exit the program
                        else:                   # and going to the BEGINNING of the function "calculator"
                            print("\nSee you next time :)")
                            next_operation = False
                            break
                    break
            break


calculator()        # Calling the function in order for it to find the place where this function was
                    # defined and to actually carry out all of those instructions.

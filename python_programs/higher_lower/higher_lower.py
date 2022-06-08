import random
import time

# Importing the python file which contains the list of Instagram accounts:
import accounts as acc

# Game STARTS:
play = True
while play:
    print("\nWelcome to Higher-Lower!")
    time.sleep(1)

    score = 0
    """
    Assigning the original challenger B because, first, it will become challenger A, and then
    we will generate a NEW challenger B. Therefore, we won't get an ERROR at the beginning of the
    game.
    """
    b_challenger = random.choice(acc.data)

    # Making the game repeatable
    should_continue = True
    while should_continue:

        # Generating random accounts for challenger A and challenger B ----> random.choice(list)
        a_challenger = b_challenger             # in the 1st ROUND: ORIGINAL challenger B becomes challenger A
        b_challenger = random.choice(acc.data)  # ----> NEW challenger B
        while a_challenger == b_challenger:
            b_challenger = random.choice(acc.data)
        """
        Asking the user for a guess and creating variables for their follower counts that will be sent
        to the next function "check_answer":
        """
        print(f"\nCompare A:  {a_challenger['name']}, a {a_challenger['description']} from {a_challenger['country']}\n"
              f"Against B:  {b_challenger['name']}, a {b_challenger['description']} from {b_challenger['country']}")

        while True:
            choosing = input("\nWhich account has more followers? Please type 'a' or 'b': ").lower()
            if choosing not in ("a", "b"):
                continue
            else:
                break
        count_followers_a = a_challenger["follower_count"]
        count_followers_b = b_challenger["follower_count"]

        # Checking if user has chosen correct:
        def check_answer(guess, a_followers, b_followers):
            if a_followers >= b_followers and guess == "a":
                return 1
            elif b_followers >= a_followers and guess == "b":
                return 1
            else:
                return 0

        # Checking the result:
        result = check_answer(choosing, count_followers_a, count_followers_b)

        # Returning feedback on its guess:
        if result == 1:
            score += 1
            print(f"\nCorrect! Current score: {score}")
        else:
            print(f"\nSorry, that's wrong. Final score: {score}")
            should_continue = False

        # Moving challenger B to challenger A
        temp = b_challenger
        a_challenger = temp
        b_challenger = a_challenger

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
                print("\nSee you next time :)")
                play = False
                break  # will exit the game

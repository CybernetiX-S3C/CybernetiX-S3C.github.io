from termcolor import colored
import os
import getpass

VER = "0.1"

def banner():
    logo = """
___________             .__       .__            
\_   _____/____    ____ |__|____  |  |           
 |    __) \__  \ _/ ___\|  \__  \ |  |    ______ 
 |     \   / __ \\  \___|  |/ __ \|  |__ /_____/ 
 \___  /  (____  /\___  >__(____  /____/         
     \/        \/     \/        \/               
         __________                              
         \______   \ ____   ____  ____   ____    
   ~JPM   |       _// __ \_/ ___\/  _ \ /    \   
  Version |    |   \  ___/\  \__(  <_> )   |  \  
    {0}   |____|_  /\___  >\___  >____/|___|  /  
                 \/     \/     \/           \/   
            {1}, you have been activated                                                                   
    """
    clear()
    print(logo.format(
        VER,
        colored(getpass.getuser(), 'red', attrs=['bold'])
        )
    )


def clear():
    os.system('cls' if os.name == 'nt' else 'clear')


def section(name):
    print("\n{} {}".format(
        colored("::", 'blue', attrs=['bold']),
        colored(name, attrs=['bold'])
        )
    )


def task(name):
    print('{} {}'.format(
        colored("==>", 'green', attrs=['bold']),
        colored(name, attrs=['bold'])
        )
    )


def subtask(name):
    print('{} {}'.format(
        colored("  ->", 'blue', attrs=['bold']),
        colored(name, attrs=['bold'])
        )
    )


def failure(name):
    print('{} {}'.format(
        colored("==> ERROR:", 'red', attrs=['bold']),
        colored(name, attrs=['bold'])
        )
    )


def subfailure(name):
    print('{} {}'.format(
        colored("  ->", 'red', attrs=['bold']),
        colored(name, 'red', attrs=['bold'])
        )
    )


def prompt(name):
    print('{} {}'.format(
        colored("==>", 'yellow', attrs=['bold']),
        colored(name, attrs=['bold'])),
        end=""
    )


def subprompt(name):
    print('{} {}'.format(
        colored("  ->", 'yellow', attrs=['bold']),
        colored(name, attrs=['bold'])),
        end="")

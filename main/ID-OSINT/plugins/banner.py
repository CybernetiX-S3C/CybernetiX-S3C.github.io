# -*- coding: utf-8 -*-
from __future__ import print_function
from plugins.colors import BodyColors as bc


class Logo:

    def __init__(self):
        pass

    def banner(self):
        print("")
        print("\t\t ___________        _____ _____ _____ _   _ _____ ")
        print("\t\t|_   _|  _  \      |  _  /  ___|_   _| \ | |_   _|")
        print("\t\t  | | | | | |______| | | \ `--.  | | |  \| | | |  ")
        print("\t\t  | | | | | |______| | | |`--. \ | | | . ` | | |  ")
        print("\t\t _| |_| |/ /       \ \_/ /\__/ /_| |_| |\  | | |  ")
        print("\t\t \___/|___/         \___/\____/ \___/\_| \_/ \_/  ")
        print(
            ("\t\t{},.-~*´¨¯¨`*·~-.¸{}-({}by{})-{},.-~*´¨¯¨`*·~-.¸{} \n").format(
                bc.CRED,
                bc.CYLW,
                bc.CCYN,
                bc.CYLW,
                bc.CRED,
                bc.CEND))
        print(
            ("\t\t\t      {}     ██╗██████╗ ███╗   ███╗{}").format(
                bc.CBLU,
                bc.CRED,
                bc.CBLU,
                bc.CEND))
        print(
            ("\t\t\t      {}     ██║██╔══██╗████╗ ████║{}").format(
                bc.CBLU,
                bc.CRED,
                bc.CBLU,
                bc.CEND))
        print(
            ("\t\t\t      {}     ██║██████╔╝██╔████╔██║{}").format(
                bc.CBLU,
                bc.CRED,
                bc.CBLU,
                bc.CEND))
        print(
            ("\t\t\t      {}██   ██║██╔═══╝ ██║╚██╔╝██║{}").format(
                bc.CBLU,
                bc.CRED,
                bc.CBLU,
                bc.CEND))
        print(
            ("\t\t\t      {}╚█████╔╝██║     ██║ ╚═╝ ██║{}").format(
                bc.CBLU,
                bc.CRED,
                bc.CBLU,
                bc.CEND))
        print(
            ("\t\t\t      {} ╚════╝ ╚═╝     ╚═╝     ╚═╝{}").format(
                bc.CBLU,
                bc.CRED,
                bc.CBLU,
                bc.CEND))
        print(("\t\t\t      {}  https://CybernetiX-S3C.github.io {}\n").format(bc.CYLW, bc.CEND))


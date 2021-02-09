import os
import sys

fileName = sys.argv[1]

os.system("python ct.py "+fileName+" >__temp_ir__.ir")
ir = open("__temp_ir__.ir").read()
goal = "astHandle("+ir+", ResAST), write(ResAST)."
os.system("swipl -s c.pl -g \""+goal+"\" -t halt.")
os.remove("__temp_ir__.ir")
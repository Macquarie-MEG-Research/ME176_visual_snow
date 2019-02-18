from psychopy import visual,core,event,gui,sound, parallel
from datetime import datetime
import random
import numpy as np
from csv import DictWriter
import csv
import glob
import numpy as np

## SET UP WINDOW
win = visual.Window([1920,1080],allowGUI=True,fullscr=False, units= "pix", color = (0,0,0))

## Set up variables

RGB_list = [[1.0, 0.6, 0.6],[1,1,1]]
size_of_rect = 800
time_of_rep = 1.5

## Present stim

for stim in RGB_list:

    rect = visual.Rect(
        win=win,
        units="pix",
        width=size_of_rect,
        height=size_of_rect,
        fillColor= stim,
        lineColor=stim
    )
    
    #rect.setColor([1.0, 0.6, 0.6],colorSpace='rgb')
    
    rect.draw()
    win.flip()
    
    core.wait(time_of_rep)
    
win.close()
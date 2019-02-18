from psychopy import visual,core,event,gui,sound, parallel
from datetime import datetime
import random
import numpy as np
from csv import DictWriter
import csv
import glob
import numpy as np
#from ctypes import windll

## SET UP WINDOW
win = visual.Window([1920,1080],allowGUI=True,fullscr=False, units= "pix", color = (0,0,0))

## VARIABLES

#Trial Number starts at 1
trialnumber = 0 
correct_count = []

## Set port information
#p = parallel.ParallelPort('0xD020')
#p.setData(0)

## Set up variables

vis_cue_BY = visual.GratingStim(win,tex='sqr',pos=(0.0, 0.0),size=(410,410),sf=0.023)
vis_cue_BY.setColor([0,90,1], colorSpace='dkl')

vis_cue_RG = visual.GratingStim(win,tex='sqr',pos=(0.0, 0.0),size=(410,410),sf=0.023)
vis_cue_RG.setColor([0,0,1], colorSpace='dkl')

vis_cue_Ach = visual.GratingStim(win,tex='sqr',pos=(0.0, 0.0),size=(410,410),sf=0.023)
vis_cue_Ach.setColor([90,0,1], colorSpace='dkl')

fixation = visual.TextStim(win, text='+', pos=(0.0, 0.0),height = 50)

instructions = visual.TextStim(win,text='Please keep still! The experiment is about to start...',
pos=(0.0, 0.0),height = 50)

rect_white = visual.Rect(win=win,width=50,height=50,
    fillColor= [1,1,1],lineColor = [1,1,1],pos=(800.0,-400.0))
rect_black = visual.Rect(win=win,units="pix",width=50,height=50,
    fillColor= [-1,-1,-1],lineColor = [-1,-1,-1],pos=(800.0,-400.0))

# Show instructions
instructions.draw()
rect_black.draw()
win.flip()
keyPress_intro = event.waitKeys(keyList=['space'])

print("Managed to set up the experiment")

for cycle in range(1,8,1):

    for trial in range(1,5,1):
    
        fixation.draw()
        rect_black.draw()
        win.flip()
        core.wait(2.0)
    
        vis_cue_BY.draw()
        rect_white.draw()
        #p.setData(18)
        win.flip()
        core.wait(0.1)
        #p.setData(0)
        core.wait(1.4)
        
    for trial in range(1,5,1):
    
        fixation.draw()
        rect_black.draw()
        win.flip()
        core.wait(2.0)
    
        vis_cue_RG.draw()
        rect_white.draw()
        #p.setData(20)
        win.flip()
        core.wait(0.1)
        #p.setData(0)
        core.wait(1.4)
        
    for trial in range(1,5,1):
    
        fixation.draw()
        rect_black.draw()
        win.flip()
        core.wait(2.0)
    
        vis_cue_Ach.draw()
        rect_white.draw()
        #p.setData(22)
        win.flip()
        core.wait(0.1)
        #p.setData(0)
        core.wait(1.4)



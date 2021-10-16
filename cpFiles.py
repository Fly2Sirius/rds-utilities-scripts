#!/usr/bin/env python3
import shutil
import os

srcDir = "/Volumes/Untitled/DCIM/100GOPRO/"
dstDir = "/Users/krisdavey/Movies/GoPro/"

if os.path.isdir(srcDir):

    for file in os.listdir(srcDir):
        if file.endswith(".MP4"):
            print(f"Copying {file} to {dstDir}")
            shutil.move(os.path.join(srcDir, file), os.path.join(dstDir, file))

    for file in os.listdir(srcDir):
        print("Removing " + srcDir + file)
        os.remove(srcDir + file)
else:
    print("The drive doesn't seem to be inserted")

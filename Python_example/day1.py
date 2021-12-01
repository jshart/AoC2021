
import math

def calculateFuel(fuel):
    r=math.floor(fuel/3)
    f=r-2
    if(f<0):
        f=0

    if (f>0):
        f=f+calculateFuel(f)
    return f

input = [int(x) for x in open("data/input.txt").read().split()]
#input =[12,14,1969,100756]
t=0
for i in input:
    f=calculateFuel(i)
    t=t+f
    print("i="+str(i)+" f="+str(f)+" t="+str(t))

print("total:"+str(t))


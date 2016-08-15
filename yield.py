def yeild11(a,b):

   while True:
       yield b
       a,b=b,a+b
       
       
yy = yeild11(9,6)

[yy.next() for i in range(10)]
    
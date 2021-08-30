f = open("terrors.txt", 'r')
l = f.readlines()
for line in l:
    print("extern type {};".format(line.strip()))

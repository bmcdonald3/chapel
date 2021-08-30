f = open('ArrowHeaders.chpl')
lines = f.readlines()
count = 0


for i in range(len(lines)):
    if 'extern record' in lines[i]:
        j = i
        while('}' not in lines[j]):
            if i+j > len(lines):
                break;
            print(lines[j], end='')
            j += 1
        print('}')

with open('/etc/hosts') as hosts:
    for line in hosts:
        if line.startswith('#'):
            continue
        print line

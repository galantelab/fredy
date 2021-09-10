#!/usr/bin/python3

from sys import argv

arq=open(argv[1],'r')
arq_lines=arq.readlines()

def seq_print(arq,key):
	cont=0
	for i in arq:
		if key in i:
			tmp= i.split("\n")
			cont=1
			print(tmp[0])
			break
	return cont

cont=seq_print(arq_lines,"todos")

if cont == 0:
        cont = seq_print(arq_lines,"Deleção")
else:
	exit()
if cont == 0:
        cont = seq_print(arq_lines,"Adição")
else:
	exit()

if cont == 0:
        cont = seq_print(arq_lines,"Troca")
else:
	exit()

if cont == 0:
	seq_print(arq_lines,"merda")
else:
	exit()

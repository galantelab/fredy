import sys
#import time
#from urllib.request import urlretrieve
#import pandas as pd
#import os.path
#from os import system
from Bio import SeqIO

def sel_aa(lista,fasta,arq_list):
	file=open(lista,'r')
	lista_lines=file.readlines()
	blacklist=list([])
	for i in lista_lines:
#		print(i[:-1])
		tam=0
		id='-'
		seq='-'
		for seed_record in SeqIO.parse(fasta, "fasta"):
#			print(len(seed_record.seq))
#			if mode == 'string':
#			print(i)
			if i[:-1] in seed_record.description and len(seed_record.seq) > tam:
				tam=len(seed_record.seq)
				id=seed_record.description
				seq=seed_record.seq
		if id != '-':
#			pass
			print(">"+id)
			print(seq)
		else:
			blacklist.append(i)
	black=open(arq_list,'w')
	black.writelines(blacklist)
	black.close()
#			break
#				break
#			else:
#				if "GN="+i[:-1] in seed_record.description and "Fragment" not in seed_record.description:
#					print(">"+seed_record.description)
#					print(seed_record.seq)

sel_aa(sys.argv[1], sys.argv[2], sys.argv[3])

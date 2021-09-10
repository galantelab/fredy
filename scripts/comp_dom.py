#!/usr/bin/python3

from sys import argv

arq = open(argv[1], 'r')
arq_lines = arq.readlines()
list_dom= list([])
list_id= list([])
to_dict=list([])
for i in arq_lines:
	tmp = i.split(" ")
#	print(argv[2])
	if tmp[0] == str(argv[2]):
		list_dom.append(tmp[1])
		to_dict.append((tmp[1],tmp[2]))
	else:
		list_id.append(tmp[0])

dic_dom=dict(to_dict)
list_uniq= list(set(list_id))
to_dic_pa=list([])

list_dom_uniq=list([])
for i in list_uniq:
	cont=0
	list_dom_uniq=list([])
	for j in arq_lines:
		tmp = j.split(" ")
		if tmp[0] == i:
			list_dom_uniq.append(tmp[1])
			to_dic_pa.append((tmp[1],tmp[2]))

dic_dom_uniq=dict(to_dic_pa)
status=''
man=list(set(list_dom_uniq).intersection(list_dom))
dlt=list(set(list_dom_uniq) - set(list_dom))
add=list(set(list_dom) - set(list_dom_uniq))
if len(man) > 0 and len(add) == 0 and len(dlt) == 0:
	status='Manteve todos os dominios '
elif (len(man) > 0 and len(add) > 0 and len(dlt) > 0) or (len(man) == 0 and len(add) > 0 and len(dlt) > 0):
	status='Troca de dominios '
elif len(add) > 0 and len(dlt) == 0 and len(man) >= 0:
	status='Adição de dominios '
elif len(add) == 0 and len(dlt) > 0 and len(man) >= 0:
	status='Deleção de domínios '
else:
	status='Deu merda ai'

key='(Manteve todo o dominio)'

for i in man:
	if float(dic_dom[i])-float(dic_dom_uniq[i]) >= 5:
		key='(Ganhou parte do domínio)'
	elif float(dic_dom[i])-float(dic_dom_uniq[i]) <= -5:
		key='(Perdeu parte do domínio)'

if len(list_uniq) == 0:
	key='FP'

if len(man) == 0:
	key='-'

print("#ID\tManteve\tPerdeu\tAdicionou\tStatus")
print("{}\t{}\t{}\t{}\t{}".format(argv[2], man, dlt, add, status+key))

#!/usr/bin/python3

import sys

gtf = open(sys.argv[1],"r")
gtf_lines = gtf.readlines()
for i in range(len(gtf_lines)):
	tmp = gtf_lines[i].split("\t")
	info = tmp[8].split('"')
	if i+1 < len(gtf_lines):
		comp = gtf_lines[i+1].split("\t")
	elif i+1 >= len(gtf_lines):
		comp = gtf_lines[0].split("\t")
	if "transcript" in comp[2]:
		print("{}\t{}\t{}".format(info[3],tmp[6],info[5]))

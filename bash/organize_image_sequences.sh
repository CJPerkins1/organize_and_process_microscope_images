#!/usr/bin/env bash

mkdir scratch

mv *thumb* scratch

find . -name "*.TIF" | awk -F"_" -v mvcmd='mv "%s" "%s"\n' '{old=$0; gsub(/s/,"",$5); gsub(/t/,"",$6); new=sprintf("%s_%s_%s_%ss%02d_t%02d.TIF", $1,$2,$3,$4,$5,$6); printf mvcmd,old,new;}' | sh

for i in {01..24..1}; do
	mkdir well_${i}	
	mv *s${i}* well_${i}
done	

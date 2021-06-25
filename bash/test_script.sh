for i in A1 A2 A3 A4 A5 A6 B1 B2 B3 B4 B5 B6 C1 C2 C3 C4 C5 C6 D1 D2 D3 D4 D5 D6; do
   echo  well_${i}
   for x in *.TIF; do
        echo $x $(echo $x | sed -E "s/s[0-9]*/$i/g")
   #     mv $x $(echo $x | sed 's/_13/_15/g')
   done
   # cd ..
done

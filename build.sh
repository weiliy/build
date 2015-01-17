#!/bin/bash
#Pre-pocessing, support
# <if></if>
# include
#
#set -x

# Function to include script to main script output

include ()
{
[ -f "$1" ] || ( echo "include.err: $1 is illegal." >&2 ; exit 1 )

COMMSKIP=1

cat "$1" | while IFS=$'\n' read -r LINE
do
    if [ $COMMSKIP -ne 0 ]
    then
        if [ 0 -eq $(echo "$LINE" | grep "^#" | wc -l) ]
        then
            COMMSKIP=0
            echo "$LINE"
        fi
    else
        echo "$LINE"
    fi
done
}

# Function to hand <if>

while_if ()
{
IN=$1
OS=$2
OUT=$3
IFCACHE=".build.if.cache"
> $OUT || ( echo "ERRO: > $OUT" >&2 ; exit 1 )
> $IFCACHE || ( echo "ERRO: > $IFCACHE >&2" ; exit 1 )

IFFLAG=0	;# 1: start if ; 0: exit if 
IFMATCH=0	;# 1 will processing if
while IFS=$'\n' read -r LINE
do
	case "$IFFLAG" in
		0)
			IFFLAG=$(echo "$LINE" | grep '^<if' | wc -l)
			if [ 0 -ne $IFFLAG ] 
			then
				EX=$(echo "$LINE" | cut -d' ' -f2)
				[ ${#OS} -eq $(expr "$OS" : "$EX") ] && \
					IFMATCH=1
			else
				echo "$LINE"
			fi
			;;
		1)
			if [ 0 -eq $(echo "$LINE" | grep '^</if>' | wc -l) ]
			then
				[ 1 -eq $IFMATCH ] && echo $LINE > $IFCACHE 
			else
				. $IFCACHE 
				IFFLAG=0
				IFMATCH=0
				>$IFCACHE 
			fi
			;;
	esac				
done < $IN >> $OUT

}
# ## Main Script

echo -en "Build start at $(date)\n"

echo -en "Cache INDEX... "
INDEXCACHE=.build.index.cache
> .build.index.cache
[ $? -ne 0 ] && ( echo "ERRO: > .build.index.cache" >&2 ; exit 1 )

ls | grep ".index$" | while read LINE
do
	EXPECT=${LINE/%.index/.sh}
	[ -f "$EXPECT" ] &&  \
		echo -e "$EXPECT\t$LINE" >> $INDEXCACHE
done
echo -en ">> $INDEXCACHE DONE!\n"

cat $INDEXCACHE | while read LINE
do
	INPUTFILE=$(echo "$LINE" | cut -f1)
	INDEXFILE=$(cat $INDEXCACHE | grep "^$INPUTFILE" | cut -f2)

	echo -en "Load $INDEXFILE\n"

	[ -f "$INPUTFILE" ] || ( echo "ERRO: INDEX -> $INPUTFILE" >&2; exit 1)

	echo -en "  Release...\n"
	for STR in $(cat $INDEXFILE | grep -v "^#" | cut -f1)
	do
		echo -en "  $STR "
		OUTPUTFILE=release/$(cat $INDEXFILE | grep "^$STR" | head -n1 | cut -f2)
		while_if $INPUTFILE $STR $OUTPUTFILE	
		echo -en ">> $OUTPUTFILE "	

		echo -en "...check"
		bash -n $OUTPUTFILE \
		&& echo -en "...OK!\n" \
		|| echo "...Failed!\n" \
		&& bash -n $OUTPUTFILE  
	done
done

echo -en "Cleaning "
rm -rf $INDEXCACHE
rm -rf $IFCACHE 
echo -en "...DONE!\n"
echo -en "Build complated at $(date)\n"


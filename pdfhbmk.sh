#!/bin/bash

#/////////////////////////////////////////////////////////////////////////
#  PDFHBMK  (PDF HANDBOOK MAKER) Transforms PDF documents to printeable handbook format
#  Copyright (C) 2013  Daniel Campoverde Carrión [alx741]

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#---------------------------------------------------------------------
#>>> This script depends on:  poppler, pdfjam, texlive-bin  <<<<<<<<<<
#---------------------------------------------------------------------

#////////////////////////////////////////////////////////////////////////


#First argument is the pdf file to compute
FILE="$1"

#Check if FILE exists and  is a PDF file 
echo
echo "Verifying document..."

if [ -f "./$FILE" ]; then

	FILE_TYPE=`file -b "$FILE" | grep -i pdf -o`

	if [ "$FILE_TYPE" != "PDF" ]; then
		echo "FATAL ERROR: Need a valid PDF file"
		exit 1 
	fi

else
	echo "FATAL ERROR: $FILE does not exist"
	exit 1 
fi

echo "Document verification [OK]"

ID=$RANDOM
mkdir "tmp_pdfhbmk_$ID"
cd "tmp_pdfhbmk_$ID"

#extract FILE pages 
echo
echo "Splitting pages..."

pdfseparate "../$FILE" 'page_%d.pdf'

#### Generate printable handbook

#get number of pages in pdf document
PAGES=`pdfinfo "../$FILE" | grep '^[pP]ages' | cut -d ":" -f 2 | sed 's/ //g'`

#compute offset
if [ $(($PAGES%2)) == 0 ]; then

	SPLIT_OFFSET=$((($PAGES/2)+1))

else

	SPLIT_OFFSET=$((($PAGES/2)+2))
fi

#join pages 
echo
echo "Joining pages..."

i=1
j=$SPLIT_OFFSET
PAGES_LIST=""

while [ $i -lt $SPLIT_OFFSET ]; do
	
	if [ $(($PAGES%2)) != 0 ] && [ $i == $(($SPLIT_OFFSET - 1)) ]; then
		PAGES_LIST="$PAGES_LIST page_$i.pdf" 
	else
		PAGES_LIST="$PAGES_LIST page_$i.pdf page_$j.pdf"
	fi

	i=$(($i+1))
	j=$(($j+1))

done

pdfunite $PAGES_LIST "../handbook_tmp.pdf"

#Clean temp files
cd ..
rm -rf "tmp_pdfhbmk_$ID"

#Create 2x1 pages document
echo
echo "Generating 2x1 pages document..."

pdfnup --landscape --nup 2x1 "handbook_tmp.pdf"
mv "handbook_tmp-nup.pdf" "handbook_$FILE"
rm "handbook_tmp.pdf"

echo
echo
echo
echo "[DONE]"
echo "Execute a 2 side printing of: handbook_$FILE"
echo
echo "Then guillotine paper in the middle, organize and make a book ringing or a hard plaster"
echo

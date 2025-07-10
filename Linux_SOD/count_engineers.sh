#!/bin/bash

##This script creates the files that are needed for counting the nr. of ocurrences of the word engineers, performing the counting  operation and calculating the time need for this operation to occur"

echo "### Creating work directory and the .txt files" > file_out.txt

mkdir -p work/files/wiki

echo "### Directory work  created" >> file_out.txt

cat > work/files/wiki/page1.txt << EOL
John is a software engineer.
Engineers solve complex problems.
Engineering is a discipline.
EOL

echo "### Page1.txt created" >> file_out.txt


cat > work/files/wiki/page2.txt << EOL
A systems engineer builds infrastructure.
Engineer your career wisely.
EOL

echo "### Page2.txt created" >> file_out.txt

cat > work/files/wiki/page3.txt << EOL
ENGINEER - a person who designs, builds, or maintains engines or machines.
engineer
engineer
engineer
EOL

echo "### Page3.txt created" >> file_out.txt

cat > work/files/wiki/page4.txt << EOL
This document does not mention the target word.
Except this: engineer.
EOL

echo "### Page4.txt created" >> file_out.txt

cat > work/files/wiki/page5.txt << EOL
Data engineers and ML engineers are in high demand.
engineering engineering engineering
EOL

echo "### Page5.txt created" >> file_out.txt

echo "### Reading operation start time" >> file_out.txt

start_time=$(date +%s.%N)

# Count occurrences of the word 'engineer' in all files

echo "###  Counting occurrences of the word 'engineer' in all files" >> file_out.txt
count=$(grep -rohwi engineer work/files/wiki/ | wc -l)

echo "Occurrences of 'engineer': $count" >> file_out.txt

echo "### Reading operation  end time" >> file_out.txt

end_time=$(date +%s.%N)

# Calculate elapsed time
echo "### Calculating elapsed time" >> file_out.txt

elapsed=$(echo "$end_time - $start_time" | bc)

echo "Time taken: $elapsed seconds" >> file_out.txt


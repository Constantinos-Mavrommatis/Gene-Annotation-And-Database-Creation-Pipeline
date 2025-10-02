#!/usr/bin/bash

echo -e "\n============================================================="
echo -e " Welcome to DatabaseMaker2025!"
echo -e "=============================================================\n"

# We are asking the user if they want to load the script

read -p $'\nWould you like to start the script (YES/NO): ' load_script

# If they input "YES" then we ask them what file they want to load

if [[ ${load_script} == YES ]]
then

	read -p $'\nWhat is the name of the file you want to load: ' sequences_input
	
	echo -e "\n------------------------------------------------------------------------------------------------"

# If the file is not empty then we proceed to check if the format is correct

	if [ -s ${sequences_input} ]
	then
		
		echo -e "\n[INFO] Loading Ensembl Stable ID's from file: ${sequences_input}..."
		
# This while loop checks if the format of the Ensembl ID is correct 
# ENS[species prefix][feature type prefix][a unique eleven-digit number] 
# but only for Gene feature type because the script only works with genes.
								
		while read wholeline
		do
						
			if [[ ${wholeline:0:3} == "ENS" ]]
			then		
				
				if [[ ${wholeline:6:1} == "G" ]]
				then
										
					unique=${wholeline:7:11}
					
					if [[  ${#unique} == 11 ]]
					then
						echo -e "\n[SUCCESS] Valid Ensembl Stable ID found: ${wholeline}"
						continue
					else		
						echo -e "\n[FAILURE] Invalid Ensembl Stable ID format, after Feature Type Prefix: ${wholeline:7:11} Exiting Script...\n"
						return
					fi

# The elif statement is required for human stable IDs

				elif [[ ${wholeline:3:1} == "G" ]]
				then
					unique2=${wholeline:4:11}

					if [[ ${#unique2} == 11 ]]
					then
						echo -e "\n[SUCCESS] Valid Ensembl Stable ID found: ${wholeline}"
						continue
					else  
						echo -e "\n[FAILURE] Invalid Ensembl Stable ID format, after Feature Type Prefix: ${wholeline:4:11} Exiting Script...\n"
						return
					fi
				else
					echo -e "\n[FAILURE] Invalid Ensembl Stable ID Feature Type Prefix: ${wholeline} Exiting Script...\n"
					return
				fi
			else
				echo -e "\n[FAILURE] Invalid Ensembl Stable ID format: ${wholeline} Exiting Script...\n"
				return
        	fi
	
		done < "${sequences_input}"

# If the file is empty a warning is echoed and the script is exited

	else
		echo -e "\n[FAILURE] File ${sequences_input} not found. Exiting the script...\n"
		
		return
	fi
	
	echo -e "\n------------------------------------------------------------------------------------------------"
	echo -e "\n[INFO] All sequences have been successfully loaded from ${sequences_input}.\n"
	echo -e "------------------------------------------------------------------------------------------------\n"
	
# Since we established that the script is going to run, we delete the previous runs data

	rm -f ./Ensembl.txt # comment -f
	rm -f ./Uniprot.txt
	rm -f ./NCBI.txt
	
# This is a variable that holds the input file	

	sequence_file="./${sequences_input}"
		
	touch Ensembl.txt

# This is the start of the Ensembl information extraction process

	echo -e "\n============================================================="
	echo -e "Starting Data Extraction from the ENSEMBL Database"
	echo -e "=============================================================\n"
	
# The while loop takes the stable id's from the input file and extracts
# information for each one of them and then inputs it in the Ensembl.txt

	while read sequence_names 
	do

		echo -e "\n[INFO] Processing sequence ID: ${sequence_names}"
		echo -e "\nQuerying ENSEMBL API for ${sequence_names} data..."

# The wget command requests from the Ensembl rest API information based on the 
# stable id's, from the code database of Ensembl and outputted on a text file 
# named with a stable id

		wget -q --header="Content-type:text" "https://rest.ensembl.org/lookup/id/${sequence_names}?db_type=core;format=full"  -O - > ${sequence_names}.txt
		
# If that text file is not empty, then we remove the information that is not 
# needed + the header line with grep and then output the information with tabs on 
# one line into Ensembl.txt

		if [ -s ${sequence_names}.txt ]
		then
			cat ${sequence_names}.txt | grep -v "assembly_name" | grep -v "db_type" | grep  -v "object_type" | grep -v "source" | grep -v "version" | grep -v "logic_name" | grep -v "canonical_transcript" | grep -v "<" | grep -v "description" | awk 'BEGIN{FS=":";}{ORS="\t";}{print $2}' >> Ensembl.txt
		       	
# I am inputting an empty line every instance of the while loop because awk for 
# some reason is outputting everything on one line rather at the next line like 
# it's supposed too

			echo "" >> Ensembl.txt
		       
			echo -e "\n[SUCCESS] Data extracted for ${sequence_names}. Saving to Ensembl.txt."
			echo -e "\n------------------------------------------------------------------------------------------------"

# We delete the previous text files to have our folder more clean

			rm -f ./${sequence_names}.txt
			continue
		
# If that text file is empty then we just echo a warning and continue the script

		else
			echo -e "\n[WARNING] No data found for sequence ID: ${sequence_names}. Skipping..."
			echo -e "\n------------------------------------------------------------------------------------------------"
			rm -f ./${sequence_names}.txt
			continue
		fi

		
	done < "${sequence_file}"

# After all the stable ids have been queried, we check if our final combined text 
# file has any information 

	if [ -s Ensembl.txt ]
	then
		Ensembl_file=$(cat Ensembl.txt  | grep "ENS")
		
		echo -e "\n============================================================="
		echo -e "ENSEMBL Data Extraction Complete Successfully"
		echo -e "=============================================================\n"

# If no data has been found we exit the script since the whole script is based on 
# finding data based on Ensembl 

	else
		echo -e "\n============================================================="
		echo -e "No ENSEMBL Data Extracted. Exiting the Script..."
		echo -e "=============================================================\n"
		return
	fi

# Here is the start of the Uniprot information extraction process

	echo -e "\n============================================================="
	echo -e " Starting Data Extraction from the UNIPROT Database"
	echo -e "=============================================================\n"
	
# Creation of the text file where all the data are going to be inserted 

	touch Uniprot.txt

# This while loop reads the Ensembl text file and assigns a variable to each 
# field

	while read biotype display_name end id seq_region_name species start strand
	do
		echo -e "\n[INFO] Processing GENE ID: ${display_name}"
		echo -e "\nQuerying Uniprot API for ${display_name} data..."

# This variable holds the response of the Uniprot Rest Api based on the query 
# specified and the fields we required outputted

		Uniprot_responce=$(curl -s -H "Accept: text/plain; format=tsv" "https://rest.uniprot.org/uniprotkb/search?query=(reviewed:true)%20AND%20(gene:${display_name})%20AND%20(organism_name:${species})&fields=accession%2Cgene_primary%2Corganism_name%2Ccc_function%2Cprotein_name%2Csequence" | grep -v "Entry")	
		
# This variable holds the Http response of the Uniprot Rest Api based on the 
# query and fields required outputted

		server_response=$(curl -s -o /dev/null -w "%{http_code}" -H "Accept: text/plain; format=tsv" "https://rest.uniprot.org/uniprotkb/search?query=(reviewed:true)%20AND%20(gene:${display_name})%20AND%20(organism_name:${species})&fields=accession%2Cgene_primary%2Corganism_name%2Ccc_function%2Cprotein_name%2Csequence")
		
# This if statement checks if the server response is "200" meaning working fine 
# and if true we move to the next if statement
		
		if [[ ${server_response} -eq 200 ]]
		then

# This if statement checks if the Uniprot response is empty, if not then the 
# response is outputted into Uniprot.txt, if it is then an echo statement gives a 
# warning

			if [[ -n ${Uniprot_responce} ]]
			then
				echo -e "${Uniprot_responce}" >> Uniprot.txt
				echo -e "\n[SUCCESS] Data extracted for ${display_name}. Saving to Uniprot.txt."
				echo -e "\n------------------------------------------------------------------------------------------------"

			else
				echo -e "\n[WARNING] No data found for GENE ID: ${display_name}"
				echo -e "\n------------------------------------------------------------------------------------------------"
			fi
		
# This elif statement checks if the server response is "500", If it is then an 
# echo statement echoes that there is an internal error

		elif [[ ${server_response} -eq 500 ]]
		then
			echo "\n[WARNING] Server internal error, try re-running the script or try re-running it at different time"

# This else statement just sends an echo saying that there is an error code

		else
			echo -e "\n[WARNING]: Received HTTP status code ${server_response}"
		fi

		
	done <<< ${Ensembl_file}
	
	echo -e "\n============================================================="
	echo -e "Uniprot Data Extraction Complete"
	echo -e "=============================================================\n"

# Here is the start of the NCBI information extraction process

	echo -e "\n============================================================="
	echo -e "Starting Data Extraction from the NCBI Database"
	echo -e "=============================================================\n"
	
# Creation of NCBI output text file

	touch NCBI.txt

# This while loop reads the Ensembl text file and assigns a variable to each 
# field

	while read biotype display_name end id seq_region_name species start strand
	do
		echo -e "\n[INFO] Processing GENE ID: ${display_name} and ORGANISM: ${species}"
		echo -e "\nQuerying NCBI API for ${display_name} and ${species} data..."

# This code is utilising the E-utilities Api from NCBI to search the Gene 
# database based on a specific query, subsequently the data are fetched into an 
# xml format and then using xtract the fields that you want to be specified are 
# extracted into NCBI.txt in a tabular form.

		esearch -db Gene -query "${display_name}[GENE] AND ${species}[ORGANISM]" < /dev/null | efetch -format xml | xtract -pattern Entrezgene -element Gene-ref_locus -block Entrezgene_summary -element Entrezgene_summary >> NCBI.txt 
			
# The use of < /dev/null is necessary because without it the xtract stops 
# interacting with the while loop	
	
		echo -e "\n[SUCCESS] Data extracted for ${display_name} and ${species}. Saving to NCBI.txt."
		echo -e "\n------------------------------------------------------------------------------------------------"


	done <<< "${Ensembl_file}"

	echo -e "\n============================================================="
	echo -e "NCBI Data Extraction Complete"
	echo -e "=============================================================\n"

# Here is the start of the MySQL Database

	echo -e "\n============================================================="
	echo -e "Starting Creation of MySQL Database"
	echo -e "=============================================================\n"
	
	echo -e "\n[INFO] Preparing to create MySQL database and tables..."
	echo -e "\n[INFO] Please ensure your MySQL credentials are correct.\n"

# Here we ask the user for what username and password to use
# The “-s” silences the user input thus, protecting the integrity of the database

	read -p $'What is your MySQL username: ' mysql_username

	read -s -p $'\nWhat is your password: ' mysql_password

	read -p $'\nWhat would you like to name your database: '	n_database
# Here the code makes sure the database is clear and that it exists
	
    	echo "DROP DATABASE ${n_database}; CREATE DATABASE ${n_database};" | mysql -u${mysql_username} -p${mysql_password}

# Here, the creation of the ENSEMBL table begins. The columns are named, and the 
# data types are specified. Furthermore, the file containing the information is 
# loaded into the tables created, with the field separators specified.

	echo -e "\n-------------------------------------------------------------------------------------------------\n"
	echo -e "[INFO] Creating table: ENSEMBL"
	echo -e "\n[INFO] Loading data into ENSEMBL table from Ensembl.txt.\n"
	
	echo "DROP TABLE IF EXISTS ENSEMBL; CREATE TABLE ENSEMBL (biotype VARCHAR(20), display_name VARCHAR(50), end INT, id VARCHAR(50) PRIMARY KEY, seq_region_name VARCHAR(10), species VARCHAR(50), start INT, strand TINYINT); LOAD DATA LOCAL INFILE './Ensembl.txt' INTO TABLE ENSEMBL FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';" | mysql ${n_database} -u${mysql_username} -p${mysql_password}

	
# Here, the creation of the NCBI table begins. The columns are named, and the 
# data types are specified. Furthermore, the file containing the information is 
# loaded into the tables created, with the field separators specified.

	echo -e "\n-------------------------------------------------------------------------------------------------\n"
	echo -e "[INFO] Creating table: NCBI"
	echo -e "\n[INFO] Loading data into NCBI table from NCBI.txt.\n"
	
	echo "DROP TABLE IF EXISTS NCBI; CREATE TABLE NCBI (symbol VARCHAR(50), Gene_description TEXT, PRIMARY KEY (symbol)); LOAD DATA LOCAL INFILE './NCBI.txt' INTO TABLE NCBI FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';" | mysql ${n_database} -u${mysql_username} -p${mysql_password}
	
# Here, the creation of the Uniprot table begins. The columns are named, and the 
# data types are specified. Furthermore, the file containing the information is 
# loaded into the tables created, with the field separators specified.

	echo -e "\n-------------------------------------------------------------------------------------------------\n"
	echo -e "[INFO] Creating table: Uniprot"
	echo -e "\n[INFO] Loading data into Uniprot table from Uniprot.txt.\n"
	
	echo "DROP TABLE IF EXISTS UNIPROT; CREATE TABLE UNIPROT (accession VARCHAR(20), gene_primary VARCHAR(100), organism_name VARCHAR(100), cc_function TEXT, Protein_Name TEXT, sequence TEXT, PRIMARY KEY (accession)); LOAD DATA LOCAL INFILE './Uniprot.txt' INTO TABLE UNIPROT FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';" | mysql ${n_database} -u${mysql_username} -p${mysql_password} 
	
	echo -e "\n-------------------------------------------------------------------------------------------------\n"
	echo -e "[SUCCESS] All database tables have been successfully created and populated."

# Here, we display the combined view of all the data extracted, with a slightly 
# shortened version in a vertical view.

    	echo -e "\n-------------------------------------------------------------------------------------------------\n"
	echo -e "[INFO] Generating final combined view of extracted data..."
	echo -e "\n[INFO] Displaying a shortened version below for easier reading.\n"

	echo -e "SELECT ENSEMBL.*, SUBSTRING(NCBI.Gene_description, 1, 600) AS Gene_description, SUBSTRING(UNIPROT.accession, 1, 10) AS accession, SUBSTRING(UNIPROT.cc_function, 1, 1000) AS cc_function, SUBSTRING(UNIPROT.Protein_Name, 1, 200) AS Protein_Name, SUBSTRING(UNIPROT.sequence, 1, 100) AS sequence FROM ENSEMBL LEFT JOIN NCBI ON TRIM(ENSEMBL.display_name) = TRIM(NCBI.symbol) LEFT JOIN UNIPROT ON TRIM(ENSEMBL.display_name) = TRIM(UNIPROT.gene_primary) \G"| mysql ${n_database} -u${mysql_username} -p${mysql_password}

# Outputting the table in a tsv so when imported in excel it looks better than a 
# csv

        echo -e "\n-------------------------------------------------------------------------------------------------\n"
	echo -e "SELECT ENSEMBL.*, NCBI.Gene_description, UNIPROT.accession, UNIPROT.cc_function, UNIPROT.Protein_Name, UNIPROT.sequence FROM ENSEMBL LEFT JOIN NCBI ON TRIM(ENSEMBL.display_name) = TRIM(NCBI.symbol) LEFT JOIN UNIPROT ON TRIM(ENSEMBL.display_name) = TRIM(UNIPROT.gene_primary)" | mysql ${n_database} -u${mysql_username} -p${mysql_password} > FINAL.tsv
    
	echo -e "\n[INFO] Final data output created: FINAL.tsv"
	echo -e "\nYou can view the full dataset in this file."

	echo -e "\n============================================================="
	echo -e "Thank you for using DatabaseMaker2025!\n"
	echo -e "Script execution complete. Have a great day!"
	echo -e "=============================================================\n"
else
	echo -e"\nExiting Script...\n"
fi


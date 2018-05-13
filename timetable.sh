#!/bin/bash

#Installs xmllint
sudo apt-get install libxml2-utils --force-yes
printf "\n \n"
echo "Checked for xmllint. Now proceeding..........."
echo "#######################################################"
echo "Curls will take a few seconds. Do not kill the process."


input="units.txt"
while read -r var
do
	printf "\n"
	echo 'Now showing for: '$var
	printf "\n \n"

	#saves the grabbed page as output.html for extraction.
	curl -s -d "p_unit_cd=$var&p_ci_year=$1&cmdSubmit=Search" http://apps.wcms.ecu.edu.au/semester-timetable/lookup \
	-o "output.html"

	
	if [ "$var" != "csg6206" ]
	then

	#specific fields grabbed and stored in variables to be used to populate database tables later on.
		unit_code=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[1]/text()" output.html`)

		unit_sem=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[2]/text()" output.html`)

		unit_name=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[3]/text()" output.html`)

		unit_mode_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[5]/text()" output.html`)

		unit_mode_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[5]/text()" output.html`)

		unit_quota_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[6]/text()" output.html`)

		unit_quota_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[6]/text()" output.html`)

		unit_campus_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[4]/text()" output.html`)

		unit_campus_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[4]/text()" output.html`)


	#-----------------------------------------------------------------------------#

		#population of main view tables for csi3208 and csi3207 because of the same main html page structure.		

		sqlite timetable.db "create table '$var+main'(unit_code text, unit_name text, sem text, mode text, quota text, campus text, primary key(unit_code,mode))"
		sqlite timetable.db "insert into '$var+main' values ('$unit_code','$unit_name','$unit_sem','$unit_mode_1','$unit_quota_1','$unit_campus_1')"
		sqlite timetable.db "insert into '$var+main' values ('$unit_code','$unit_name','$unit_sem','$unit_mode_2','$unit_quota_2','$unit_campus_2')"
		
		sqlite -column -header timetable.db "select * from '$var+main'"

		printf "\n \n"

	#-----------------------------------------------------------------------------#
		#grabbing the activities page. The code works for both csi3207 and csi 3208 because of their same main page structure. 
		#saving the grabbed page to activities.html for further extraction.

		unit_link=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[7]/a/@href" output.html\
		| sed 's/href="//g'`)
		curl -s $unit_link -o activities.html

		#grabbing specific fields from activities and saving them in variables for further extraction.	

		#-------------------------------------------------------------------------------------------------------------------------------#
		#The 2 > /dev/null is done because of the error/warning thrown by xmllint since it wasn't agreeing to the 
		#way the web page is coded. The error being \\\element div: validity error : ID hwrapper1 already defined
		#<div id = "hwrapper1">\\\ 
		#Apparently, in the webpage SOURCE CODE (apps.wcms.ecu.edu.au SOURCE CODE), "hwrapper1" is used more than once to identify different <div> elements.
		#This is a parser error and not causing any problems in the extraction fo the data fromt he page because 
		#of the relative --xpath used. 
		#-------------------------------------------------------------------------------------------------------------------------------#

		activity_1_name=$(echo `xmllint --html --xpath "//tr[1]/th[1]/strong/text()" activities.html 2> /dev/null`)

		activity_1_ID_1=$(echo `xmllint --html --xpath "//tr[3]/td[1]/text()" activities.html 2> /dev/null`)

		activity_1_ID_1_day=$(echo `xmllint --html --xpath "//tr[3]/td[2]/text()" activities.html 2> /dev/null`)

		activity_1_ID_1_time=$(echo `xmllint --html --xpath "//tr[3]/td[3]/text()" activities.html 2> /dev/null`)

		activity_1_ID_1_location=$(echo `xmllint --html --xpath "//tr[3]/td[4]/a/text()" activities.html 2> /dev/null`)

		activity_1_ID_1_allocated_places=$(echo `xmllint --html --xpath "//tr[3]/td[5]/text()" activities.html 2> /dev/null`)

	#--------------------------------------------------------------------#

	#creating tables for the lecture actvity. This piece of code works for both 
	#csi3207 and csi3208 because of the same lecture table(html table) structure.

		sqlite timetable.db "create table '$var+activity_1'(activity_id text primary key, activity_sem text, activity_name text, activity_day text, 
							activity_time text, activity_location text, activity_allocated_places text)"
		sqlite timetable.db "insert into '$var+activity_1' values ('$activity_1_ID_1','$unit_sem','$activity_1_name','$activity_1_ID_1_day',
							'$activity_1_ID_1_time','$activity_1_ID_1_location','$activity_1_ID_1_allocated_places')"
		
		sqlite -column -header timetable.db "select * from '$var+activity_1'"

		printf "\n \n"
	#--------------------------------------------------------------------#

		if [ "$var" == "csi3207" ]
		then

			#activity 2 ie lab table is different in terms of html page structure for all the three units. 
			#hence it was better to extract those parts separately and then populate the separate tables. 
			activity_2_name=$(echo `xmllint --html --xpath "//tr[5]/th[1]/strong/text()" activities.html 2> /dev/null`)

			activity_2_ID_1=$(echo `xmllint --html --xpath "//tr[7]/td[1]/text()" activities.html 2> /dev/null`)

			activity_2_ID_1_day=$(echo `xmllint --html --xpath "//tr[7]/td[2]/text()" activities.html 2> /dev/null`)

			activity_2_ID_1_time=$(echo `xmllint --html --xpath "//tr[7]/td[3]/text()" activities.html 2> /dev/null`)

			activity_2_ID_1_location=$(echo `xmllint --html --xpath "//tr[7]/td[4]/a/text()" activities.html 2> /dev/null`)

			activity_2_ID_1_allocated_places=$(echo `xmllint --html --xpath "//tr[7]/td[5]/text()" activities.html 2> /dev/null`)

			activity_2_ID_2=$(echo `xmllint --html --xpath "//tr[8]/td[1]/text()" activities.html 2> /dev/null`)

			activity_2_ID_2_day=$(echo `xmllint --html --xpath "//tr[8]/td[2]/text()" activities.html 2> /dev/null`)

			activity_2_ID_2_time=$(echo `xmllint --html --xpath "//tr[8]/td[3]/text()" activities.html 2> /dev/null`)

			activity_2_ID_2_location=$(echo `xmllint --html --xpath "//tr[8]/td[4]/a/text()" activities.html 2> /dev/null`)

			activity_2_ID_2_allocated_places=$(echo `xmllint --html --xpath "//tr[8]/td[5]/text()" activities.html 2> /dev/null`)

			sqlite timetable.db "create table '$var+activity_2'(activity_id text primary key, activity_sem text, activity_name text, activity_day text, 
							activity_time text, activity_location text, activity_allocated_places text)"

			sqlite timetable.db "insert into '$var+activity_2' values ('$activity_2_ID_1','$unit_sem','$activity_2_name','$activity_2_ID_1_day',
							'$activity_2_ID_1_time','$activity_2_ID_1_location','$activity_2_ID_1_allocated_places')"

			sqlite timetable.db "insert into '$var+activity_2' values ('$activity_2_ID_2','$unit_sem','$activity_2_name','$activity_2_ID_2_day',
							'$activity_2_ID_2_time','$activity_2_ID_2_location','$activity_2_ID_2_allocated_places')"

			sqlite -column -header timetable.db "select * from '$var+activity_2'" 

			printf "\n \n"


		elif [ "$var" == "csi3208" ]
		then
			#activity 2 ie lab table is different in terms of html page structure for all the three units. 
			#hence it was better to extract those parts separately and then populate the separate tables. 

			activity_2_name=$(echo `xmllint --html --xpath "//tr[4]/th[1]/strong/text()" activities.html 2> /dev/null`)

			activity_2_ID_1=$(echo `xmllint --html --xpath "//tr[6]/td[1]/text()" activities.html 2> /dev/null`)

			activity_2_ID_1_day=$(echo `xmllint --html --xpath "//tr[6]/td[2]/text()" activities.html 2> /dev/null`)

			activity_2_ID_1_time=$(echo `xmllint --html --xpath "//tr[6]/td[3]/text()" activities.html 2> /dev/null`)

			activity_2_ID_1_location=$(echo `xmllint --html --xpath "//tr[6]/td[4]/a/text()" activities.html 2> /dev/null`)

			activity_2_ID_1_allocated_places=$(echo `xmllint --html --xpath "//tr[6]/td[5]/text()" activities.html 2> /dev/null`)

			activity_2_ID_2=$(echo `xmllint --html --xpath "//tr[7]/td[1]/text()" activities.html 2> /dev/null`)

			activity_2_ID_2_day=$(echo `xmllint --html --xpath "//tr[7]/td[2]/text()" activities.html 2> /dev/null`)

			activity_2_ID_2_time=$(echo `xmllint --html --xpath "//tr[7]/td[3]/text()" activities.html 2> /dev/null`)

			activity_2_ID_2_location=$(echo `xmllint --html --xpath "//tr[7]/td[4]/a/text()" activities.html 2> /dev/null`)

			activity_2_ID_2_allocated_places=$(echo `xmllint --html --xpath "//tr[7]/td[5]/text()" activities.html 2> /dev/null`)

			sqlite timetable.db "create table '$var+activity_2'(activity_id text primary key, activity_sem text, activity_name text, activity_day text, 
							activity_time text, activity_location text, activity_allocated_places text)"

			sqlite timetable.db "insert into '$var+activity_2' values ('$activity_2_ID_1','$unit_sem','$activity_2_name','$activity_2_ID_1_day',
							'$activity_2_ID_1_time','$activity_2_ID_1_location','$activity_2_ID_1_allocated_places')"

			sqlite timetable.db "insert into '$var+activity_2' values ('$activity_2_ID_2','$unit_sem','$activity_2_name','$activity_2_ID_2_day',
							'$activity_2_ID_2_time','$activity_2_ID_2_location','$activity_2_ID_2_allocated_places')"

			sqlite -column -header timetable.db "select * from '$var+activity_2'"

			printf "\n \n"

		fi


	elif [ "$var" == "csg6206" ]
	then
		#html page structure for csg6206 is different from the other two units.
		#Therefore, it was necessary to make a separate block of code for csg6206.

		unit_code=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[1]/text()" output.html`)

		unit_sem_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[4]/td[2]/text()" output.html`)

		unit_name=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[3]/text()" output.html`)

		unit_sem_1_campus_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[4]/td[4]/text()" output.html`)

		unit_sem_1_campus_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[3]/td[4]/text()" output.html`)

		unit_sem_2_campus_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[4]/text()" output.html`)

		unit_sem_2_campus_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[4]/text()" output.html`)

		unit_sem_1_mode_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[4]/td[5]/text()" output.html`)

		unit_sem_1_mode_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[3]/td[5]/text()" output.html`)

		unit_sem_2_mode_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[5]/text()" output.html`)

		unit_sem_2_quota_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[2]/td[6]/text()" output.html`)

		unit_sem_2_mode_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[5]/text()" output.html`)

		unit_sem_2_quota_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[6]/text()" output.html`)

		unit_sem_1_quota_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[4]/td[6]/text()" output.html`)

		unit_sem_1_quota_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[3]/td[6]/text()" output.html`)
		
		unit_sem_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[2]/text()" output.html`)

	#-----------------------------------------------------------------------------#
		sqlite timetable.db "create table '$var+main'(unit_code text, unit_name text, sem text, mode text, quota text, campus text, primary key(unit_code, sem, mode))"
		sqlite timetable.db "insert into '$var+main' values ('$unit_code','$unit_name','$unit_sem_1','$unit_sem_1_mode_2','$unit_sem_1_quota_2','$unit_sem_1_campus_2')"
		sqlite timetable.db "insert into '$var+main' values ('$unit_code','$unit_name','$unit_sem_1','$unit_sem_1_mode_1','$unit_sem_1_quota_1','$unit_sem_1_campus_1')"
		sqlite timetable.db "insert into '$var+main' values ('$unit_code','$unit_name','$unit_sem_2','$unit_sem_2_mode_2','$unit_sem_2_quota_2','$unit_sem_2_campus_2')"
		sqlite timetable.db "insert into '$var+main' values ('$unit_code','$unit_name','$unit_sem_2','$unit_sem_2_mode_1','$unit_sem_2_quota_1','$unit_sem_2_campus_1')"
		sqlite -column -header timetable.db "select * from '$var+main'"

		printf "\n \n"
	#-----------------------------------------------------------------------------#

		#the main page has 2 Activities links. Both of them are grabbed one by one and the content extracted
		#and collated + populated in tables

		#activity link 2
		
		activity_link_2=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[1]/td[7]/a/@href" output.html\
		| sed 's/href="//g'`)

		curl -s $activity_link_2 -o activities.html

		activity_1_sem_2_name=$(echo `xmllint --html --xpath "//tr[2]/th[1]/strong/text()" activities.html 2> /dev/null`)

		activity_1_sem_2_ID_1=$(echo `xmllint --html --xpath "//tr[4]/td[1]/text()" activities.html 2> /dev/null`)

		activity_1_sem_2_ID_1_day=$(echo `xmllint --html --xpath "//tr[4]/td[2]/text()" activities.html 2> /dev/null`)

		activity_1_sem_2_ID_1_time=$(echo `xmllint --html --xpath "//tr[4]/td[3]/text()" activities.html 2> /dev/null`)

		activity_1_sem_2_ID_1_location=$(echo `xmllint --html --xpath "//tr[4]/td[4]/a/text()" activities.html 2> /dev/null`)

		activity_1_sem_2_ID_1_allocated_places=$(echo `xmllint --html --xpath "//tr[4]/td[5]/text()" activities.html 2> /dev/null`)

		activity_2_sem_2_name=$(echo `xmllint --html --xpath "//tr[5]/th[1]/strong/text()" activities.html 2> /dev/null`)

		activity_2_sem_2_ID_1=$(echo `xmllint --html --xpath "//tr[7]/td[1]/text()" activities.html 2> /dev/null`)

		activity_2_sem_2_ID_1_day=$(echo `xmllint --html --xpath "//tr[7]/td[2]/text()" activities.html 2> /dev/null`)

		activity_2_sem_2_ID_1_time=$(echo `xmllint --html --xpath "//tr[7]/td[3]/text()" activities.html 2> /dev/null`)

		activity_2_sem_2_ID_1_location=$(echo `xmllint --html --xpath "//tr[7]/td[4]/a/text()" activities.html 2> /dev/null`)

		activity_2_sem_2_ID_1_allocated_places=$(echo `xmllint --html --xpath "//tr[7]/td[5]/text()" activities.html 2> /dev/null`)

		#---------------------------------------------------------------------------#
		
		#activity link 1

		activity_link_1=$(echo `xmllint --html --xpath "//table[@class='styledTable']//tr[3]/td[7]/a/@href" output.html\
		| sed 's/href="//g'`)

		curl -s $activity_link_1 -o activities.html

		activity_1_sem_1_name=$(echo `xmllint --html --xpath "//tr[2]/th[1]/strong/text()" activities.html 2> /dev/null`)

		activity_1_sem_1_ID_1=$(echo `xmllint --html --xpath "//tr[4]/td[1]/text()" activities.html 2> /dev/null`)

		activity_1_sem_1_ID_1_day=$(echo `xmllint --html --xpath "//tr[4]/td[2]/text()" activities.html 2> /dev/null`)

		activity_1_sem_1_ID_1_time=$(echo `xmllint --html --xpath "//tr[4]/td[3]/text()" activities.html 2> /dev/null`)

		activity_1_sem_1_ID_1_location=$(echo `xmllint --html --xpath "//tr[4]/td[4]/a/text()" activities.html 2> /dev/null`)

		activity_1_sem_1_ID_1_allocated_places=$(echo `xmllint --html --xpath "//tr[4]/td[5]/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_name=$(echo `xmllint --html --xpath "//tr[5]/th[1]/strong/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_1=$(echo `xmllint --html --xpath "//tr[7]/td[1]/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_1_day=$(echo `xmllint --html --xpath "//tr[7]/td[2]/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_1_time=$(echo `xmllint --html --xpath "//tr[7]/td[3]/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_1_location=$(echo `xmllint --html --xpath "//tr[7]/td[4]/a/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_1_allocated_places=$(echo `xmllint --html --xpath "//tr[7]/td[5]/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_2=$(echo `xmllint --html --xpath "//tr[8]/td[1]/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_2_day=$(echo `xmllint --html --xpath "//tr[8]/td[2]/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_2_time=$(echo `xmllint --html --xpath "//tr[8]/td[3]/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_2_location=$(echo `xmllint --html --xpath "//tr[8]/td[4]/a/text()" activities.html 2> /dev/null`)

		activity_2_sem_1_ID_2_allocated_places=$(echo `xmllint --html --xpath "//tr[8]/td[5]/text()" activities.html 2> /dev/null`)


#-------------------------------------------------------------------#
		#populating the lecture activity from both the semesters in one table

		sqlite timetable.db "create table '$var+activity_1'(activity_id text primary key, activity_name text, activity_sem text, activity_day text, 
							activity_time text, activity_location text, activity_allocated_places text)"
		
		sqlite timetable.db "insert into '$var+activity_1' values ('$activity_1_sem_1_ID_1','$activity_1_sem_1_name','$unit_sem_1','$activity_1_sem_1_ID_1_day',
							'$activity_1_sem_1_ID_1_time','$activity_1_sem_1_ID_1_location','$activity_1_sem_1_ID_1_allocated_places')"

		sqlite timetable.db "insert into '$var+activity_1' values ('$activity_1_sem_2_ID_1','$activity_1_sem_2_name','$unit_sem_2','$activity_1_sem_2_ID_1_day',
							'$activity_1_sem_2_ID_1_time','$activity_1_sem_2_ID_1_location','$activity_1_sem_2_ID_1_allocated_places')"
		
		sqlite -column -header timetable.db "select * from '$var+activity_1'"

		printf "\n \n"
#-------------------------------------------------------------------#

		#Populating the lab activity from both the semesters in one table

		sqlite timetable.db "create table '$var+activity_2'(activity_id text primary key, activity_name text, activity_sem text, activity_day text, 
							activity_time text, activity_location text, activity_allocated_places text)"
		
		sqlite timetable.db "insert into '$var+activity_2' values ('$activity_2_sem_1_ID_1','$activity_2_sem_1_name','$unit_sem_1','$activity_2_sem_1_ID_1_day',
							'$activity_2_sem_1_ID_1_time','$activity_2_sem_1_ID_1_location','$activity_2_sem_1_ID_1_allocated_places')"

		sqlite timetable.db "insert into '$var+activity_2' values ('$activity_2_sem_1_ID_2','$activity_2_sem_1_name','$unit_sem_1','$activity_2_sem_1_ID_2_day',
							'$activity_2_sem_1_ID_2_time','$activity_2_sem_1_ID_2_location','$activity_2_sem_1_ID_2_allocated_places')"

		sqlite timetable.db "insert into '$var+activity_2' values ('$activity_2_sem_2_ID_1','$activity_2_sem_2_name','$unit_sem_2','$activity_2_sem_2_ID_1_day',
							'$activity_2_sem_2_ID_1_time','$activity_2_sem_2_ID_1_location','$activity_2_sem_2_ID_1_allocated_places')"
		
		sqlite -column -header timetable.db "select * from '$var+activity_2'"

		printf "\n \n"
#-------------------------------------------------------------------#

	fi

done < "$input"

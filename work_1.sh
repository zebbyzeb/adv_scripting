#!/bin/bash

#Student Name: Yash Karan Singh
#Student Number : 10445116


if [ "$1" == "" ]			#if no positional argument given
then

	printf "Present Working Directory is: %s \n \n" `pwd`

	count=$(git rev-list --all --count)

	
	printf "Total Number of Commits: %d\n\n" $count
	
	echo "Author of the recent commit: "
	git log -1 --pretty=format:'%an'
	printf "\n"
	echo "Comments: "
	git log -1 --pretty=format:'%s'
	printf "\n"
	
	exit 0
else

	cd $1					#place the script in some other folder and
						#give the path of the form /home/jeff/wherever_the_workshop_folder_is
	echo `pwd`

	count=$(git rev-list --all --count)

	
	printf "Total Number of Commits: %d\n\n" $count
	
	echo "Author of the recent commit: "
	git log -1 --pretty=format:'%an'
	printf "\n"
	echo "Comments: "
	git log -1 --pretty=format:'%s'
	printf "\n"

	
fi


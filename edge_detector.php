<?php
//How To Run The Script
//eg. cat input.txt | php assign_3_task_2.php


// Types of input strings accepted include > strings containing only 0s and 1s. 
//										   > whitespaces on either ends of the string.
// 										   > newlines/emptylines in between the strings.



	$old = array(); #initialising an array to hold the input strings
					#from the file supplied through stdin.

	$f = fopen('php://stdin', 'r');

	while( $line = fgets( $f ) ) {

		array_push($old,$line);#pushing the lines, fetched by fgets, into the array $old.
	}
	fclose( $f );

	#echoing the strings on the terminal, as per the specifications.
	echo "Input:";
	for($i=0;$i<count($old);$i++){
		echo "\t\t".$old[$i];
	}

	#initialising a $new array to take the trimmed and 'new line' removed strings.
	$new = array();
	for($i=0;$i<count($old);$i++){
		
		$old[$i]=trim($old[$i]); #trims the whitespaces from the either ends of the string.
		if(($old[$i])!=NULL){	 #this ensures that if the input file has newlines in it,
								 #it will not push those newlines in the $new array
								 #thereby, making the input consistent.
			array_push($new,$old[$i]);
		}

	}
	#echo count($new);


	$digit_count = strlen($new[0]); #takes the length of the first string to compare it with other string lengths.
	#echo $digit_count;


	for($i=0;$i<count($new);$i++){
		if($i!=0 && strlen($new[$i])!=$digit_count){ #since the length of the first string is store in $digit_count,
													 #no point comparing first string length with digit count.
													 #Instead, it checks if the string is anyone other than the first string,
													 #and its length is not equal to the $digit_count, it ends the script.
			die("Irregular Length Input");
		}											 #if the string is the first string or any other string whose length is 
													 #same as the first string, it checks if each character in the string is 
													 #'0' or '1' and continues. Otherwise, it ends the script.
		for($j=0;$j<strlen($new[$i]);$j++){
			if($new[$i][$j]=="1" || $new[$i][$j]=="0"){
				continue;
			}
			else{									#the checks are in the order of the string being checked. 
													#say, if a string '12345' is encountered before a string whose length is not the same as others,
													#the script will give the error "non binary input" and terminate.
				die("Non-Binary Input.");
			}
		}
	}

	
	#edge detection starts after the above checks have been performed. 
	echo "\n";
	echo "Output:\t\t";
	for($i=0;$i<count($new);$i++){
		
		
		for($j=0;$j<strlen($new[$i]);$j++){
			if($i==0 && $j==0){					#the leftmost character of the first string will always be 0 by logic. 
				echo "0";
			}
			elseif($i==0 && $j!=0){				#the characters(other than the first character) in the first string
												#is to be checked with the character to its left.
				if($new[$i][$j]!=$new[$i][$j-1]){
					echo "1";
				}
				else{
					echo "0";
				}
			}
			elseif($i!=0 && $j==0){				#character not in the first string but in the first column of other strings
												#is to be checked with the character above it.
				if($new[$i][$j]!=$new[$i-1][$j]){
					echo "1";
				}
				else{
					echo "0";
				}
			}
			else{								#this is for all the other cases where the character will be checked,first, against the
												#character above it and then to the left of it.
				if($new[$i][$j]!=$new[$i-1][$j] || $new[$i][$j]!=$new[$i][$j-1]){
					echo "1";
				}
				else{
					echo "0";
				}
			}
		}
		echo "\n";
		echo "\t\t";
	}
	

?>
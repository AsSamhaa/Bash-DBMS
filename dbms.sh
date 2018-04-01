# echo Default location for databases is \~/Desktop/DB
# for name in `ls ~/Desktop/DB`; do
# 	# echo $name
# 	db[i]=$name
# 	let i++
# done
# echo ${db[*]}

# -------------------------------functions section--------------------------------------
# 				$1			$2			$3
# match-data	$input		$file 		$column
function match_data {
	datatype=$(head -1 $2 | cut -d ':' -f$3 | awk -F "-" 'BEGIN { RS = ":" } {print $2}')
	if [[ "$1" = '' ]]; then
		echo 0
	elif [[ "$1" = -?(0) ]]; then
		echo 1 # error!
	elif [[ "$1" = ?(-)+([0-9])?(.)*([0-9]) ]]; then
		if [[ $datatype == integer ]]; then
			# datatype integer and the input is integer
			echo 0
		else
			# datatype string and input is number
			echo 0
		fi
	else
		if [[ $datatype == integer ]]; then
			# datatype integer and input is not
			echo 1 # error!
		else
			# datatype string and input is string
			echo 0
		fi
	fi
}
function match_size {
	datasize=$(head -1 $2 | cut -d ':' -f$3 | awk -F "-" 'BEGIN { RS = ":" } {print $3}')
	if [[ "${#1}" -le $datasize ]]; then
		echo 0
	else
		echo 1 # error
	fi
}

# -------------------------------------code---------------------------------------------
flag1=true
flag2=true
flag3=true
while true; do
	while $flag1; do
		flag2=true
		flag3=true
		clear
		select choice in "Choose default location ~/Desktop/DB" "Choose custom location" "Exit"; do
			case "$REPLY" in
				1 )
					mkdir -p ~/Desktop/DB
					cd ~/Desktop/DB
					location="~/Desktop/DB"
					location="$location"
					flag1=false
					echo default location loaded successfully
					echo ----------------------------------------------------------------------------------
					echo press any key
					read
					;;
				2 )
					flag11=true
					while $flag11; do
						echo enter the location to store this database
						read location
						eval location="$location"
						if [[ "$location" = "" ]]; then
							echo invalid entry
						elif [[ -d "$location" && -O "$location" && -r "$location" && -w "$location" && -x "$location" ]]; then
							location="$location/DB"
							mkdir -p "$location"
							cd "$location"
							flag11=false
						else
							echo can\'t access this location
							echo press any key
							read
						fi
					done
					flag1=false
					echo press any key
					read
					;;
				3 )
					exit
					;;
				* )
					echo invalid entry
					echo press any key
					read
					;;
			esac
			break
		done 
	done
	while $flag2; do
		clear
		echo databases:$'\n'$(find . -maxdepth 1 -type d | cut -d'/' -f2 | sed '1d')
		echo ------------------------------------------------------------------------------
		select choice in "Create a database" "Use existing" "Back"; do 
		case "$REPLY" in
			1 ) # Create a database
				flag21=true
				while $flag21; do
					echo enter the name of the database please
					read dbname
					if [[ "$location/$dbname" = "$location/" ]]; then
						echo invalid entry
						flag21=false
						echo press any key
						read
					elif [[ -e "$location/$dbname" ]]; then
						echo this name already used # color this
						flag21=false
						echo press any key
						read
					else
						eval mkdir -p "$location/$dbname"
						eval cd "$location/$dbname" > /dev/null 2>&1
						eval newloc="$location/$dbname"
						if [[ "$newloc" = $(pwd) ]]; then
							echo database created in $(pwd)
							flag21=false
							flag2=false
							flag3=true
							echo press any key
							read
						else
							cd - > /dev/null 2>&1
							echo can\'t access this location
							echo press any key
							read
						fi
					fi
				done
				;;
			2 ) # Use existing
				if ! [[ $(find . -maxdepth 1 -type d | cut -d'/' -f2 | sed '1d') = '' ]]; then
					echo Databases:$'\n'$(find . -maxdepth 1 -type d | cut -d'/' -f2 | sed '1d')
					echo ------------------------------------------------------------------------------
					flag21=true
					while $flag21; do
						echo enter the name of the database
						read db
						db="$db"
						if ! [[ -d "$db" ]]; then
							echo this database doesn\'t exist # color this
							flag21=false
							echo press any key
							read
						else
							cd "$db"
							echo the database successfully loaded
							flag21=false
							flag2=false
							flag3=true
							echo press any key
							read
						fi
					done
				else
					echo there are no databases here
				fi
				;;
			3 ) # Back
				flag1=true
				flag2=false
				flag3=false
				;;
			* )
				echo wrong choice # color this
				echo press any key
				read
				;;
		esac
		break
		done
	done
	while $flag3; do
		clear
		echo Tables:$'\n'$(find . -maxdepth 1 -type f | cut -d'/' -f2)
		echo ------------------------------------------------------------------------------
		select choice in "Create table" "Delete table" "Insert into table"\
		"Delete row" "Update table" "Display row" "Display table" "Back"; do 
			case "$REPLY" in
				1 ) # create table
					echo enter the name of the table please
					read dbtable
					if [[ -e "$dbtable" ]]; then
						echo this table exists
						echo press any key
						read
						break
					fi
					touch "$dbtable"
					if [[ -f "$dbtable" ]]; then
						flag31=true
						while $flag31; do
							echo how many columns you want?
							read num_col
							if [[ "$num_col" = +([1-9])*([0-9]) ]]; then
								flag31=false
							else
								echo invalid entry
							fi
						done
						flag31=true
						while $flag31; do
							echo enter primary key name # to limit size of name
							read pk_name
							if ! [[ "$pk_name" = '' ]]; then
								echo -n "$pk_name" >> "$dbtable"
								echo -n "-" >> "$dbtable"
								flag31=false
							else
								echo invalid entry
							fi
						done
						flag31=true
						while $flag31; do
							echo enter primary key datatype
							select choice in "integer" "string"; do
								if [[ "$REPLY" = "1" || "$REPLY" = "2" ]]; then
									echo -n "$choice" >> "$dbtable"
									echo -n "-" >> "$dbtable"
									flag31=false
								else
									echo invalid choice
								fi
								break
							done
						done
						flag31=true
						while $flag31; do
							echo enter size please
							read size
							if [[ "$size" = +([1-9])*([0-9]) ]]; then
								echo -n "$size" >> "$dbtable"
								echo -n ":" >> "$dbtable"
								flag31=false
							else
								echo invalid entry
							fi
						done
						for (( i = 1; i < num_col; i++ )); do
							flag31=true
							while $flag31; do
								echo enter field $[i+1] name
								read pk_name
								if ! [[ "$pk_name" = '' ]]; then
									echo -n "$pk_name" >> "$dbtable"
									echo -n "-" >> "$dbtable"
									flag31=false
								else
									echo invalid entry
								fi
							done
							flag31=true
							while $flag31; do
								echo enter field $[i+1] datatype # to make it by select and case
								select choice in "integer" "string"; do
									if [[ "$REPLY" = "1" || "$REPLY" = "2" ]]; then
										echo -n "$choice" >> "$dbtable"
										echo -n "-" >> "$dbtable"
										flag31=false
									else
										echo invalid choice
									fi
									break
								done
							done
							flag31=true
							while $flag31; do
								echo enter field $[i+1] size please
								read size
								if [[ "$size" = +([1-9])*([0-9]) ]]; then
									echo -n "$size" >> "$dbtable"
									if [[ i -eq $num_col-1 ]]; then
										echo $'\n' >> "$dbtable"
										echo $'\n'table created successfully
										echo press any key
										read
									else 
										echo -n ":" >> "$dbtable"
									fi
									flag31=false
								else
									echo invalid entry
								fi
							done
						done
					else
						echo invalid entry$'\n'press any key
						read
					fi
					;;
				2 ) # delete table
					echo enter the name of the table to delete
					read dbtable
					if ! [[ -f "$dbtable" ]]; then
						echo this table doesn\'t exist # color this
						echo press any key
						read
					else
						rm "$dbtable"
						echo table deleted
						echo press any key
						read
					fi
					;;
				3 ) # insert into table
					echo enter the name of the table
					read dbtable
					if ! [[ -f "$dbtable" ]]; then
						echo this table doesn\'t exist # color this
						echo press any key
						read
					else
						flag31=true
						while $flag31 ; do
							echo enter primary key \"$(head -1 "$dbtable" | cut -d ':' -f1 |\
							awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable"\
							| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable"\
							| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}')

							read
							dflag=$(match_data "$REPLY" "$dbtable" 1)
							sflag=$(match_size "$REPLY" "$dbtable" 1)
							pk_uflag=$(cut -d ':' -f1 "$dbtable" | awk '{if(NR != 1) print $0}' | grep -x -e "$REPLY")

							if [[ "$REPLY" == '' ]]; then
								echo no entry
							elif [[ "$dflag" == 1 ]]; then # if primary key exist
								echo entry invalid
							elif [[ "$sflag" == 1 ]]; then
								echo entry size invalid
							elif ! [[ "$pk_uflag" == '' ]]; then
								echo this primary key already used
							else # primary key is valid
								echo -n "$REPLY" >> "$dbtable"
								echo -n ':' >> "$dbtable"
								num_col=$(head -1 "$dbtable" | awk -F: '{print NF}') # to get number of columns in table
								for (( i = 2; i <= num_col; i++ )); do
									flag311=true
									while $flag311 ; do
										echo enter \"$(head -1 $dbtable | cut -d ':' -f$i |\
										awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable" | cut -d ':' -f$i |\
										awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable" | cut -d ':' -f$i |\
										awk -F "-" 'BEGIN { RS = ":" } {print $3}')
										read
										dflag=$(match_data "$REPLY" "$dbtable" "$i")
										sflag=$(match_size "$REPLY" "$dbtable" "$i")
					
										if [[ "$dflag" == 1 ]]; then # if primary key exist
											echo entry invalid
										elif [[ "$sflag" == 1 ]]; then
											echo entry size invalid
										else # entry is valid
											if [[ i -eq $num_col ]]; then
												echo "$REPLY" >> "$dbtable"
												flag311=false
												flag31=false
												echo entry inserted successfully
											else 
												echo -n "$REPLY": >> "$dbtable"
												flag311=false
											fi
										fi
									done
								done
							fi
						done
						echo press any key
						read
					fi
					;;
				4 ) # delete row
					echo enter name of the table
					read dbtable
					if ! [[ -f "$dbtable" ]]; then
						echo this table doesn\'t exist # color this
						echo press any key
						read
					else
						echo enter primary key \"$(head -1 "$dbtable" | cut -d ':' -f1 |\
						awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable"\
						| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable"\
						| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}') of the record to delete
						read
						linenum=''
						linenum=$(cut -d ':' -f1 "$dbtable" | awk '{if(NR != 1) print $0}'\
						| grep -x -n -e "$REPLY" | cut -d':' -f1)

						if [[ "$REPLY" == '' ]]; then
							echo no entry
						elif [[ "$linenum" = '' ]]; then
							echo this primary key doesn\'t exist
						else
							let linenum=$linenum+1
							sed -i "${linenum}d" "$dbtable"
							echo row deleted
						fi
						echo press any key
						read
					fi
					;;
				5 ) # update table
					echo enter name of the table
					read dbtable
					if ! [[ -f "$dbtable" ]]; then
						echo this table doesn\'t exist # color this
						echo press any key
						read
					else
						echo enter primary key \"$(head -1 "$dbtable" | cut -d ':' -f1 |\
						awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable"\
						| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable"\
						| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}') of the record
						read
						linenum=''
						linenum=$(cut -d ':' -f1 "$dbtable" | sed '1d'\
						| grep -x -n -e "$REPLY" | cut -d':' -f1)

						if [[ "$REPLY" == '' ]]; then
							echo no entry
						elif [[ "$linenum" = '' ]]; then
							echo this primary key doesn\'t exist
						else
							let linenum=$linenum+1
							num_col=$(head -1 "$dbtable" | awk -F: '{print NF}') # to get number of columns in table
							echo other values of record:
							for (( i = 2; i <= num_col; i++ )); do
									echo \"$(head -1 $dbtable | cut -d ':' -f$i |\
									awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable" | cut -d ':' -f$i |\
									awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable" | cut -d ':' -f$i |\
									awk -F "-" 'BEGIN { RS = ":" } {print $3}'): $(sed -n "${linenum}p" "$dbtable" | cut -d: -f$i)
							done
							echo ---------------------------------------------------------------------------------
							echo fields:
							option=$(head -1 $dbtable | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}')
							echo "$option"
							flag31=true
							while $flag31; do
								echo --------------------------------------------------------------------------------
								echo enter field to update
								read
								if [[ "$REPLY" = '' ]]; then
									echo invalid entry
									echo press any key
									read
								elif [[ $(echo "$option" | grep -x "$REPLY") = "" ]]; then
									echo no such field
								else
									fieldnum=$(head -1 "$dbtable" | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}'\
									| grep -x -n "$REPLY" | cut -d: -f1)
									flag311=true
									while $flag311; do
										if [[ "$fieldnum" = 1 ]]; then
											echo enter primary key \"$(head -1 "$dbtable" | cut -d ':' -f1 |\
											awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable"\
											| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable"\
											| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}')

											read
											dflag=$(match_data "$REPLY" "$dbtable" 1)
											sflag=$(match_size "$REPLY" "$dbtable" 1)
											pk_uflag=$(cut -d ':' -f1 "$dbtable" | awk '{if(NR != 1) print $0}' | grep -x -e "$REPLY")

											if [[ "$REPLY" == '' ]]; then
												echo no entry
											elif [[ "$dflag" == 1 ]]; then # if primary key exist
												echo entry invalid
											elif [[ "$sflag" == 1 ]]; then
												echo entry size invalid
											elif ! [[ "$pk_uflag" == '' ]]; then
												echo this primary key already used
											else # primary key is valid
												awk -v fn="$fieldnum" -v rn="$linenum" -v nv="$REPLY"\
												'BEGIN { FS = OFS = ":" } { if(NR == rn)	$fn = nv } 1' "$dbtable"\
												> "$dbtable".new && rm "$dbtable" && mv "$dbtable".new "$dbtable"
												flag311=false
												flag31=false
											fi
										else
											flag311=true
											while $flag311 ; do
												echo enter \"$(head -1 $dbtable | cut -d ':' -f$fieldnum |\
												awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable" | cut -d ':' -f$fieldnum |\
												awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable" | cut -d ':' -f$fieldnum |\
												awk -F "-" 'BEGIN { RS = ":" } {print $3}')
												read
												dflag=$(match_data "$REPLY" "$dbtable" "$fieldnum")
												sflag=$(match_size "$REPLY" "$dbtable" "$fieldnum")
							
												if [[ "$dflag" == 1 ]]; then # if primary key exist
													echo entry invalid
												elif [[ "$sflag" == 1 ]]; then
													echo entry size invalid
												else # entry is valid
													awk -v fn="$fieldnum" -v rn="$linenum" -v nv="$REPLY"\
													'BEGIN { FS = OFS = ":" } { if(NR == rn)	$fn = nv } 1' "$dbtable"\
													> "$dbtable".new && rm "$dbtable" && mv "$dbtable".new "$dbtable"
													flag311=false
													flag31=false
												fi
											done
										fi
									done
								fi
							done
						fi
						echo field updated successfully
						echo press any key
						read
					fi
					;;
				6 ) # display row
					echo enter name of the table
					read dbtable
					if ! [[ -f "$dbtable" ]]; then
						echo this table doesn\'t exist # color this
						echo press any key
						read
					else
						echo enter primary key \"$(head -1 "$dbtable" | cut -d ':' -f1 |\
						awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable"\
						| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable"\
						| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}') of the record
						read
						linenum=''
						linenum=$(cut -d ':' -f1 "$dbtable" | sed '1d'\
						| grep -x -n -e "$REPLY" | cut -d':' -f1)

						if [[ "$REPLY" == '' ]]; then
							echo no entry
						elif [[ "$linenum" = '' ]]; then
							echo this primary key doesn\'t exist
						else
							let linenum=$linenum+1
							num_col=$(head -1 "$dbtable" | awk -F: '{print NF}') # to get number of columns in table
							echo other values of record:
							for (( i = 2; i <= num_col; i++ )); do
									echo \"$(head -1 $dbtable | cut -d ':' -f$i |\
									awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable" | cut -d ':' -f$i |\
									awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable" | cut -d ':' -f$i |\
									awk -F "-" 'BEGIN { RS = ":" } {print $3}'): $(sed -n "${linenum}p" "$dbtable" | cut -d: -f$i)
							done
						fi
					fi
					echo --------------------------------------------------------------------------------------
					echo press any key
					read
					;;
				7 ) # display table
					echo enter name of the table
					read dbtable
					if ! [[ -f "$dbtable" ]]; then
						echo this table doesn\'t exist # color this
						echo press any key
						read
					else
						head -1 "$dbtable" | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}' | awk 'BEGIN{ORS="\t"} {print $0}'
						echo -n $'\n'
						sed '1d' "$dbtable" | awk -F: 'BEGIN{OFS="\t"} {for(n = 1; n <= NF; n++) $n=$n}  1'
						echo $'\n'press any key
						read
					fi
					;;
				8 ) # back
					cd ..
					flag3=false
					flag2=true
					flag1=false
					;;
				* )
					echo wrong choice # color this
					echo press any key
					read
					;;
			esac
			break # hated the prompt in the end to rerun the select statement
		done
	done
done

CHAT_DIR=/tmp/shell-chat
CHANNELS_DIR="$CHAT_DIR"/channels
USERS_DIR="$CHAT_DIR"/users

user_exists() {
	user_file="$USERS_DIR/$1"
	if [ -e "$user_file" ]; then
		return 0 #true
	else
		return 1 #false
	fi
}

user_is_logged() {
	channel_file="$CHANNELS_DIR/$1"
	if [ -e "$channel_file" ]; then
		return 0 #true
	else
		return 1 #false
	fi
}

is_passd_correct() {
	user_file="$USERS_DIR/$1"
	if [ "$(cat "$user_file")" = "$2" ]; then
		return 0 #true
	else
		return 1 #false
	fi
}

is_logged() {
	if [ -z $logged_user ]; then
		return 1 #false
	else
		return 0 #true
	fi
}
check_logged() {
	if ! is_logged; then
		echo "Please, login first!" 1>&2
		return 1 #false
	else
		return 0 #true
	fi
}
logout() {
	channel=$CHANNELS_DIR/$logged_user
	rm "$channel"
	logged_user=""
}

listen() {
	channel_file="$CHANNELS_DIR/$logged_user"
	tail -f "$channel_file" | while read msg; do \
			echo ""; \
			echo $msg;\
			echo -n "prompt> ";\
		done &
}

list() {
	ls -1 $CHANNELS_DIR
}

if [ ! -d "$CHAT_DIR" ]; then
	mkdir "$CHAT_DIR"
	mkdir "$CHANNELS_DIR"
	mkdir "$USERS_DIR"
fi

logged_user=""

while [ 1 ]; do
	echo -n "prompt> "
	read input
	cmd=$(echo $input | cut -d " " -f1)

	if [ ! -d "$USERS_DIR" ]; then
		echo "Start the server first!" 1>&2
	else
		case $cmd in
			create)
				name=$(echo $input | cut -d " " -f2)
				passwd=$(echo $input | cut -d " " -f 3)
				if user_exists $name; then
					echo "This name is taken!" 1>&2
				else
					echo -n "$passwd" > "$user_file"
				fi
				;;
			
			login)
				name=$(echo $input | cut -d " " -f2)
				passwd=$(echo $input | cut -d " " -f 3)

				if is_logged; then
					echo "You already logged in as '$logged_user'. Please logout first!" 1>&2
				elif user_exists $name && is_passd_correct $name $passwd; then
					if user_is_logged $name; then
						echo "This user is already logged in (or didn't logout)" 1>&2
					else
						mkfifo "$channel_file"
						logged_user="$name"
						listen
					fi
				else
					echo "Incorrect user or password!" 1>&2
				fi
				;;
			
			msg)
				if check_logged; then
					receiver=$(echo $input | cut -d " " -f 2)
					content=$(echo $input | cut -d " " -f 3-)
					channel_file="$CHANNELS_DIR/$receiver"

					if ! user_is_logged $receiver; then
						echo "$receiver is not logged in!" 1>&2
					else
						echo "[Message from $logged_user]: $content" > "$channel_file"
					fi
				fi
				;;
			
			list)
				if check_logged; then
					list
				fi
				;;

			passwd)
				name=$(echo $input | cut -d " " -f2)
				old_passwd=$(echo $input | cut -d " " -f 3)
				new_passwd=$(echo $input | cut -d " " -f 4)
				user_file="$USERS_DIR/$name"
				
				if user_exists $name && is_passd_correct $name $old_passwd; then
					echo -n "$new_passwd" > "$user_file"
				else
					echo "Incorrect user or password!" 1>&2
				fi
				;;
			
			logout)
				if check_logged; then
					logout
				fi
				;;

			quit)
				if is_logged; then
					logout
				fi
				break;
				;;

			*) echo "Unknown command '$cmd'" 1>&2
		esac
	fi
done

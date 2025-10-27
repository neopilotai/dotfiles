#!/usr/bin/env zsh

# check whether this script is being eval'ed
[[ $0 =~ "autoupdate.zsh" ]] && sourced=0 || sourced=1

# update_error appends a descriptive error entry to the global update_errors array when a command's exit code is non-zero.
function update_error() {
	error_cmd=$1
	error_code=$2
	if [ $error_code -ne 0 ]; then
		# add the error to the array
		update_errors+=("$error_cmd: $error_code")
	fi
}

tp='success'

# show_errors prints any accumulated update errors, sends a terminal notification when the script is sourced, and otherwise exits with status 0 if overall status is "success" or 1 if "error".
function show_errors() {
	if [ ${#update_errors[@]} -ne 0 ]; then
		tp='error'
		echo "Errors occurred during update:"
		for error in "${update_errors[@]}"; do
			echo "  $error"
		done
	fi
	# $sourced is 1, use term-notify to send notifications
	if [ $sourced -eq 1 ]; then
		term-notify $tp $interval <<<"autoupdate.zsh"
	else
		if [ $tp = 'success' ]; then
			exit 0
		else
			exit 1
		fi
	fi
}

# check_interval computes the number of seconds since the timestamp stored in ~/FILENAME and echoes the interval; if the file does not exist it treats the last update as 0.
function check_interval() {
	now=$(date +%s)
	if [ -f ~/${1} ]; then
		last_update=$(cat ~/${1})
	else
		last_update=0
	fi
	interval=$(expr ${now} - ${last_update})
	echo ${interval}
}

# revolver_stop stops the revolver progress display and restores the terminal cursor visibility.
function revolver_stop() {
  revolver stop
  tput cnorm
}

if [ -z "$SYSTEM_UPDATE_DAYS" ]; then
	SYSTEM_UPDATE_DAYS=7
fi

if [ -z "$SYSTEM_RECEIPT_F" ]; then
	SYSTEM_RECEIPT_F='.system_lastupdate'
fi

# check whether force update option was provided
if [ "$1" = "--force" ]; then
	force_update=1
else
	force_update=0
fi

day_seconds=86400
system_seconds=$(expr ${day_seconds} \* ${SYSTEM_UPDATE_DAYS})

last_system=$(check_interval ${SYSTEM_RECEIPT_F})

if [ ${last_system} -gt ${system_seconds} ] || [ $force_update -eq 1 ]; then
	# get current time
	start_time=$(date +%s)

	$(date +%s >~/${SYSTEM_RECEIPT_F})
	echo "It has been $(expr ${last_system} / $day_seconds) days since system was updated"
	echo "Updating system... Please open a new terminal to continue your work in parallel..."

  # check if revolver command exists
  if command -v revolver >/dev/null 2>&1; then
    tput civis
    revolver --style 'dots2' start 'Pulling latest dotfiles...'
  fi

	cd ~ && chezmoi --force update -v
	update_error dotfiles $?

  revolver update "Running personal autoupdates..."
	# run ~/.autoupdate_local.zsh if it exists
	if [ -f ~/.autoupdate_local.zsh ]; then
		# run ~/.autoupdate_local.zsh by eval it's content
		eval "$(cat ~/.autoupdate_local.zsh)"
		update_error ~/.autoupdate_local.zsh $?
	fi

  if command -v revolver >/dev/null 2>&1; then
    revolver_stop
  fi
	~/scripts/bin/sync_brews.sh
	update_error sync_brews $?

  revolver --style 'dots2' start 'Updating zinit... (Press q or Enter if this is taking too long)'
	source $HOME/.local/share/zinit/zinit.git/zinit.zsh && zinit self-update && zinit update --quiet --parallel 8 && zinit cclear
	update_error zinit $?

  revolver update "Updating nvim... (Press Spaces if this is taking too long)"
	nvim +PlugUpgrade +PlugClean! +PlugUpdate +PlugInstall +CocUpdateSync +TSUpdateSync +qall
	update_error nvim $?

  revolver update "Updating npm packages..."
	# Update npm packages with safer audit fix
	npm update && npm upgrade
	# Only run audit fix if package.json exists and has dependencies
	if [ -f package.json ] && [ -s package.json ]; then
		npm audit fix --dry-run && npm audit fix
	fi
	npm prune --production
	update_error npm $?

  revolver update "Updating pip packages..."
	# upgrade pip and pip packages with safer practices
	pip3 install --quiet --upgrade pip setuptools wheel

	# Update pip packages if requirements.txt exists, otherwise update all
	if [ -f requirements.txt ]; then
		pip3 install --quiet --upgrade -r requirements.txt
	elif [ -f pyproject.toml ]; then
		pip3 install --quiet --upgrade .
	else
		# Fallback to updating all local packages (less safe but necessary)
		pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install --quiet --upgrade 2>/dev/null || true
	fi
	update_error pip $?


  revolver update "Updating tldr cache..."
	# update tldr
	tldr --update
  
  revolver update "Syncing styles in $HOME/notes"
  pushd $HOME/notes && vale sync && popd

  revolver_stop

  $HOME/scripts/bin/sync_neopilotai.sh
  $HOME/scripts/bin/sync_fluxninja.sh

  if [[ $TERM == *"tmux"* || $TERM == *"screen"* || -n $TMUX ]]; then
    tmux source-file $HOME/.tmux.conf
  fi

	stop_time=$(date +%s)
	interval=$(expr ${stop_time} - ${start_time})
	echo "It took $interval seconds to update the system."
	show_errors
fi

unset SYSTEM_RECEIPT_F
unset SYSTEM_UPDATE_DAYS
unset day_seconds
unset last_system
unset system_seconds
unset start_time
unset stop_time
unset interval
unset force_update
unset update_errors
unset check_interval
unset error_code
unset error_cmd
unset tp
unset -f update_error
unset -f check_interval
unset -f show_errors
unset -f revolver_stop
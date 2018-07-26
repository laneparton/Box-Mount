#!/bin/sh

# If the config file exists, go ahead and mount Box
if [ -f "$HOME/.config/rclone/rclone.conf" ]; then

	# If the mount directory doesn't exist, create it
	if [ ! -d "/Box/$USER" ]; then
		mkdir /Box/$USER
	fi

	# Create a symbolic link in home dir to the mount dir - overwrite it if its already there
	# in case it is corrupt or anything of that sort.
	ln -sfn /Box/$USER $HOME/Desktop/Box

	# Finally, mount the remote to the folder using Rclone
	# This is where we will want to pass the ideal config parameters - some are added, there might be more - tbd
	eval "/N/soft/rhel7/rclone/1.41/rclone mount Box: /Box/"$USER" \
	--vfs-cache-mode=writes \
	--dir-cache-time=15s \
	--daemon"

	# We need to give the mount some time to startup before testing whether it works or not.
	sleep 1

	# Test the mount directory and see if there is anything in it
	# There is a possibility of this throwing an error if a user has absolutely no files in their box account,
	# looking to handle that soon. In the event of that, it would totally work, but show the zenity error screen.
	if [ -z "$(ls -A /Box/$USER)" ]; then
		# When this happens, we need to make sure the rclone process is killed.
		# Otherwise if for some reason the access/refresh tokens are corrupt
		# the process never dies and the "Input/output error" is thrown thus nothing will work
		if pgrep -u $USER -f rclone > /dev/null; then
  			# rclone is running, kill it
  			pkill -u $USER rclone
		fi

		# If the directory is still listed as mounted, go ahead and unmount it before going any further.
		if mount | grep /Box/$USER > /dev/null; then
		    # Unmount
  			fusermount -u /Box/$USER
		fi
		
		dialogue=$(zenity --error --ellipsize --title="Box Launcher" \
		--text="Box was not successfully mounted.\nTry resetting the configuration.\n\nIf the problem persists contact\nthe RED Beta Development Team." \
		--ok-label="Ok" \
		--extra-button="Reset Configuration")


		# Lets give the user a way to invoke the configuration script if the mount fails.
		# This will overwrite their rclone.conf with new tokens
		if [[ $dialogue == "Reset Configuration"  ]]; then
			# Launch the Configuration Script
			gnome-terminal -e "python $HOME/Desktop/v3/Rclone-Auth/auth.py"
		else
			# Otherwise close window
			exit
		fi
	else
		# There are files showing up in the mount directory, let the user know everything is ready to go.
		zenity --info --ellipsize --title="Box Launcher" \
		 --text="You have successfully mounted box!\n\nYou can now access it from your Desktop."
	fi
# Otherwise the config file doesn't exist so run the python script to generate a config file
else
	# If the Rclone config directory doesn't exist in the user's .config directory, create it.
	if [ ! -d "$HOME/.config/rclone" ]; then
		mkdir $HOME/.config/rclone
	fi
	# Launch a terminal - this is essential for the bottle server used in the OAuth script
	gnome-terminal -e "python $HOME/Desktop/v3/Rclone-Auth/auth.py"
fi

prepare_yabs

# https://github.com/masonr/yet-another-bench-script
# launch_geekbench
# Purpose: This method is designed to run the Primate Labs' Geekbench 4/5 Cross-Platform Benchmark utility
# Parameters:
#          1. VERSION - indicates which Geekbench version to run
function launch_geekbench {
	VERSION=$1

	# create a temp directory to house all geekbench files
	GEEKBENCH_PATH=$YABS_PATH/geekbench_$VERSION
	mkdir -p $GEEKBENCH_PATH

	# check for curl vs wget
	[[ ! -z $LOCAL_CURL ]] && DL_CMD="curl -s" || DL_CMD="wget -qO-"

	if [[ $VERSION == *4* && ($ARCH = *aarch64* || $ARCH = *arm*) ]]; then
		echo -e "\nARM architecture not supported by Geekbench 4, use Geekbench 5."
	elif [[ $VERSION == *4* && $ARCH != *aarch64* && $ARCH != *arm* ]]; then # Geekbench v4
		echo -en "\nRunning GB4 benchmark test... *may take several minutes*"
		# download the latest Geekbench 4 tarball and extract to geekbench temp directory
		$DL_CMD https://cdn.geekbench.com/Geekbench-4.4.4-Linux.tar.gz | tar xz --strip-components=1 -C $GEEKBENCH_PATH &>/dev/null

		if [[ "$ARCH" == *"x86"* ]]; then
			# check if geekbench file exists
			if test -f "geekbench.license"; then
				$GEEKBENCH_PATH/geekbench_x86_32 --unlock $(cat geekbench.license) >/dev/null 2>&1
			fi

			# run the Geekbench 4 test and grep the test results URL given at the end of the test
			GEEKBENCH_TEST=$($GEEKBENCH_PATH/geekbench_x86_32 --upload 2>/dev/null | grep "https://browser")
		else
			# check if geekbench file exists
			if test -f "geekbench.license"; then
				$GEEKBENCH_PATH/geekbench4 --unlock $(cat geekbench.license) >/dev/null 2>&1
			fi

			# run the Geekbench 4 test and grep the test results URL given at the end of the test
			GEEKBENCH_TEST=$($GEEKBENCH_PATH/geekbench4 --upload 2>/dev/null | grep "https://browser")
		fi
	fi

	if [[ $VERSION == *5* ]]; then                           # Geekbench v5
		if [[ $ARCH = *x86* && $GEEKBENCH_4 == *False* ]]; then # don't run Geekbench 5 if on 32-bit arch
			echo -e "\nGeekbench 5 cannot run on 32-bit architectures. Re-run with -4 flag to use"
			echo -e "Geekbench 4, which can support 32-bit architectures. Skipping Geekbench 5."
		elif [[ $ARCH = *x86* && $GEEKBENCH_4 == *True* ]]; then
			echo -e "\nGeekbench 5 cannot run on 32-bit architectures. Skipping test."
		else
			echo -en "\nRunning GB5 benchmark test... *may take several minutes*"
			# download the latest Geekbench 5 tarball and extract to geekbench temp directory
			if [[ $ARCH = *aarch64* || $ARCH = *arm* ]]; then
				$DL_CMD https://cdn.geekbench.com/Geekbench-5.4.4-LinuxARMPreview.tar.gz | tar xz --strip-components=1 -C $GEEKBENCH_PATH &>/dev/null
			else
				$DL_CMD https://cdn.geekbench.com/Geekbench-5.4.4-Linux.tar.gz | tar xz --strip-components=1 -C $GEEKBENCH_PATH &>/dev/null
			fi
			# check if geekbench file exists
			if test -f "geekbench.license"; then
				$GEEKBENCH_PATH/geekbench5 --unlock $(cat geekbench.license) >/dev/null 2>&1
			fi

			GEEKBENCH_TEST=$($GEEKBENCH_PATH/geekbench5 --upload 2>/dev/null | grep "https://browser")
		fi
	fi

	# ensure the test ran successfully
	if [ -z "$GEEKBENCH_TEST" ]; then

		if [[ -z "$IPV4_CHECK" ]]; then

			# Geekbench test failed to download because host lacks IPv4 (cdn.geekbench.com = IPv4 only)
			echo -e "\r\033[0KGeekbench releases can only be downloaded over IPv4. FTP the Geekbench files and run manually."
		elif [[ $ARCH != *x86* ]]; then

			# if the Geekbench test failed for any reason, exit cleanly and print error message
			echo -e "\r\033[0KGeekbench $VERSION test failed. Run manually to determine cause."
		fi

	else

		# if the Geekbench test succeeded, parse the test results URL
		GEEKBENCH_URL=$(echo -e $GEEKBENCH_TEST | head -1)
		GEEKBENCH_URL_CLAIM=$(echo $GEEKBENCH_URL | awk '{ print $2 }')
		GEEKBENCH_URL=$(echo $GEEKBENCH_URL | awk '{ print $1 }')

		# sleep a bit to wait for results to be made available on the geekbench website
		sleep 20
		# parse the public results page for the single and multi core geekbench scores
		[[ $VERSION == *5* ]] && GEEKBENCH_SCORES=$($DL_CMD $GEEKBENCH_URL | grep "div class='score'") ||
			GEEKBENCH_SCORES=$($DL_CMD $GEEKBENCH_URL | grep "span class='score'")
		GEEKBENCH_SCORES_SINGLE=$(echo $GEEKBENCH_SCORES | awk -v FS="(>|<)" '{ print $3 }')
		GEEKBENCH_SCORES_MULTI=$(echo $GEEKBENCH_SCORES | awk -v FS="(>|<)" '{ print $7 }')

		# print the Geekbench results
		echo -en "\r\033[0K"
		echo -e "Geekbench $VERSION Benchmark Test:"
		echo -e "---------------------------------"
		printf "%-15s | %-30s\n" "Test" "Value"
		printf "%-15s | %-30s\n"
		printf "%-15s | %-30s\n" "Single Core" "$GEEKBENCH_SCORES_SINGLE"
		printf "%-15s | %-30s\n" "Multi Core" "$GEEKBENCH_SCORES_MULTI"
		printf "%-15s | %-30s\n" "Full Test" "$GEEKBENCH_URL"

		# write the geekbench claim URL to a file so the user can add the results to their profile (if desired)
		[ ! -z "$GEEKBENCH_URL_CLAIM" ] && echo -e "$GEEKBENCH_URL_CLAIM" >>geekbench_claim.url 2>/dev/null
	fi
}

# if the skip geekbench flag was set, skip the system performance test, otherwise test system performance
if [ -z "$SKIP_GEEKBENCH" ]; then
	if [[ $GEEKBENCH_4 == *True* ]]; then
		launch_geekbench 4
	fi

	if [[ $GEEKBENCH_5 == *True* ]]; then
		launch_geekbench 5
	fi
fi

finished_yabs

inspect_args

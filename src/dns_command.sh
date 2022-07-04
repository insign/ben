set -f
IFS=,
winners=()
lowest_server_time=10000

get_split() {
	string=$1
	separator=$2
	position=$3

	echo "$string" | cut -d"$separator" -f"$position"
}

int(){ printf '%d' ${1:-} 2>/dev/null || :; }

# shellcheck disable=SC2154
for ((round = 1; round < ${args[--rounds]} + 1; round++)); do
	echo "Round $round"
	sleep "${args[--sleep]}"

	while read -r DNS; do
		if [ -n "$DNS" ]; then
			dns=($DNS)
			server_ip=${dns[0]}
			server_name=${dns[1]}
			# shellcheck disable=SC2154
			server_time=$(dig @"${server_ip}" -q "${args[host]}" +noall +stats | sed -nEz 's/.*;; Query time:\s([^\n]*).*.msec.*/\1/p')
			server_time=$(int $server_time)


			printf "%15s%12s%5dms\n" "$server_ip" "$server_name" "$server_time"
			if [ "${server_time}" -lt $lowest_server_time ]; then
				lowest_server_time=$server_time
				lowest_server_ip=$server_ip
				lowest_server_name=$server_name
			fi
		fi
	done <./ipv4.csv

	winners+=("$round,$lowest_server_ip,$lowest_server_name,$lowest_server_time")

done
for i in "${winners[@]}"; do
	winner=($i)
	round=${winner[0]}
	ip=${winner[1]}
	name=${winner[2]}
	time=${winner[3]}

	printf "Round %s winner: %5s%12s%5dms\n" "$round" "$ip" "$name" "$time"
done

inspect_args

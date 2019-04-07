function gotest(){
	set -o pipefail
	prefix="";suffix=""
	go test $* | while IFS=$'\n' read -r line
	do
		if echo ${line} | grep -q -e "^\s*=== RUN "; then
			prefix="";suffix=""
		elif echo ${line} | grep -q -e "^\s*--- PASS: "; then
			prefix="\033[32m";suffix="\033[0m"
		elif echo ${line} | grep -q -e "^\s*--- FAIL: "; then
			prefix="\033[91m";suffix="\033[0m"
		fi
		echo "$prefix$line$suffix"
	done
}

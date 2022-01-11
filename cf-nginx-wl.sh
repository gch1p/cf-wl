#!/bin/bash

TEMP=$(mktemp)
OUTPUT="$1"

die() {
	echo "error: $@"
	[ -f "$TEMP" ] && rm "$TEMP"
	exit 1
}

[ -z "$OUTPUT" ] && {
	echo "usage: $0 OUTPUT"
	exit
}

curl -s "https://www.cloudflare.com/ips-v4" --output "$TEMP" || die "downloading failed"
[ -s "$TEMP" ] || die "temp file is empty"

cat "$TEMP" | sed 's/^/allow /g' | sed 's/$/;/g' | tee "$TEMP" > /dev/null
echo -e "satisfy all;\n$(cat "$TEMP")" > "$TEMP"
echo "deny all;" >> "$TEMP"

[ -f "$OUTPUT" ] && {
	rm "$OUTPUT" || die "failed to remove old file $OUTPUT"
}
mv "$TEMP" "$OUTPUT"

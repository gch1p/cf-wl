#!/bin/bash

TEMP=$(mktemp)
IPSET_NAME="$1"

ipset_exists() {
	ipset -L "$1" >/dev/null 2>/dev/null
}

die() {
	echo "error: $@"
	[ -f "$TEMP" ] && rm "$TEMP"
	exit 1
}

[ -z "$IPSET_NAME" ] && {
	echo "usage: $0 IPSET_NAME"
	exit
}

if ! ipset_exists "$IPSET_NAME"; then
	echo "warn: set $IPSET_NAME doesn't exists, creating it for you..."
	ipset create $IPSET_NAME hash:net || die "failed to create ipset"
fi

list=$(curl -s "https://www.cloudflare.com/ips-v4")
[ -z "$list" ] && die "failed to fetch cf networks"

ipset flush $IPSET_NAME || die "failed to flush $IPSET_NAME"
for net in $list; do
	ipset add $IPSET_NAME $net || echo "error: failed to add $net to $IPSET_NAME"
done

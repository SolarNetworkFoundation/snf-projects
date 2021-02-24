#!/usr/bin/env sh

APT_PROXY=""
UPDATE_PKG_CACHE=""
BOOT_CONFIG="/boot/firmware/config.txt"
KIOSK_CONFIG="/home/kiosk/.config/solarkiosk.conf"

while getopts ":o:Pv" opt; do
	case $opt in
		o) APT_PROXY="${OPTARG}";;
		P) UPDATE_PKG_CACHE='TRUE';;
		v) ;;
		*)
			echo "Unknown argument ${OPTARG}"
			exit 1
	esac
done
shift $(($OPTIND - 1))

apt_proxy=""
if [ -n "$APT_PROXY" ]; then
	apt_proxy="-o Acquire::http::Proxy=http://${APT_PROXY}"
fi

if [ -n "$UPDATE_PKG_CACHE" ]; then
	echo 'Updating package cache...'
	apt -y update
fi

if [ -e "$BOOT_CONFIG" ]; then
	if ! grep -q 'disable_overscan=1' "$BOOT_CONFIG" 2>/dev/null; then
		echo "Adding disable_overscan=1 to $BOOT_CONFIG"
		echo 'disable_overscan=1' >>"$BOOT_CONFIG"
	fi
fi

# Remove solarnode (via Java)
echo "Removing Java and all dependents"
apt purge -y openjdk-11-jre-headless

echo "Upgrading OS packages..."
apt upgrade -y \
	-o Dpkg::Options::="--force-confdef" \
	-o Dpkg::Options::="--force-confnew"

# Remove no-longer-needed packages
echo "Removing unneeded packages..."
apt autoremove --purge -y

# Add kiosk
echo "Adding WPE kiosk"
apt install -y \
	-o Dpkg::Options::="--force-confdef" \
	-o Dpkg::Options::="--force-confnew" \
	${apt_proxy} \
	sn-kiosk-wpe

# Configure WSC URL, zoom level
if [ -e "$KIOSK_CONFIG" ]; then
	sed -i -e 's/SOLARKIOSK_URL=.*/SOLARKIOSK_URL="https%3A%2F%2Fgo.solarnetwork.net%2Fnz%2Fwsc%2F"/' \
		-e 's/SOLARKIOSK_ZOOM_LEVEL=.*/SOLARKIOSK_ZOOM_LEVEL="1.5"/' \
		"$KIOSK_CONFIG"
fi

#!/bin/bash
#
# This file prepares the openwrt source tree prior to doing a build.
#
# Basically, this means that minor configuration changes that need
# to be done prior to performing the build are done here.
#
# This file assumes that its being run in the same directory as the .config
# file found in the root of openwrt tree.

SCRIPT_NAME=$(basename $0)
SCRIPT_DIR=$(dirname $0)

if [ ! -f .config ]; then
  echo "No .config file found in the current directory."
  exit 1
fi

HOSTNAME=gateway

###########################################################################
#
# Prints the program usage
#
usage() {
  cat <<END
${SCRIPT_NAME} [OPTION]

where OPTION can be one of:

  --hostname NAME   Specify the hostname
  -h, --help        Print this help
  -v, --verbose     Turn on some verbose reporting
  -x                Does a 'set -x'
END
}

###########################################################################
#
# Update hostname
#
update_hostname() {
  SYSTEM_INIT=./package/base-files/files/etc/init.d/system

  OLD_HOSTNAME=$(sed -n -e "/hostname:string:/ s/.*hostname:string:\([^']*\).*/\1/p" "${SYSTEM_INIT}")

  echo "Updating hostname from '${OLD_HOSTNAME}' to '${HOSTNAME}'"

  sed -i -e "s/hostname:string:${OLD_HOSTNAME}/hostname:string:${HOSTNAME}/" "${SYSTEM_INIT}"
}

###########################################################################
#
# Parses command line arguments and run the program.
#
main() {
  while getopts ":vhx-:" opt "$@"; do
    case $opt in
      -)
        case "${OPTARG}" in
          help)
            usage
            exit 1
            ;;
          hostname)
            HOSTNAME="${!OPTIND}"
            OPTIND=$(( OPTIND + 1 ))
            ;;
          verbose)
            VERBOSE=1
            ;;
          *)
            if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
              echo "Unknown option --${OPTARG}" >&2
              echo ""
              usage
              exit 1
            fi
        esac
        ;;
      h)
        usage
        exit 1
        ;;
      v)
        VERBOSE=1
        ;;
      x)
        set -x
        ;;
      ?)
        echo "Unrecognized option: ${opt}"
        echo ""
        usage
        exit 1
        ;;
      esac
  done
  shift $(( OPTIND - 1 ))

  if [ "${VERBOSE}" == "1" ]; then
    echo "HOSTNAME = ${HOSTNAME}"
  fi

  echo ""

  update_hostname
}

main "$@"

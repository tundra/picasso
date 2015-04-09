#! /bin/sh
### BEGIN INIT INFO
# Provides:          picasso
# Required-Start:    $remote_fs $syslog virtualbox vboxdrv sshd
# Required-Stop:     $remote_fs $syslog virtualbox vboxdrv sshd
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start the virtualbox slave vms
# Description:       Start the virtualbox slave vms
### END INIT INFO

# Service that starts and stops the picasso slave vms. Install it by
# doing the following:
#
#   1. Create a link to this file as /etc/init.d/picasso.
#
#   2. Create a file called /etc/default/picasso which sets two
#      variables, PICASSO_HOME which points to your picasso checkout
#      and PICASSO_USER which is the user to run the vms as.
#
#   3. Run [sudo update-rc.d picasso defaults 80] which registers the
#      service to be run.
#
# We require ssh before starting up because it takes a while to start
# and there's no reason not to be able to ssh into the machine before
# then.

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Picasso slave vms"
NAME=picasso
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

if [ -z "$PICASSO_HOME" ]; then
  log_failure_msg "No \$PICASSO_HOME set"
  exit 1
fi

if [ ! -d "$PICASSO_HOME" ]; then
  log_failure_msg "Picasso home $PICASSO_HOME doesn't exist"
  exit 1
fi

if [ -z "$PICASSO_USER" ]; then
  log_failure_msg "No \$PICASSO_USER set"
  exit 1
fi

TOOLS=$PICASSO_HOME/vagrant/tools
USER_HOME=$(eval "echo ~$PICASSO_USER")

do_start() {
  HOME=$USER_HOME chpst -u $PICASSO_USER "$TOOLS/start-picasso-service.sh" && log_success_msg "Started $DESC" "$NAME"
}

do_stop() {
  HOME=$USER_HOME chpst -u $PICASSO_USER "$TOOLS/stop-picasso-service.sh" && log_success_msg "Stopped $DESC" "$NAME"
}

do_restart() {
  do_start && do_stop
}

case "$1" in
  start)
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
    do_start
    case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  stop)
    [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
    do_stop
    case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  status)
    log_failure_msg "Don't know how to status $NAME, sorry"
    ;;
  restart|force-reload)
    log_daemon_msg "Restarting $DESC" "$NAME"
    do_restart
    case "$?" in
      0) log_end_msg 0 ;;
      1) log_end_msg 1 ;; # Old process is still running
      *) log_end_msg 1 ;; # Failed to start
    esac
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
    exit 3
  ;;
esac

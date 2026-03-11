Here is how to export them considering that the souce is in .config place, made it manuaklly to be more controlable

#### Important ####
Don't forget to put your own things.
Directoriers here should be changed on your wish.

# one way to do it
# Source all shell configurations
#SHELL_CONFIG_DIR="$HOME/.config/shell"
#
# Load in specific order
#[ -f "$SHELL_CONFIG_DIR/core.sh" ] && source "$SHELL_CONFIG_DIR/core.sh"
#[ -f "$SHELL_CONFIG_DIR/aliases.sh" ] && source "$SHELL_CONFIG_DIR/aliases.sh"
#[ -f "$SHELL_CONFIG_DIR/functions.sh" ] && source "$SHELL_CONFIG_DIR/functions.sh"


# my current way
# Source all shell configurations
if [ -d "$HOME/.config/shell" ]; then
    for config_file in "$HOME/.config/shell"/*.sh; do
        [ -f "$config_file" ] && source "$config_file"
    done
fi

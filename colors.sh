if [ "$TERM" = "xterm-color" ]; then

    CLR_RESET='\033[m'      # Reset all formatting

    # Text Styling
    CLR_BOLD='\033[1m'       # Bold
    CLR_DIM='\033[2m'        # Dim
    CLR_UNDERLINE='\033[4m'  # Underline
    CLR_BLINK='\033[5m'      # Blinking
    CLR_INVERT='\033[7m'     # Invert current color scheme

    # Colors
    CLR_BLACK='\033[30m'    # Black
    CLR_RED='\033[31m'      # Red
    CLR_GREEN='\033[32m'    # Green
    CLR_YELLOW='\033[33m'   # Yellow
    CLR_BLUE='\033[34m'     # Blue
    CLR_MAGENTA='\033[35m'  # Magenta
    CLR_CYAN='\033[36m'     # Cyan
    CLR_WHITE='\033[37m'    # White
    CLR_DEFAULT='\033[39m'  # Default

    # Bright Colors
    CLR_bBLACK='\033[90m'    # Black
    CLR_bRED='\033[91m'      # Red
    CLR_bGREEN='\033[92m'    # Green
    CLR_bYELLOW='\033[93m'   # Yellow
    CLR_bBLUE='\033[94m'     # Blue
    CLR_bMAGENTA='\033[95m'  # Magenta
    CLR_bCYAN='\033[96m'     # Cyan
    CLR_bWHITE='\033[97m'    # White
    CLR_bDEFAULT='\033[99m'  # Default

    # Background Colors
    CLR_BG_BLACK='\033[40m'    # Black
    CLR_BG_RED='\033[41m'      # Red
    CLR_BG_GREEN='\033[42m'    # Green
    CLR_BG_YELLOW='\033[43m'   # Yellow
    CLR_BG_BLUE='\033[44m'     # Blue
    CLR_BG_MAGENTA='\033[45m'  # Magenta
    CLR_BG_CYAN='\033[46m'     # Cyan
    CLR_BG_WHITE='\033[47m'    # White
    CLR_BG_DEFAULT='\033[49m'  # Default  

    # Bright Background Colors
	CLR_BG_bBLACK='\033[100m'    # Black
    CLR_BG_bRED='\033[101m'      # Red
    CLR_BG_bGREEN='\033[102m'    # Green
    CLR_BG_bYELLOW='\033[103m'   # Yellow
    CLR_BG_bBLUE='\033[104m'     # Blue
    CLR_BG_bMAGENTA='\033[105m'  # Magenta
    CLR_BG_bCYAN='\033[106m'     # Cyan
    CLR_BG_bWHITE='\033[107m'    # White
    CLR_BG_bDEFAULT='\033[109m'  # Default

    # Extra Aliases
    CLR_R=$CLR_RESET
    CLR_B=$CLR_BOLD
    CLR_U=$CLR_UNDERLINE

fi

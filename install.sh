#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "\033[0;31mThis script must be run as root (use sudo).\033[0m"
   exit 1
fi

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PANEL_PATH="/var/www/pterodactyl"
WRAPPER_PATH="${PANEL_PATH}/resources/views/templates/wrapper.blade.php"
BACKUP_PATH="${WRAPPER_PATH}.bak"
ASSETS_DIR="${PANEL_PATH}/public/assets/custom"

# Verify Pterodactyl Installation
if [[ ! -f "$WRAPPER_PATH" ]]; then
    echo -e "${RED}Error: wrapper.blade.php not found at ${WRAPPER_PATH}${NC}"
    echo -e "${RED}Are you sure Pterodactyl is installed here?${NC}"
    exit 1
fi

# Helper function to clear previous theme injections
clean_theme_injections() {
    sed -i '/<style id="saturo-zentrix-theme">/,/<\/style>/d' "$WRAPPER_PATH"
    sed -i '/<style id="custom-bg-style">/,/<\/style>/d' "$WRAPPER_PATH"
    sed -i '/<style id="xyron-login-width-override">/,/<\/style>/d' "$WRAPPER_PATH"
    sed -i '/<style id="xyron-login-transparent-override">/,/<\/style>/d' "$WRAPPER_PATH"
    sed -i '/id="custom-bg"/d' "$WRAPPER_PATH"
    sed -i '/class="bg-transparent-overlay"/d' "$WRAPPER_PATH"
    sed -i 's/ bg-transparent//g' "$WRAPPER_PATH"
}

# Helper function to clear view cache
clear_cache() {
    echo -e "${BLUE}[+] Clearing Laravel view cache...${NC}"
    cd "$PANEL_PATH" && php artisan view:clear > /dev/null 2>&1
}

# Function to Install Background (Video / Image)
install_bg() {
    BG_TYPE=$1
    echo ""
    if [[ "$BG_TYPE" == "video" ]]; then
        read -p "Enter Video URL: " BG_URL
    else
        read -p "Enter Image URL: " BG_URL
    fi

    if [[ -z "$BG_URL" ]]; then
        echo -e "${RED}URL cannot be empty.${NC}"
        return
    fi

    # Create Backup if it doesn't exist
    if [[ ! -f "$BACKUP_PATH" ]]; then
        cp "$WRAPPER_PATH" "$BACKUP_PATH"
        echo -e "${GREEN}[+] Created original wrapper backup at ${BACKUP_PATH}${NC}"
    fi

    # Download File
    mkdir -p "$ASSETS_DIR"
    FILENAME=$(basename "$BG_URL" | cut -d? -f1) # Strip URL queries
    DEST_PATH="${ASSETS_DIR}/${FILENAME}"

    echo -e "${BLUE}[+] Downloading background file...${NC}"
    if wget -q -O "$DEST_PATH" "$BG_URL"; then
        echo -e "${GREEN}[+] File saved to ${DEST_PATH}${NC}"
    else
        echo -e "${RED}[-] Failed to download file. Check the URL.${NC}"
        return
    fi

    # Define Glassmorphism CSS Block (Includes Login Modal & Bandwidth Chart Fixes)
    export CSS_BLOCK="<style id=\"saturo-zentrix-theme\">
    /* Main Background & Overlay */
    #custom-bg {
        position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
        object-fit: cover; z-index: -1;
    }
    .bg-transparent-overlay {
        position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
        background: rgba(0, 0, 0, 0.4); z-index: -1;
    }
    #app { position: relative; z-index: 1; }

    /* Glassmorphism for standard panel cards */
    .bg-neutral-900, .bg-neutral-800, .bg-neutral-700 {
        background-color: rgba(15, 15, 15, 0.6) !important;
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.05);
    }

    /* Login Modal Container Styling — matched to spy.zentrixtech.name.ng */
    .flex-1.flex.items-center.justify-center > div,
    div[class*="LoginFormContainer__Container"] {
        width: 700px !important;
        max-width: calc(100vw - 2rem) !important;
        box-sizing: border-box !important;
        margin-left: auto !important;
        margin-right: auto !important;
        background-color: rgba(0, 0, 0, 0.14) !important;
        background-image: none !important;
        backdrop-filter: blur(8px);
        -webkit-backdrop-filter: blur(8px);
        border-radius: 14px;
        box-shadow: 0 18px 45px rgba(0, 0, 0, 0.28);
        border: 1px solid rgba(255, 255, 255, 0.18);
        padding: 2rem;
    }

    /* Match the live panel’s generated login wrapper and form dimensions. */
    div[class*="sc-qtrnpk-0"] {
        width: 700px !important;
        max-width: calc(100vw - 2rem) !important;
        margin: 0 auto !important;
        padding: 0 !important;
        box-sizing: border-box !important;
    }

    /* The reference login form measures 620px inside the 700px card. */
    form[class*="LoginContainer___StyledLoginFormContainer"],
    form[class*="LoginFormContainer"] {
        width: 620px !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        margin-left: auto !important;
        margin-right: auto !important;
    }

    /* Prevent the app shell and login page from becoming wider than the device viewport. */
    html, body, #app {
        width: 100% !important;
        min-width: 0 !important;
        max-width: 100% !important;
        margin: 0 !important;
        overflow-x: hidden !important;
    }

    /* Keep the same proportions on phones without causing horizontal overflow. */
    @media (max-width: 740px) {
        .flex-1.flex.items-center.justify-center,
        .flex-1.flex.items-center.justify-center > div,
        div[class*="LoginContainer___StyledLoginContainer"],
        div[class*="LoginFormContainer__Container"],
        div[class*="sc-qtrnpk-0"] {
            width: 100vw !important;
            max-width: 100vw !important;
            min-width: 0 !important;
            margin-left: 0 !important;
            margin-right: 0 !important;
            padding: 0 1rem !important;
            box-sizing: border-box !important;
        }

        div[class*="LoginFormContainer__Container"] {
            width: calc(100vw - 2rem) !important;
            max-width: calc(100vw - 2rem) !important;
            margin-left: auto !important;
            margin-right: auto !important;
        }

        form[class*="LoginContainer___StyledLoginFormContainer"],
        form[class*="LoginFormContainer"] {
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
        }
    }

    /* Bandwidth / Server Resource Charts Background Fix */
    canvas {
        background-color: rgba(0, 0, 0, 0.35);
        border-radius: 8px;
        padding: 10px;
    }

    /* Live panel inner login glass layer. */
    div[class*="sc-cyh04c-3"],
    form div[class*="sc-cyh04c"],
    form div { 
        background: rgba(0, 0, 0, 0.35) !important;
        backdrop-filter: blur(16px) !important;
        -webkit-backdrop-filter: blur(16px) !important;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5) !important;
    }

    /* Keep controls readable over the transparent background. */
    input, textarea, select {
        background-color: rgba(0, 0, 0, 0.22) !important;
        color: rgba(255, 255, 255, 0.95) !important;
        border: 1px solid rgba(255, 255, 255, 0.16) !important;
        backdrop-filter: blur(5px);
        -webkit-backdrop-filter: blur(5px);
    }

    button[type="submit"] {
        background-color: rgba(59, 130, 246, 0.88) !important;
        border: 1px solid rgba(255, 255, 255, 0.22) !important;
    }

    /* Text Brightness Adjustments */
    .text-neutral-400, .text-neutral-500, label {
        color: rgba(255, 255, 255, 0.9) !important;
    }

    /* Global Body Transparency */
    body.bg-transparent { background-color: transparent !important; }
</style>"

    ASSET_PATH="/assets/custom/${FILENAME}"
    if [[ "$BG_TYPE" == "video" ]]; then
        export BG_HTML_BLOCK="<video autoplay loop muted playsinline id=\"custom-bg\"><source src=\"${ASSET_PATH}\" type=\"video/mp4\"></video><div class=\"bg-transparent-overlay\"></div>"
    else
        export BG_HTML_BLOCK="<img id=\"custom-bg\" src=\"${ASSET_PATH}\"><div class=\"bg-transparent-overlay\"></div>"
    fi

    echo -e "${BLUE}[+] Injecting Theme & Background...${NC}"

    # Clean old injections before writing new ones
    clean_theme_injections

    # Inject CSS into <head>
    perl -0777 -pi -e 's|</head>|$ENV{CSS_BLOCK}\n</head>|g' "$WRAPPER_PATH"

    # Inject bg-transparent class into <body> tag
    perl -0777 -pi -e 's|(<body[^>]*class=")([^"]*)(")|$1$2 bg-transparent$3|g' "$WRAPPER_PATH"

    # Inject Background HTML element right after opening <body>
    perl -0777 -pi -e 's|(<body[^>]*>)|$1\n$ENV{BG_HTML_BLOCK}|g' "$WRAPPER_PATH"

    # Permissions & Cache Clear
    chown -R www-data:www-data "$ASSETS_DIR" 2>/dev/null || chown -R nginx:nginx "$ASSETS_DIR" 2>/dev/null
    clear_cache

    echo -e "${GREEN}[+] Background successfully applied! Refresh your panel to view changes.${NC}\n"
}

# Function to Remove Background (Keeps Backup)
remove_bg() {
    echo -e "${BLUE}[+] Removing custom background and styles...${NC}"
    clean_theme_injections
    clear_cache
    echo -e "${GREEN}[+] Custom background removed.${NC}\n"
}

# Function to Restore Original Wrapper
restore_wrapper() {
    if [[ -f "$BACKUP_PATH" ]]; then
        echo -e "${BLUE}[+] Restoring original wrapper.blade.php...${NC}"
        cp "$BACKUP_PATH" "$WRAPPER_PATH"
        clear_cache
        echo -e "${GREEN}[+] Wrapper restored to original state.${NC}\n"
    else
        echo -e "${RED}[-] Backup file (wrapper.blade.php.bak) not found!${NC}\n"
    fi
}

# Interactive Menu Loop
while true; do
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${GREEN} ZENTRIX x SATURO PANEL BACKGROUND INSTALLER ${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo "1) Video Background"
    echo "2) Image Background"
    echo "3) Remove Background"
    echo "4) Restore Original Wrapper"
    echo "5) Exit"
    echo ""
    read -p "Select: " CHOICE

    case $CHOICE in
        1)
            install_bg "video"
            ;;
        2)
            install_bg "image"
            ;;
        3)
            remove_bg
            ;;
        4)
            restore_wrapper
            ;;
        5)
            echo -e "${YELLOW}Exiting installer. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid selection. Please choose 1-5.${NC}\n"
            ;;
    esac
done

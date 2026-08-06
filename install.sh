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

    # Define Glassmorphism CSS Block (Includes Login Glass, Input Fixes, & White Line Overflow Fixes)
    export CSS_BLOCK="<style id=\"saturo-zentrix-theme\">
    /* Global Viewport & White Line Removal Fixes */
    html, body, #app, div[class*=\"AppContainer\"], div[class*=\"AuthenticationRouter\"] {
        background-color: #0f172a !important;
        background-attachment: fixed !important;
        background-position: center !important;
        background-repeat: no-repeat !important;
        background-size: cover !important;
        min-height: 100vh !important;
        width: 100% !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow-x: hidden !important;
    }

    * {
        box-sizing: border-box !important;
    }

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

    /* Glassmorphism Login Modal & Container Styling */
    .flex-1.flex.items-center.justify-center > div,
    div[class*=\"LoginFormContainer\"], 
    div[class*=\"LoginContainer\"],
    .bg-white {
        background: rgba(15, 23, 42, 0.45) !important;
        backdrop-filter: blur(16px) saturate(180%) !important;
        -webkit-backdrop-filter: blur(16px) saturate(180%) !important;
        border-radius: 20px !important;
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.5) !important;
        border: 1px solid rgba(255, 255, 255, 0.15) !important;
        padding: 2rem;
    }

    /* Glassmorphic Input Text Boxes */
    input[type=\"text\"], 
    input[type=\"password\"], 
    input[type=\"email\"] {
        background: rgba(0, 0, 0, 0.35) !important;
        color: #ffffff !important;
        border: 1px solid rgba(255, 255, 255, 0.2) !important;
        border-radius: 10px !important;
        backdrop-filter: blur(5px) !important;
        -webkit-backdrop-filter: blur(5px) !important;
        transition: all 0.3s ease !important;
    }

    input[type=\"text\"]:focus, 
    input[type=\"password\"]:focus, 
    input[type=\"email\"]:focus {
        border-color: #3b82f6 !important;
        box-shadow: 0 0 12px rgba(59, 130, 246, 0.5) !important;
        outline: none !important;
    }

    input::placeholder {
        color: rgba(255, 255, 255, 0.5) !important;
    }

    label, p, span, h1, h2, h3 {
        color: #f3f4f6 !important;
    }

    /* Login Submit Button */
    button[type=\"submit\"] {
        background: linear-gradient(135deg, #2563eb, #1d4ed8) !important;
        border: 1px solid rgba(255, 255, 255, 0.2) !important;
        border-radius: 10px !important;
        font-weight: 600 !important;
        box-shadow: 0 4px 15px rgba(37, 99, 235, 0.4) !important;
    }

    /* Bandwidth / Server Resource Charts Background Fix */
    canvas {
        background-color: rgba(0, 0, 0, 0.35);
        border-radius: 8px;
        padding: 10px;
    }

    /* Text Brightness Adjustments */
    .text-neutral-400, .text-neutral-500 {
        color: rgba(255, 255, 255, 0.85) !important;
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

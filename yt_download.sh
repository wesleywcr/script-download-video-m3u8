#!/bin/bash

# YouTube Downloader with Cutting & Format Options
# Dependencies: yt-dlp, ffmpeg

# Colors for better UI
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}   YouTube Downloader & Cutter         ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Check dependencies
for cmd in yt-dlp ffmpeg; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed.${NC}"
        exit 1
    fi
done

# 1. Get URL
read -p "Enter YouTube URL: " URL
if [[ -z "$URL" ]]; then
    echo -e "${RED}Error: URL cannot be empty.${NC}"
    exit 1
fi

# 2. Get Cutoff Times
echo -e "\n${YELLOW}Leaving times blank will download the full video.${NC}"
read -p "Start time (HH:MM:SS or SS, e.g., 00:01:30): " START_TIME
read -p "End time (HH:MM:SS or SS, e.g., 00:02:00): " END_TIME

# Prepare download sections argument
SECTION_ARG=""
if [[ -n "$START_TIME" || -n "$END_TIME" ]]; then
    # Default values if one is missing
    [[ -z "$START_TIME" ]] && START_TIME="0"
    [[ -z "$END_TIME" ]] && END_TIME="inf"
    SECTION_ARG="*${START_TIME}-${END_TIME}"
fi

if [[ -n "$SECTION_ARG" ]]; then
    YT_VERSION="$(yt-dlp --version)"
    REQUIRED_VERSION="2026.03.17"
    if [[ "$YT_VERSION" < "$REQUIRED_VERSION" ]]; then
        echo -e "${RED}Error: yt-dlp ${YT_VERSION} is too old for --download-sections.${NC}"
        echo -e "${YELLOW}Please run: sudo apt update && sudo apt install yt-dlp${NC}"
        exit 1
    fi
fi

# 3. Get Format
echo -e "\nChoose output format:"
echo "1) MP4 (Video + Audio)"
echo "2) MP3 (Audio only)"
read -p "Select option [1-2]: " FORMAT_OPT

# 4. Get Filename
read -p "Enter output filename (without extension): " FILENAME
[[ -z "$FILENAME" ]] && FILENAME="downloaded_file"

echo -e "\n${GREEN}Starting download...${NC}"

if [[ "$FORMAT_OPT" == "2" ]]; then
    # MP3 Logic
    if [[ -n "$SECTION_ARG" ]]; then
        yt-dlp -x --audio-format mp3 --download-sections "$SECTION_ARG" --force-keyframes-at-cuts \
               -o "${OUTPUT_DIR}/${FILENAME}.%(ext)s" "$URL"
    else
        yt-dlp -x --audio-format mp3 -o "${OUTPUT_DIR}/${FILENAME}.%(ext)s" "$URL"
    fi
else
    # MP4 Logic (Default)
    if [[ -n "$SECTION_ARG" ]]; then
        yt-dlp -f "bv+ba/b" --merge-output-format mp4 --download-sections "$SECTION_ARG" --force-keyframes-at-cuts \
               -o "${OUTPUT_DIR}/${FILENAME}.%(ext)s" "$URL"
    else
        yt-dlp -f "bv+ba/b" --merge-output-format mp4 -o "${OUTPUT_DIR}/${FILENAME}.%(ext)s" "$URL"
    fi
fi

if [[ $? -eq 0 ]]; then
    shopt -s nullglob
    downloaded_files=( "${OUTPUT_DIR}/${FILENAME}."* )
    shopt -u nullglob
    if [[ ${#downloaded_files[@]} -gt 0 ]]; then
        latest_file="${downloaded_files[0]}"
        for file in "${downloaded_files[@]}"; do
            if [[ "$file" -nt "$latest_file" ]]; then
                latest_file="$file"
            fi
        done
        echo -e "\n${GREEN}Success! File saved as ${latest_file}${NC}"
    else
        echo -e "\n${GREEN}Success! Download completed in ${OUTPUT_DIR}${NC}"
    fi
else
    echo -e "\n${RED}Error: Download failed.${NC}"
fi

#!/bin/bash

read -p "Enter YouTube URL: " url
read -p "Enter max quality (e.g. 480 or 720): " quality

yt-dlp -f "bv*[height<=$quality]+ba/b[height<=$quality]" \
--print "%(filesize,filesize_approx)s" "$url" \
| awk '{s+=$1} END {printf "%.2f GB\n", s/1024/1024/1024}'
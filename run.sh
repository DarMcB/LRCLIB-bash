#!/bin/bash
for f in *.mp3;
do
        if [[ -f "${f%.*}".lrc ]]
        then
                echo "${f%.*}".lrc exists
        else

                #get Song Title
                title="$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "${f%.*}".mp3*)";

                #get Song Artist
                artist="$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "${f%.*}".mp3*)";

                #replace " " with "+" for curl
                title=${title// /+};
                artist=${artist// /+};

                #LRCLIB API and jq write to file
                for i in $(seq 0 19);
                do
                        lyrics="$(curl -s https://lrclib.net/api/search?q=$artist+$title)"
                        formattedLyrics="$(jq -r .[$i].syncedLyrics <<< "$lyrics")"
                        if [[ $formattedLyrics == null ]]
                        then
                                echo skipping "${f%.*}".lrc
                                break
                        else
                                echo "$formattedLyrics" > "${f%.*}".lrc
                                echo creating "${f%.*}".lrc;
                                break
                        fi
                done
        fi
done

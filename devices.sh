#!/bin/bash
# List audio input devices ffmpeg can see. Run before every take - indices shift.
echo "Audio input devices:"
ffmpeg -f avfoundation -list_devices true -i "" 2>&1 \
  | awk '/AVFoundation audio devices/{a=1;next} a && /\] \[[0-9]+\]/{
      sub(/.*\] \[/,"["); print "  " $0 }'
echo
echo "Use the number in brackets as the device index for record.sh"

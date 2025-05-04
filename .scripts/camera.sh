ffplay $(ls /dev/ | grep "video" | xargs -I {} echo "/dev/{}" | tofi)

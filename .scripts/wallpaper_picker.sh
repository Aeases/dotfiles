#!/bin/sh

swww img --transition-type wave --transition-fps 60 "$(ls ${HOME}/.config/hypr/wallpapers/ | tofi | xargs -I {} echo "${HOME}/.config/hypr/wallpapers/{}")"

#!/bin/sh

swww img --transition-type none "$(ls ${HOME}/.config/hypr/wallpapers/ | tofi | xargs -I {} echo "${HOME}/.config/hypr/wallpapers/{}")"

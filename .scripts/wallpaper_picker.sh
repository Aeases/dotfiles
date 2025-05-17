#!/bin/sh

swww img "$(ls ${HOME}/.config/hypr/wallpapers/ | tofi | xargs -I {} echo "${HOME}/.config/hypr/wallpapers/{}")"

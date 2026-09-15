#!/usr/bin/env bash
# Keep steam_app_<appid>.desktop aliases in sync with Steam's generated entries.
#
# Steam names its generated desktop entries after the store title (Balatro.desktop)
# and writes no StartupWMClass, but game windows report an app_id of
# steam_app_<appid>. Nothing links the two, so waybar's workspace taskbar finds no
# icon for a running game.
#
# Waybar's IconLoader::get_app_info_by_name() probes
# $HOME/.local/share/applications/<app_id>.desktop first, before its StartupWMClass
# index and before the fuzzy search. So a symlink named steam_app_<appid>.desktop
# sitting beside the original is found immediately, with no XDG_DATA_DIRS changes.
#
# Steam only writes those entries for games the user asked it to, so a second pass
# covers the rest: every installed game in an appmanifest that has no entry gets a
# minimal NoDisplay one generated in $GENAPPS, and the same kind of alias pointing
# at it. Generated entries live outside the applications directory so they never
# appear in a launcher and so uninstall knows exactly what it made.
#
# Steam installs steam_icon_<appid>.png into the icon theme as part of writing a
# desktop entry, so a game without one has no themed icon either and `Icon=` by
# name would resolve to nothing. The generated entry therefore points at a copy of
# Steam's own icon asset, taken out of appcache/librarycache and kept in $GENICONS
# -- unexported on purpose: it is referenced by absolute path rather than installed
# into the icon theme, so nothing else on the system has to be updated or undone.
#
# Run by steam-desktop-aliases.timer.

set -uo pipefail
shopt -s nullglob

APPDIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
GENDIR="${XDG_DATA_HOME:-$HOME/.local/share}/steam-icon-fixer"
GENAPPS="$GENDIR/applications"
GENICONS="$GENDIR/unexported-icons"

# Basename of an alias we own. Matching on this exact shape matters: our own
# symlinks also carry a rungameid Exec, so without skipping them the scan would
# reprocess its own output.
is_alias() { [[ ${1##*/} =~ ^steam_app_[0-9]+\.desktop$ ]]; }

# The appid an alias claims, from its filename.
alias_appid() { local b=${1##*/}; b=${b#steam_app_}; echo "${b%.desktop}"; }

# What we point an alias at when the entry is one we generated. Relative, like the
# links to Steam's own entries, so the data directory can be moved wholesale.
gen_link() { echo "../steam-icon-fixer/applications/$1"; }

# Filename for a generated entry: the game's name, the way Steam names its own
# entries, so a generated alias reads like every other one. Drops the characters
# Steam drops too, plus anything that would make a path or a hidden file.
gen_name() {
    local n
    n=$(printf '%s' "$1" | tr -d '/:\000-\037' | sed 's/^[[:space:].]*//; s/[[:space:]]*$//')
    printf '%s' "$n"
}

# The appid a generated entry claims. Read from its Exec line, because the
# filename is the game's name and no longer says which app it is.
entry_appid() { grep -m1 -oP '^Exec=.*steam://rungameid/\K[0-9]+' "$1" 2>/dev/null; }

[[ -d $APPDIR ]] || { echo "no $APPDIR, nothing to do"; exit 0; }

created=0 removed=0 unchanged=0 generated=0 dropped=0

# appid -> source basename, built from Steam's own entries.
declare -A want=()
# appid -> game name, built from the installed-game manifests.
declare -A have=()

# Sorted so that "first entry wins" is deterministic across runs when two files
# claim the same appid.
for f in "$APPDIR"/*.desktop; do
    is_alias "$f" && continue

    # Read the appid off the Exec line specifically, not from anywhere in the file.
    id=$(grep -m1 -oP '^Exec=.*steam://rungameid/\K[0-9]+' "$f" 2>/dev/null) || true
    [[ -n ${id:-} ]] || continue

    if [[ -n ${want[$id]:-} ]]; then
        echo "warning: appid $id claimed by both '${want[$id]}' and '${f##*/}', keeping the first"
        continue
    fi
    want[$id]=${f##*/}
done

# --- second pass: installed games Steam wrote no entry for --------------------

# Every Steam installation on the machine, native before Flatpak, deduped by
# resolved path (~/.steam/steam is usually a symlink to the native one). Order is
# what makes a game present in both described by the native install.
steam_roots() {
    local root real seen=()
    local -a candidates=(
        "${XDG_DATA_HOME:-$HOME/.local/share}/Steam"
        "$HOME/.steam/steam"
        "$HOME/.steam/root"
        "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
        "$HOME/.var/app/com.valvesoftware.Steam/data/Steam"
    )

    for root in "${candidates[@]}"; do
        [[ -d $root ]] || continue
        real=$(realpath -- "$root" 2>/dev/null) || real=$root
        [[ " ${seen[*]-} " == *" $real "* ]] && continue
        seen+=("$real")
        printf '%s\n' "$real"
    done
}

# Every steamapps directory worth reading, in that same order.
steam_libraries() {
    local root libs=() seen=() candidate real dir
    while IFS= read -r root; do
        [[ -d $root/steamapps ]] || continue
        # A library can be listed by several roots (~/.steam/steam is usually a
        # symlink to the native one), so dedupe on the resolved path.
        for candidate in "$root/steamapps" \
            $(grep -oP '"path"\s*"\K[^"]+' "$root/steamapps/libraryfolders.vdf" 2>/dev/null); do
            dir=$candidate
            [[ $dir == */steamapps ]] || dir=$dir/steamapps
            [[ -d $dir ]] || continue
            real=$(realpath -- "$dir" 2>/dev/null) || real=$dir
            [[ " ${seen[*]-} " == *" $real "* ]] && continue
            seen+=("$real")
            libs+=("$real")
        done
    done < <(steam_roots)
    printf '%s\n' "${libs[@]-}"
}

# Steam's own icon for an app, out of its library cache: the hash-named image
# sitting directly in librarycache/<appid>/, which is the 32x32 asset Steam
# converts into steam_icon_<appid>.png when it writes a desktop entry itself.
# Everything else in there is named (header.jpg, library_*, logo.png) or a
# directory, so the hash shape is what distinguishes it.
steam_icon_source() {
    local root f b
    while IFS= read -r root; do
        for f in "$root/appcache/librarycache/$1"/*; do
            [[ -f $f ]] || continue
            b=${f##*/}
            if [[ $b =~ ^[0-9a-f]{40}\.(jpg|png)$ || $b =~ ^icon\.(jpg|png)$ ]]; then
                printf '%s\n' "$f"
                return 0
            fi
        done
    done < <(steam_roots)
    return 1
}

# Steam installs its own runtimes and compatibility tools as appids too. They
# never open a window, so an icon alias for them would be noise.
is_tool() {
    [[ $1 =~ ^Proton([[:space:]]|$) ]] ||
    [[ $1 =~ ^Steam[[:space:]]Linux[[:space:]]Runtime ]] ||
    [[ $1 =~ ^Steam[[:space:]]Runtime ]] ||
    [[ $1 == "Steamworks Common Redistributables" ]] ||
    [[ $1 == "SteamVR" ]]
}

# Desktop entries take backslash escapes, and a value is a single line.
desktop_escape() { printf '%s' "${1//\\/\\\\}" | tr -d '\n\r'; }

while IFS= read -r lib; do
    [[ -n $lib ]] || continue
    for m in "$lib"/appmanifest_*.acf; do
        id=${m##*/appmanifest_}
        id=${id%.acf}
        [[ $id =~ ^[0-9]+$ ]] || continue
        # First library wins: the roots above are ordered native before Flatpak.
        [[ -n ${have[$id]:-} ]] && continue

        name=$(grep -m1 -oP '^\s*"name"\s+"\K[^"]*' "$m" 2>/dev/null) || true
        [[ -n ${name:-} ]] || name="steam_app_$id"
        is_tool "$name" && continue

        have[$id]=$name
    done
done < <(steam_libraries)

# appid -> basename of the entry we generated for it.
declare -A gen=()
# Absolute path -> 1, for every icon we copied. The sweep keeps only these.
declare -A gen_icons=()
# basename -> appid, so two games sharing a name cannot claim the same file.
declare -A gen_used=()

# Write an entry for every installed game Steam did not describe itself. Sorted so
# that which of two identically-named games keeps the plain filename is stable
# across runs rather than following the hash order of the array.
while IFS= read -r id; do
    [[ -n $id ]] || continue
    [[ -n ${want[$id]:-} ]] && continue

    base=$(gen_name "${have[$id]}")
    [[ -n $base && -z ${gen_used[$base]:-} ]] || base="steam_app_$id"
    gen_used[$base]=$id
    gen[$id]=$base.desktop

    mkdir -p -- "$GENAPPS" || { echo "error: could not create $GENAPPS" >&2; break; }

    # Take Steam's own icon along, since without its desktop entry Steam never
    # installed steam_icon_$id into the theme and the name would resolve to
    # nothing. Referenced by absolute path, which .desktop allows.
    icon="steam_icon_$id"
    if src=$(steam_icon_source "$id"); then
        if mkdir -p -- "$GENICONS"; then
            dest="$GENICONS/$base.${src##*.}"
            # Only copy when it would change, so the entry below stays byte-identical
            # across runs and the GUI's file monitor has nothing to react to.
            if cmp -s -- "$src" "$dest" || cp -f -- "$src" "$dest"; then
                icon=$dest
                gen_icons[$dest]=1
            else
                echo "error: could not copy $src to $dest" >&2
            fi
        fi
    fi

    entry="$GENAPPS/${gen[$id]}"
    body="[Desktop Entry]
Type=Application
Name=$(desktop_escape "${have[$id]}")
Exec=steam steam://rungameid/$id
Icon=$icon
Terminal=false
NoDisplay=true
StartupWMClass=steam_app_$id
X-SteamIconFixer-Generated=true"

    # Only touch the file when it would actually change: the GUI watches this
    # directory's neighbour and a rewrite on every timer tick would churn it.
    if [[ ! -f $entry || $(cat -- "$entry") != "$body" ]]; then
        printf '%s\n' "$body" > "$entry" || { echo "error: could not write $entry" >&2; continue; }
        generated=$((generated + 1))
    fi
done < <(printf '%s\n' "${!have[@]}" | sort -n)

# --- reconcile the aliases ----------------------------------------------------

# Drop aliases that no longer correspond to a source entry, and any that dangle.
# Only ever unlink symlinks, so a hand-written steam_app_*.desktop is left alone.
for f in "$APPDIR"/steam_app_*.desktop; do
    is_alias "$f" || continue
    [[ -L $f ]] || continue

    id=$(alias_appid "$f")
    target=$(readlink "$f")

    if [[ $target == ../steam-icon-fixer/* ]]; then
        # One of ours. It stays only while the game is installed, Steam still has
        # not written a real entry -- if it has, the loop below relinks to it --
        # and it still points at the entry's current name, which changes when
        # Steam renames the game.
        if [[ -z ${have[$id]:-} || -n ${want[$id]:-} || ! -e $f
              || $target != "$(gen_link "${gen[$id]:-}")" ]]; then
            rm -f -- "$f" && removed=$((removed + 1))
        fi
        continue
    fi

    if [[ -z ${want[$id]:-} || $target != "${want[$id]}" || ! -e $f ]]; then
        rm -f -- "$f" && removed=$((removed + 1))
    fi
done

# Generated entries for games that went away, or that Steam has since described
# itself. Left behind these would be invisible clutter nothing else cleans up.
for e in "$GENAPPS"/*.desktop; do
    id=$(entry_appid "$e") || true
    if [[ -z ${id:-} || -z ${have[$id]:-} || -n ${want[$id]:-} || ${e##*/} != "${gen[$id]:-}" ]]; then
        rm -f -- "$e" && dropped=$((dropped + 1))
    fi
done

# Icons for entries that are no longer there, and entries left flat in $GENDIR by
# an older version of this script, which kept them one level up.
for i in "$GENICONS"/*; do
    [[ -n ${gen_icons[$i]:-} ]] || rm -f -- "$i"
done
for e in "$GENDIR"/*.desktop; do
    rm -f -- "$e" && dropped=$((dropped + 1))
done

rmdir -- "$GENAPPS" "$GENICONS" 2>/dev/null
rmdir -- "$GENDIR" 2>/dev/null

# Create what's missing, as a relative link so it survives the directory being
# moved or re-stowed. Steam's own entry wins over a generated one for the same id.
for id in "${!want[@]}" ; do
    link="$APPDIR/steam_app_$id.desktop"

    if [[ -L $link && $(readlink "$link") == "${want[$id]}" && -e $link ]]; then
        unchanged=$((unchanged + 1))
        continue
    fi

    # Never clobber a real file someone put here on purpose.
    if [[ -e $link && ! -L $link ]]; then
        echo "warning: $link is a regular file, refusing to replace it"
        continue
    fi

    if ln -sfn -- "${want[$id]}" "$link"; then
        created=$((created + 1))
    else
        echo "error: could not link $link -> ${want[$id]}" >&2
    fi
done

for id in "${!gen[@]}"; do
    [[ -f $GENAPPS/${gen[$id]} ]] || continue
    link="$APPDIR/steam_app_$id.desktop"
    target=$(gen_link "${gen[$id]}")

    if [[ -L $link && $(readlink "$link") == "$target" && -e $link ]]; then
        unchanged=$((unchanged + 1))
        continue
    fi

    if [[ -e $link && ! -L $link ]]; then
        echo "warning: $link is a regular file, refusing to replace it"
        continue
    fi

    if ln -sfn -- "$target" "$link"; then
        created=$((created + 1))
    else
        echo "error: could not link $link -> $target" >&2
    fi
done

echo "$created created, $removed removed, $unchanged unchanged (${#want[@]} steam entries);" \
     "$generated generated, $dropped dropped (${#have[@]} installed games)"

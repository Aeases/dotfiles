#!/usr/bin/env bash
# Waybar icons for Steam games: NoDisplay steam_app_<appid>.desktop copies of Steam's entries (or of
# entries generated for games Steam didn't describe). --learn <class> <pid> aliases other classes.

set -uo pipefail
shopt -s nullglob

DATA=${XDG_DATA_HOME:-$HOME/.local/share}
APPDIR=$DATA/applications GENDIR=$DATA/steam-icon-fixer
GENAPPS=$GENDIR/applications GENICONS=$GENDIR/unexported-icons
ALIAS_KEY=X-SteamIconFixer-Alias CLASS_KEY=X-SteamIconFixer-Class
ROOTS=("$DATA/Steam" ~/.steam/steam ~/.steam/root ~/.var/app/com.valvesoftware.Steam/{.local/share,data}/Steam)
TOOLS='^(Proton([[:space:]]|$)|Steam[[:space:]](Linux[[:space:]])?Runtime|Steamworks Common Redistributables$|SteamVR$)'

key() {
	awk -v k="$2=" '/^\[/ { main = ($0 == "[Desktop Entry]"); next }
		main && index($0, k) == 1 { print substr($0, length(k) + 1); exit }' "$1" 2>/dev/null
}
exec_appid() { grep -m1 -oP '^Exec=.*steam://rungameid/\K[0-9]+' "$1" 2>/dev/null; }
esc() { printf '%s' "${1//\\/\\\\}" | tr -d '\n\r'; }

entry() {
	printf '%s\n' '[Desktop Entry]' Type=Application "Name=$2" "Exec=steam steam://rungameid/$1" \
		"Icon=$3" Terminal=false NoDisplay=true "${@:4}"
}
# A copy, not a symlink: a symlink is the same visible entry, so launchers would list games twice.
copy_of() {
	local n i
	n=$(key "$2" Name) i=$(key "$2" Icon)
	entry "$1" "${n:-steam_app_$1}" "${i:-steam_icon_$1}" "${@:3}"
}
# Only write on change: the .path unit watches $APPDIR, so rewriting would retrigger it forever.
put() {
	[[ -f $1 && $(<"$1") == "$2" ]] && return 1
	printf '%s\n' "$2" > "$1.tmp" && mv -f -- "$1.tmp" "$1" && return 0
	rm -f -- "$1.tmp"
	echo "error: could not write $1" >&2
	return 2
}

libraries() {
	local root dir real
	local -A seen=()
	for root in "${ROOTS[@]}"; do
		[[ -d $root/steamapps ]] || continue
		for dir in "$root/steamapps" $(grep -oP '"path"\s*"\K[^"]+' "$root/steamapps/libraryfolders.vdf" 2>/dev/null); do
			[[ $dir == */steamapps ]] || dir=$dir/steamapps
			[[ -d $dir ]] && real=$(realpath -- "$dir") && [[ -z ${seen[$real]:-} ]] || continue
			seen[$real]=1
			echo "$real"
		done
	done
}

# The 32x32 image Steam turns into steam_icon_<appid>.png when it writes an entry itself.
icon_src() {
	local root f
	for root in "${ROOTS[@]}"; do
		for f in "$root/appcache/librarycache/$1"/*; do
			[[ -f $f && ${f##*/} =~ ^([0-9a-f]{40}|icon)\.(jpg|png)$ ]] && { echo "$f"; return 0; }
		done
	done
	return 1
}

sync() {
	[[ -d $APPDIR ]] || { echo "no $APPDIR, nothing to do"; return 0; }
	exec 9> "${XDG_RUNTIME_DIR:-/tmp}/steam-desktop-aliases.lock" && flock 9 # timer vs --learn
	local f id lib m name base icon img dest cls
	local created=0 removed=0 unchanged=0 generated=0 dropped=0 classes=0
	local -A want=() have=() gen=() used=() icons=() src=()

	for f in "$APPDIR"/*.desktop; do
		[[ ${f##*/} =~ ^steam_app_[0-9]+\.desktop$ || -n $(key "$f" "$CLASS_KEY") ]] && continue
		id=$(exec_appid "$f") || continue
		if [[ -n ${want[$id]:-} ]]; then
			echo "warning: appid $id claimed by both '${want[$id]}' and '${f##*/}', keeping the first"
		else
			want[$id]=${f##*/}
		fi
	done

	while IFS= read -r lib; do
		for m in "$lib"/appmanifest_*.acf; do
			id=${m##*/appmanifest_} id=${id%.acf}
			[[ $id =~ ^[0-9]+$ && -z ${have[$id]:-} ]] || continue
			name=$(grep -m1 -oP '^\s*"name"\s+"\K[^"]*' "$m" 2>/dev/null) || true
			name=${name:-steam_app_$id}
			[[ $name =~ $TOOLS ]] || have[$id]=$name
		done
	done < <(libraries)

	while IFS= read -r id; do
		[[ -n $id && -z ${want[$id]:-} ]] || continue
		base=$(printf '%s' "${have[$id]}" | tr -d '/:\000-\037' | sed 's/^[[:space:].]*//; s/[[:space:]]*$//')
		[[ -n $base && -z ${used[$base]:-} ]] || base=steam_app_$id
		used[$base]=$id gen[$id]=$base.desktop
		mkdir -p -- "$GENAPPS" || { echo "error: could not create $GENAPPS" >&2; break; }
		icon=steam_icon_$id
		if img=$(icon_src "$id") && mkdir -p -- "$GENICONS"; then
			dest=$GENICONS/$base.${img##*.}
			if cmp -s -- "$img" "$dest" || cp -f -- "$img" "$dest"; then
				icon=$dest icons[$dest]=1
			else
				echo "error: could not copy $img to $dest" >&2
			fi
		fi
		put "$GENAPPS/${gen[$id]}" "$(entry "$id" "$(esc "${have[$id]}")" "$icon" \
			"StartupWMClass=steam_app_$id" X-SteamIconFixer-Generated=true)" && ((++generated))
	done < <(printf '%s\n' "${!have[@]}" | sort -n)

	for id in "${!want[@]}"; do src[$id]=${want[$id]}; done
	for id in "${!gen[@]}"; do
		[[ -f $GENAPPS/${gen[$id]} ]] && src[$id]=../steam-icon-fixer/applications/${gen[$id]}
	done

	# Files without our key were put here by hand; symlinks are all ours, from older versions.
	for f in "$APPDIR"/steam_app_*.desktop; do
		id=${f##*/steam_app_} id=${id%.desktop}
		[[ $id =~ ^[0-9]+$ ]] && [[ -L $f || (-n $(key "$f" "$ALIAS_KEY") && -z ${src[$id]:-}) ]] &&
			rm -f -- "$f" && ((++removed))
	done
	for f in "$GENDIR"/*.desktop; do rm -f -- "$f" && ((++dropped)); done # older versions' layout
	for f in "$GENAPPS"/*.desktop; do
		id=$(exec_appid "$f") || id=
		[[ -n $id && -n ${have[$id]:-} && -z ${want[$id]:-} && ${f##*/} == "${gen[$id]:-}" ]] ||
			{ rm -f -- "$f" && ((++dropped)); }
	done
	for f in "$GENICONS"/*; do [[ -n ${icons[$f]:-} ]] || rm -f -- "$f"; done
	rmdir -- "$GENAPPS" "$GENICONS" "$GENDIR" 2>/dev/null

	for id in "${!src[@]}"; do
		f=$APPDIR/steam_app_$id.desktop
		if [[ -e $f && -z $(key "$f" "$ALIAS_KEY") ]]; then
			echo "warning: $f is not one of ours, refusing to replace it"
			continue
		fi
		put "$f" "$(copy_of "$id" "$APPDIR/${src[$id]}" "$ALIAS_KEY=${src[$id]}")"
		case $? in 0) ((++created)) ;; 1) ((++unchanged)) ;; esac
	done

	for f in "$APPDIR"/*.desktop; do
		id=$(key "$f" "$CLASS_KEY")
		[[ -n $id ]] || continue
		if [[ -z ${src[$id]:-} || -z $(key "$APPDIR/steam_app_$id.desktop" "$ALIAS_KEY") ]]; then
			rm -f -- "$f" && ((++removed))
			continue
		fi
		cls=${f##*/} cls=${cls%.desktop}
		put "$f" "$(copy_of "$id" "$APPDIR/steam_app_$id.desktop" "StartupWMClass=$(esc "$cls")" \
			"$CLASS_KEY=$id")" && ((++created))
		((++classes))
	done

	echo "$created created, $removed removed, $unchanged unchanged (${#want[@]} steam entries);" \
		"$generated generated, $dropped dropped (${#have[@]} installed games); $classes class aliases"
}

learn() {
	local cls=$1 env id dir f
	local -a data dirs=("$APPDIR")
	# Steam exports SteamAppId to everything it launches, through Proton and pressure-vessel.
	env=$(tr '\0' '\n' < "/proc/$2/environ" 2>/dev/null) || return 0
	id=$(grep -m1 -oP '^SteamAppId=\K[1-9][0-9]{0,19}$' <<< "$env" ||
		grep -m1 -oP '^SteamGameId=\K[1-9][0-9]{0,19}$' <<< "$env") || return 0
	[[ -n $cls && $cls != .* && $cls != */* && ${#cls} -le 200 && ! $cls =~ [[:cntrl:]] &&
		! $cls =~ ^steam_app_[0-9]+$ ]] || { echo "unusable class '$cls'" >&2; return 1; }

	f=$APPDIR/steam_app_$id.desktop
	[[ -n $(key "$f" "$ALIAS_KEY") ]] || sync > /dev/null # game installed since the last sync
	[[ -n $(key "$f" "$ALIAS_KEY") ]] || { echo "appid $id isn't an installed game, skipping '$cls'"; return 0; }

	# Leave classes with an entry of their own (a browser the game opened inherits SteamAppId).
	IFS=: read -ra data <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
	for dir in "${data[@]}"; do [[ -n $dir ]] && dirs+=("${dir%/}/applications"); done
	for dir in "${dirs[@]}"; do
		f=$dir/$cls.desktop
		[[ -e $f && -z $(key "$f" "$CLASS_KEY") ]] && { echo "'$cls' already has $f, skipping"; return 0; }
	done
	while IFS= read -r f; do
		[[ -n $(key "$f" "$CLASS_KEY") ]] || { echo "'$cls' is already claimed by $f, skipping"; return 0; }
	done < <(grep -rlixF --include='*.desktop' "StartupWMClass=$cls" "${dirs[@]}" 2>/dev/null)

	put "$APPDIR/$cls.desktop" "$(copy_of "$id" "$APPDIR/steam_app_$id.desktop" \
		"StartupWMClass=$(esc "$cls")" "$CLASS_KEY=$id")" && echo "learned '$cls' -> steam_app_$id"
	return 0
}

if [[ ${1:-} == --learn ]]; then
	[[ $# -eq 3 ]] || { echo "usage: $0 --learn <class> <pid>" >&2; exit 2; }
	[[ -d $APPDIR ]] || exit 0
	learn "$2" "$3"
else
	sync
fi

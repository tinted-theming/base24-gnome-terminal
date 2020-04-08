#!/usr/bin/env bash


# Cupcake - Gnome Terminal color scheme install script for Base24
# Chris Kempson (http://chriskempson.com)

[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="Base 16 Cupcake"
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="base-16-cupcake"
[[ -z "$DCONF" ]] && DCONF=dconf
[[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

dset() {
    local key="$1"; shift
    local val="$1"; shift

    if [[ "$type" == "string" ]]; then
        val="'$val'"
    fi

    "$DCONF" write "$PROFILE_KEY/$key" "$val"
}

# Because dconf still doesn't have "append"
dlist_append() {
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "'$val'"
        } | head -c-1 | tr "\n" ,
    )"

    "$DCONF" write "$key" "[$entries]"
}

# Newest versions of gnome-terminal use dconf
if which "$DCONF" > /dev/null 2>&1; then
    # Check that uuidgen is available
    type $UUIDGEN >/dev/null 2>&1 || { echo >&2 "Requires uuidgen but it's not installed.  Aborting!"; exit 1; }

    [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

    if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then
        if which "$UUIDGEN" > /dev/null 2>&1; then
            PROFILE_SLUG=`uuidgen`
        fi

        if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
            DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
        else
            DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
        fi

        DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
        PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

        # Copy existing settings from default profile
        $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

        # Add new copy to list of profiles
        dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

        # Update profile values with theme options
        dset visible-name "'$PROFILE_NAME'"
        dset palette "['#f2f1f4', '#D57E85', '#A3B367', '#EBB790', '#7297B9', '#BB99B4', '#69A9A7', '#72677E', '#d8d5dd', '#D57E85', '#A3B367', '#DCB16C', '#7297B9', '#BB99B4', '#69A9A7', '#585062']"
        dset background-color "'#fbf1f2'"
        dset foreground-color "'#8b8198'"
        dset bold-color "'#8b8198'"
        dset bold-color-same-as-fg "true"
        dset cursor-colors-set "true"
        dset cursor-background-color "'#8b8198'"
        dset cursor-foreground-color "'#f2f1f4'"
        dset use-theme-colors "false"
        dset use-theme-background "false"

        unset PROFILE_NAME
        unset PROFILE_SLUG
        unset DCONF
        unset UUIDGEN
        exit 0
    fi
fi

# Fallback for Gnome 2 and early Gnome 3
[[ -z "$GCONFTOOL" ]] && GCONFTOOL=gconftool
[[ -z "$BASE_KEY" ]] && BASE_KEY=/apps/gnome-terminal/profiles

PROFILE_KEY="$BASE_KEY/$PROFILE_SLUG"

gset() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    "$GCONFTOOL" --set --type "$type" "$PROFILE_KEY/$key" -- "$val"
}

# Because gconftool doesn't have "append"
glist_append() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$GCONFTOOL" --get "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "$val"
        } | head -c-1 | tr "\n" ,
    )"

    "$GCONFTOOL" --set --type list --list-type $type "$key" "[$entries]"
}

# Append the Base24 profile to the profile list
glist_append string /apps/gnome-terminal/global/profile_list "$PROFILE_SLUG"

gset string visible_name "$PROFILE_NAME"
gset string palette "#f2f1f4:#D57E85:#A3B367:#EBB790:#7297B9:#BB99B4:#69A9A7:#72677E:#d8d5dd:#D57E85:#A3B367:#DCB16C:#7297B9:#BB99B4:#69A9A7:#585062"
gset string background_color "#fbf1f2"
gset string foreground_color "#8b8198"
gset string bold_color "#8b8198"
gset bool   bold_color_same_as_fg "true"
gset bool   cursor-colors-set "true"
gset string cursor-background-color "'#8b8198'"
gset string cursor-foreground-color "'#f2f1f4'"
gset bool   use_theme_colors "false"
gset bool   use_theme_background "false"

unset PROFILE_NAME
unset PROFILE_SLUG
unset DCONF
unset UUIDGEN

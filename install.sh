#!/bin/bash
set -e

## These functions were borrowed from Zach Holman. Thanks Zach!

info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

setup_dvcsconfig () {
  if [[ !( -f git/gitconfig ) ]] || [[ ! (-f hg/hgrc) ]]
  then
    info 'setup dvcs config'

    credential='cache'
    if [ "$(uname -s)" == "Darwin" ]
    then
      credential='osxkeychain'
    fi

    user ' - What is your DVCS (git & hg) author name?'
    read -e authorname
    user ' - What is your DVCS (git & hg) author email?'
    read -e authoremail

    sed -e "s/AUTHORNAME/$authorname/g" -e "s/AUTHOREMAIL/$authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$credential/g" git/gitconfig.example > git/gitconfig
    sed -e "s/AUTHORNAME/$authorname/g" -e "s/AUTHOREMAIL/$authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$credential/g" hg/hgrc.example > hg/hgrc

    success 'dvcs config'
  fi
}

link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

# End files borrowed / adapted from Zach

setup_dotfiles () {
    local overwrite_all=false backup_all=false skip_all=false

    link_file "`pwd`/editors/vim/vimrc" "$HOME/.vimrc"

    link_file "`pwd`/gpg/gpg.conf" "$HOME/.gnupg/gpg.conf"
    link_file "`pwd`/gpg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"

    # ZSH`
    link_file "`pwd`/shell/zshrc" "$HOME/.zshrc"

    # Bash
    link_file "`pwd`/shell/bashrc" "$HOME/.bashrc"
    link_file "`pwd`/shell/bash_profile" "$HOME/.bash_profile"
    link_file "`pwd`/shell/liquidpromptrc" "$HOME/.config/liquidpromptrc"

    # Shated shell stuff
    link_file "`pwd`/shell/aliases" "$HOME/.aliases"
    link_file "`pwd`/shell/dockerfunc" "$HOME/.dockerfunc"
    link_file "`pwd`/shell/paths" "$HOME/.paths"


    link_file "`pwd`/git/gitconfig" "$HOME/.gitconfig"
    link_file "`pwd`/hg/hgrc" "$HOME/.hgrc"

    if type "atom" > /dev/null; then
        link_file "`pwd`/editors/atom/config.cson" "$HOME/.atom/config.cson"
        link_file "`pwd`/editors/atom/keymap.cson" "$HOME/.atom/keymap.cson"
        link_file "`pwd`/editors/atom/snippets.cson" "$HOME/.atom/snippets.cson"
        link_file "`pwd`/editors/atom/init.coffee" "$HOME/.atom/init.coffee"
        link_file "`pwd`/editors/atom/styles.less" "$HOME/.atom/styles.less"

        apm starred --user mark-adams --install
    fi

    if type "code" > /dev/null; then
      link_file "`pwd`/editors/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
    fi
}

setup_dvcsconfig
setup_dotfiles

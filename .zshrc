# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Export the PATH variable to include common directories
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
# Zsh configuration file for Oh My Zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Tooling and Environment Configuration
# ====================================================================

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
#Rustup Toolchain
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
#Ruby On Rails 
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# Added by LM Studio CLI (lms)
export PATH="$PATH:${HOME}/.lmstudio/bin"
#NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#Ensure nvm bin directory is at the front of the PATH
export PATH="$NVM_DIR/versions/node/v22.0.0/bin:$PATH"
# Mise
eval "$(~/.local/bin/mise activate)"
#Anaconda
 export PATH=$PATH:"/opt/homebrew/anaconda3/bin/"
#Python
#export PATH="$HOME/Library/Python/3.12/bin:$PATH"
#export PYTHONPATH="$HOME/Library/Python/3.12/lib/python/site-packages:$PYTHONPATH"

#NeoVim 
alias base='NVIM_APPNAME=basevim nvim'
#git alias
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gl="git log --oneline --graph --decorate --all"
# brew alias
alias start_postgres="brew services start postgresql@14"
alias stop_postgres="brew services stop postgresql@14"
# Rails alias
alias rails_server="bin/rails server"
#Python
alias dev="python manage.py tailwind start & python manage.py runserver"
# dotfiles alias
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="amuse"
#ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
 zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
#Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

#plugins=(git brew vscode nvm python zsh-interactive-cd zsh-navigation-tools zsh-autosuggestions zsh-syntax-highlighting )
plugins+=(zsh-nvm)
source $ZSH/oh-my-zsh.sh

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# shellcheck shell=bash

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
\builtin typeset -ga precmd_functions
\builtin typeset -ga chpwd_functions
# shellcheck disable=SC2034,SC2296
precmd_functions=("${(@)precmd_functions:#__zoxide_hook}")
# shellcheck disable=SC2034,SC2296
chpwd_functions=("${(@)chpwd_functions:#__zoxide_hook}")
chpwd_functions+=(__zoxide_hook)

# Report common issues.
function __zoxide_doctor() {
    [[ ${_ZO_DOCTOR:-1} -ne 0 ]] || return 0
    [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] || return 0

    _ZO_DOCTOR=0
    \builtin printf '%s\n' \
        'zoxide: detected a possible configuration issue.' \
        'Please ensure that zoxide is initialized right at the end of your shell configuration file (usually ~/.zshrc).' \
        '' \
        'If the issue persists, consider filing an issue at:' \
        'https://github.com/ajeetdsouza/zoxide/issues' \
        '' \
        'Disable this message by setting _ZO_DOCTOR=0.' \
        '' >&2
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z() {
    __zoxide_doctor
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    elif [[ "$#" -eq 2 ]] && [[ "$1" = "--" ]]; then
        __zoxide_cd "$2"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    __zoxide_doctor
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

function z() {
    __zoxide_z "$@"
}

function zi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            # Show completions for local directories.
            _cd -/

        elif [[ "${words[-1]}" == '' ]]; then
            # Show completions for Space-Tab.
            # shellcheck disable=SC2086
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})" || __zoxide_result=''

            # Set a result to ensure completion doesn't re-run
            compadd -Q ""

            # Bind '\e[0n' to helper function.
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            # Sends query device status code, which results in a '\e[0n' being sent to console input.
            \builtin printf '\e[5n'

            # Report that the completion was successful, so that we don't fall back
            # to another completion function.
            return 0
        fi
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            # shellcheck disable=SC2034,SC2296
            BUFFER="z ${(q-)__zoxide_result}"
            __zoxide_result=''
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete z
fi

# =============================================================================
#
# To initialize zoxide, add this to your shell configuration file (usually ~/.zshrc):
#
 eval "$(zoxide init zsh)"


#EDITOR = 'nvim'
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='nvim'
 fi
 
# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension.Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#Example alias 
# alias ohmyzsh="mate ~/.oh-my-zsh"

#UV 
. "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
# tat: tmux attach
function tat {
  name=$(basename `pwd` | sed -e 's/\.//g')

  if tmux ls 2>&1 | grep "$name"; then
    tmux attach -t "$name"
  elif [ -f .envrc ]; then
    direnv exec / tmux new-session -s "$name"
  else
    tmux new-session -s "$name"
  fi
}
#Launch Cursor.AI
function cursor {
  open -a "/Applications/Cursor.app" "$@"
}
#Launch Zed 
function zed {
  open -a "/Applications/Zed.app" "$@"
}
# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

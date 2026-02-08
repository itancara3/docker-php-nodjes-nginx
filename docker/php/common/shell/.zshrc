autoload -Uz colors && colors
autoload -Uz compinit && compinit
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt PROMPT_SUBST

git_branch() {
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ -z "$branch" ] || [ "$branch" = "HEAD" ] && branch=$(git describe --tags --always 2>/dev/null)
    echo "%B%F{33}git:(%f%F{203}${branch}%f%F{33})%f%b"
  fi
}

php_ver() {
  local ver
  ver=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null)
  [ -n "$ver" ] && echo "%B%F{19}php:${ver}%f%b"
}

node_ver() {
  local ver
  ver=$(node -v 2>/dev/null | sed 's/^v//')
  [ -n "$ver" ] && echo "%B%F{40}node:${ver}%f%b"
}

PROMPT='%F{green}>%f  %B%F{cyan}%~%f%b  $(git_branch)  $(php_ver)  $(node_ver)
%# '

export COMPOSER_ALLOW_SUPERUSER=1
export COMPOSER_HOME=/root/.composer
export PATH="$PATH:/root/.composer/vendor/bin"

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias artisan='php artisan'
alias nr='npm run'
alias nb='npm run build'
alias nd='npm run dev'

alias xon='export XDEBUG_MODE=debug,develop && echo "XDEBUG_MODE=$XDEBUG_MODE"'
alias xoff='unset XDEBUG_MODE && echo "XDEBUG_MODE (unset)"'

alias gpl='git pull'
alias gph='git push'
alias ci='composer install'
alias cu='composer update'

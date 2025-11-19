# ====== Inicialización ======
autoload -Uz colors && colors
autoload -Uz compinit && compinit
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt PROMPT_SUBST

# ====== Funciones dinámicas ======

# Rama git (🌿 con color #FB8C00)
git_branch() {
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ -z "$branch" || "$branch" = "HEAD" ]] && branch=$(git describe --tags --always 2>/dev/null)
    echo "%B 🌿 %F{#0087d7}git:(%f%F{#ff5f5f}${branch}%f%F{#0087d7})%f%b"   # 208 ≈ #FB8C00
  fi
}

# Versión PHP (🐘 con color #0D47A1)
php_ver() {
  local ver=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null)
  [[ -n "$ver" ]] && echo "%B%F{19}🐘 php: ${ver}%f%b"   # 19 ≈ #0D47A1
}

# Versión Node.js (🟢 con color #4CAF50)
node_ver() {
  local ver=$(node -v 2>/dev/null | sed 's/^v//')
  [[ -n "$ver" ]] && echo "%B%F{#00af5f}🟢 nodejs: ${ver}%f%b"   # 40 ≈ #4CAF50
}

# ====== Prompt ======
# Ejemplo: ➜  /var/www/html  🌿 main  🐘 8.4  🟢 22.11.0
PROMPT='%F{green}➜%f  %B%F{cyan}%~%f%b  $(git_branch)  $(php_ver)  $(node_ver)
%# '

# ====== Composer / Laravel ======
export COMPOSER_ALLOW_SUPERUSER=1
export COMPOSER_HOME=/root/.composer
export PATH="$PATH:/root/.composer/vendor/bin"

# ====== Alias útiles ======
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias artisan='php artisan'
alias nr='npm run'
alias nb='npm run build'
alias nd='npm run dev'

# ====== Xdebug rápido ======
alias xon='export XDEBUG_MODE=debug,develop && echo "XDEBUG_MODE=$XDEBUG_MODE"'
alias xoff='unset XDEBUG_MODE && echo "XDEBUG_MODE (unset)"'

# ====== Git y Composer ======
alias gpl='git pull'
alias gph='git push'
alias ci='composer install'
alias cu='composer update'

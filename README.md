# shell-utils

Colección unificada de alias y funciones para shell, diseñada para ser portátil entre macOS, Linux y WSL.  
Este repositorio centraliza únicamente la lógica útil (alias, funciones y atajos de Git), evitando dependencias con dotfiles, Stow o configuraciones específicas de cada sistema.

## Estructura

```
shell-utils/
  README.md
  zsh/
    aliases-builtin.zsh
    aliases-bugbounty.zsh
    functions-bugbounty.zsh
  git/
    git-aliases.conf
```

## Uso

Clonar el repositorio:

```bash
git clone https://github.com/theoffsecgirl/shell-utils.git ~/shell-utils
```

Añadir en `~/.zshrc`:

```zsh
export SHELL_UTILS="$HOME/shell-utils"

[ -f "$SHELL_UTILS/zsh/aliases-builtin.zsh" ] && source "$SHELL_UTILS/zsh/aliases-builtin.zsh"
[ -f "$SHELL_UTILS/zsh/aliases-bugbounty.zsh" ] && source "$SHELL_UTILS/zsh/aliases-bugbounty.zsh"
[ -f "$SHELL_UTILS/zsh/functions-bugbounty.zsh" ] && source "$SHELL_UTILS/zsh/functions-bugbounty.zsh"
```

Recargar configuración:

```bash
source ~/.zshrc
```

## Alias de Git

Incluir en `~/.gitconfig`:

```ini
[include]
    path = ~/shell-utils/git/git-aliases.conf
```

## Compatibilidad multiplataforma

Definir plataforma antes de cargar alias y funciones (solo si no se detecta en los propios archivos):

```zsh
case "$(uname -s)" in
  Linux*) PLATFORM=linux ;;
  Darwin*) PLATFORM=macos ;;
  *) PLATFORM=other ;;
esac

export PLATFORM
```

## Mantenimiento

- Alias generales: `zsh/aliases-builtin.zsh`
- Alias de seguridad ofensiva: `zsh/aliases-bugbounty.zsh`
- Funciones: `zsh/functions-bugbounty.zsh`
- Alias de Git: `git/git-aliases.conf`

El objetivo es mantener este repositorio como una librería estable, limpia y portable, desacoplada de cualquier configuración local y adaptable a cualquier entorno.

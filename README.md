# shell-utils

Colección unificada de alias y funciones para shell, diseñada para ser portátil entre macOS, Linux y WSL.

Este repositorio centraliza únicamente la lógica útil (alias, funciones y atajos de Git), evitando dependencias con dotfiles, Stow o configuraciones específicas de cada sistema.

---

## Estructura

```text
shell-utils/
  README.md
  zsh/
    aliases-builtin.zsh
    aliases-bugbounty.zsh
    functions-bugbounty.zsh
  git/
    git-aliases.conf
````

---

## Requisitos

Para usar este repositorio de forma razonable necesitas:

* **Sistema operativo**

  * macOS, cualquier distribución Linux moderna o WSL.
* **Shell**

  * `zsh` como shell por defecto (o, al menos, disponible).
* **Git**

  * `git` instalado y configurado si quieres usar los alias de Git.
* **Herramientas externas**

  * Algunos alias y funciones llaman a utilidades de línea de comandos habituales en entornos de seguridad ofensiva
    (recon, HTTP, etc.).
    El repositorio **no instala** estas herramientas: asume que ya las tienes en tu `$PATH`.

No hay script de instalación automática: la integración se hace de forma explícita en tu `~/.zshrc` y `~/.gitconfig`.

---

## Uso (Zsh)

Clonar el repositorio:

```bash
git clone https://github.com/theoffsecgirl/shell-utils.git ~/shell-utils
```

Definir la ruta base en `~/.zshrc`:

```bash
export SHELL_UTILS="$HOME/shell-utils"
```

Cargar alias y funciones:

```bash
[ -f "$SHELL_UTILS/zsh/aliases-builtin.zsh" ] && source "$SHELL_UTILS/zsh/aliases-builtin.zsh"
[ -f "$SHELL_UTILS/zsh/aliases-bugbounty.zsh" ] && source "$SHELL_UTILS/zsh/aliases-bugbounty.zsh"
[ -f "$SHELL_UTILS/zsh/functions-bugbounty.zsh" ] && source "$SHELL_UTILS/zsh/functions-bugbounty.zsh"
```

Recargar configuración:

```bash
source ~/.zshrc
```

---

## Alias de Git

Para usar los alias de Git, incluye el fichero de configuración en tu `~/.gitconfig`:

```ini
[include]
    path = ~/shell-utils/git/git-aliases.conf
```

---

## Compatibilidad multiplataforma

La variable `PLATFORM` permite ajustar el comportamiento de algunos alias/funciones según el sistema.

Puedes definirla en tu `~/.zshrc` antes de cargar los archivos de `shell-utils`:

```bash
case "$(uname -s)" in
  Linux*)  PLATFORM=linux ;;
  Darwin*) PLATFORM=macos ;;
  *)       PLATFORM=other ;;
esac

export PLATFORM
```

---

## Mantenimiento

* Alias generales: `zsh/aliases-builtin.zsh`
* Alias de seguridad ofensiva: `zsh/aliases-bugbounty.zsh`
* Funciones: `zsh/functions-bugbounty.zsh`
* Alias de Git: `git/git-aliases.conf`

El objetivo es mantener este repositorio como una librería estable, limpia y portable, desacoplada de cualquier configuración local y adaptable a cualquier entorno.

```

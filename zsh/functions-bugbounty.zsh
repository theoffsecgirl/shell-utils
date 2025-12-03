# Funciones de seguridad ofensiva, proyectos y utilidades avanzadas

# Actualización de sistema según plataforma/distro
update_system() {
    if [[ "$PLATFORM" == "macos" ]]; then
        brew update && brew upgrade && brew cleanup
        softwareupdate -l
    else
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
        elif command -v dnf &> /dev/null; then
            sudo dnf upgrade -y && sudo dnf autoremove -y
        elif command -v pacman &> /dev/null; then
            sudo pacman -Syu --noconfirm
        fi
    fi
}
alias update='update_system'

# FUNCION MKPROJECT 
# Crea proyecto y subcarpetas a tu elección
# Uso: mkproject nombre_proyecto [subcarpeta1 subcarpeta2 ...]
mkproject() {
    if [[ -z "$1" ]]; then
        echo "Tienes que indicar el nombre del proyecto!"
        return 1
    fi
    project_name="$1"
    shift

    if [[ "$#" -eq 0 ]]; then
        mkdir -p "$project_name"
        echo "Proyecto '$project_name' creado (sin subcarpetas)."
    else
        for sub in "$@"; do
            mkdir -p "$project_name/$sub"
        done
        echo "Proyecto '$project_name' creado con subcarpetas: $*"
    fi
}

# Inicializa proyectos con estructura y archivos base según plantilla
# Uso: mkproject_template nombre_proyecto plantilla
# Plantillas: docencia, bugbounty, ctf
mkproject_template() {
    if [[ $# -lt 2 ]]; then
        echo "Uso: mkproject_template nombre_proyecto plantilla"
        echo "Plantillas disponibles: docencia, bugbounty, ctf"
        return 1
    fi
    local proj="$1"
    local tpl="$2"

    case "$tpl" in
        docencia)
            mkdir -p "$proj"/{actividades,labs,scripts}
            {
              echo "# Docencia: $proj"
              echo "- Actividades: ejercicios y tareas"
              echo "- Labs: prácticas guiadas"
              echo "- Scripts: utilidades y herramientas"
            } > "$proj/README.md"
            ;;
        bugbounty)
            mkdir -p "$proj"/{recon,enumeration,scans,exploits,pocs,wordlists,screenshots,notes,reports,loot}
            {
              echo "# Bug Bounty: $proj"
              echo "- Recon: subdominios/hosts"
              echo "- Enumeration: info detallada"
              echo "- Scans: nmap, nuclei, ffuf…"
              echo "- Exploits/Pocs: scripts o PoCs"
              echo "- Wordlists: listas específicas"
              echo "- Screenshots: pruebas visuales"
              echo "- Notes: findings y procesos"
              echo "- Reports: borradores y entregables"
              echo "- Loot: credenciales, datos…"
            } > "$proj/README.md"
            ;;
        ctf)
            mkdir -p "$proj"/{src,flags,writeups,notes}
            {
              echo "# CTF: $proj"
              echo "- src: exploits/scripts"
              echo "- flags: resultados CTF"
              echo "- writeups: soluciones"
              echo "- notes: apuntes rápidos"
            } > "$proj/README.md"
            ;;
        *)
            echo "Plantilla desconocida: $tpl"
            echo "Opciones válidas: docencia, bugbounty, ctf"
            return 2
            ;;
    esac
    echo "Proyecto '$proj' creado con plantilla '$tpl'."
}

# Descompresión automática según extensión
extra() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.tar.xz)    tar xJf "$1"   ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.rar)       unrar x "$1"   ;;
            *.7z)        7z x "$1"      ;;
            *.gz)        gunzip "$1"    ;;
            *.bz2)       bunzip2 "$1"   ;;
            *)           echo "'$1' no puede ser extraído vía extra()" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# Extrae todas las IPs únicas de los archivos del directorio actual
extractips() {
    grep -Eroh '([0-9]{1,3}\.){3}[0-9]{1,3}' . | sort -u
}

# Crea y activa un entorno virtual de Python en la carpeta actual
quickvenv() {
    python3 -m venv .venv && source .venv/bin/activate
    echo "Virtualenv .venv activado"
}

# Busca recursivamente el primer directorio coincidente y entra
gotodir() {
    dir=$(find . -type d -iname "*$1*" | head -n 1)
    if [[ -d "$dir" ]]; then
        cd "$dir"
        echo "Entro en $dir"
    else
        echo "No encontrado"
    fi
}

# Actualiza sistema, pip y plugins de Neovim
updateall() {
    update_system
    pip3 install --upgrade pip setuptools wheel
    if command -v nvim &>/dev/null; then
        nvim --headless "+Lazy! sync" +qa
    fi
    echo "Todo actualizado: sistema, pip y plugins de Neovim (si hay)."
}

# Escaneo de subdominios en vivo (subfinder + httpx)
subscan() {
    if [ -z "$1" ]; then
        echo "Uso: subscan <dominio.com>"
        return 1
    fi

    python3 - "$1" <<'PYCODE'
import sys, shutil, subprocess, threading, json, signal, socket
from urllib.parse import urlparse
from functools import lru_cache

def tty(): return sys.stdout.isatty()
def c(s, code): return f"[{code}m{s}[0m" if tty() else s
BOLD=lambda s:c(s,"1"); RED=lambda s:c(s,"31"); GRN=lambda s:c(s,"32")
YEL=lambda s:c(s,"33"); BLU=lambda s:c(s,"34"); CYN=lambda s:c(s,"36")

PORTS = "80,443,8080,8443"
HTTPX_ARGS = [
    'httpx','-silent','-follow-redirects','-status-code','-title','-ip','-ports',PORTS,'-json','-threads','200'
]

stop_event = threading.Event()
def handle_sigint(sig, frame):
    stop_event.set()
    print(YEL("\n[!] Interrumpido por el usuario"))
signal.signal(signal.SIGINT, handle_sigint)
signal.signal(signal.SIGTERM, handle_sigint)

def truncate(s, n):
    s = (s or '').replace('\r',' ').replace('\n',' ')
    return s if len(s)<=n else s[:n-1]+'…'

def check_deps():
    missing=[]
    for bin in ['subfinder','httpx']:
        if not shutil.which(bin): missing.append(bin)
    if missing:
        print(RED('[x] Faltan dependencias: ')+', '.join(missing))
        print(YEL('  → Instala en macOS: brew install projectdiscovery/tap/subfinder projectdiscovery/tap/httpx'))
        sys.exit(1)

@lru_cache(maxsize=512)
def resolve_ip(host):
    if not host: return '-'
    try:
        infos = socket.getaddrinfo(host, None, proto=socket.IPPROTO_TCP)
        ipv4 = next((ai[4][0] for ai in infos if ai[0] == socket.AF_INET), None)
        return ipv4 or infos[0][4][0] if infos else '-'
    except Exception:
        return '-'

def extract_ip(obj):
    ip = obj.get('ip')
    if ip and isinstance(ip, str) and ip.strip():
        return ip.strip()
    a = obj.get('a')
    if isinstance(a, list) and a:
        return str(a[0])
    url = obj.get('url') or ''
    host = urlparse(url).hostname
    return resolve_ip(host)

def main(domain):
    check_deps()
    print(BOLD(CYN(f"\n▌ Subdomain scan ({domain}) — subfinder → httpx\n")))
    print(BOLD(f"{'STATUS':<8} │ {'URL':<60} │ {'TITLE':<45} │ IP"))

    sf = subprocess.Popen(['subfinder','-silent','-d',domain], stdout=subprocess.PIPE, text=True)
    hx = subprocess.Popen(HTTPX_ARGS, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)

    def feeder():
        try:
            for line in sf.stdout:
                if stop_event.is_set(): break
                sub = line.strip()
                if sub:
                    try:
                        hx.stdin.write(sub+'\n')
                        hx.stdin.flush()
                    except BrokenPipeError:
                        break
        finally:
            try: hx.stdin.close()
            except Exception: pass

    threading.Thread(target=feeder, daemon=True).start()

    try:
        for line in hx.stdout:
            if stop_event.is_set(): break
            line=line.strip()
            if not line: continue
            try: obj=json.loads(line)
            except: continue
            status=obj.get('status_code','-'); url=obj.get('url','-'); title=obj.get('title','-'); ip=extract_ip(obj)
            s=int(status) if str(status).isdigit() else 0
            if 200<=s<300: scol=GRN
            elif 300<=s<400: scol=CYN
            elif 400<=s<600: scol=RED
            else: scol=BLU
            print(f"{scol(f'[{status}]'):<8} │ {truncate(url,60):<60} │ {truncate(title,45):<45} │ {ip}", flush=True)
    finally:
        for p in (sf,hx):
            try:
                if p.poll() is None:
                    p.terminate(); p.wait(timeout=2)
            except Exception: pass

if __name__ == '__main__':
    main(sys.argv[1])
PYCODE
}

# FFUF directo sobre un host → descubre directorios
ffufdirs() {
    ffuf -u "https://$1/FUZZ"          -w "$WORDLISTS/fuzz4bounty/fuzz4bounty/dirsearch.txt"          -of md -o "ffuf_DIRS_$(date +%F_%H%M).md"
}

# FFUF sobre parámetros → prueba injection points
ffufparams() {
    ffuf -u "https://$1/page.php?FUZZ=1"          -w "$WORDLISTS/fuzz4bounty/discovery/parameter.txt"          -of md -o "ffuf_PARAMS_$(date +%F_%H%M).md"
}

# Descubrimiento de subdominios optimizado para bug bounty
subfinderall() {
    command subfinder -d "$1" -all -t 100 -v -o "subs_${1}.txt"
}

# Crea carpeta y archivo .md para writeup de CTF
ctfwriteup() {
    mkdir -p "$1" && echo "# $1" > "$1/writeup.md" && nvim "$1/writeup.md"
}

# Lista y busca alias definidos fácilmente
aliases() {
    if [[ -z "$1" ]]; then
        alias | sort
    else
        alias | grep -i --color "$1"
    fi
}

# Funciones de seguridad ofensiva, recon y utilidades

recon_basic() {
    if [ -z "$1" ]; then
        echo "Uso: recon_basic <dominio>"
        return 1
    fi

    TARGET="$1"
    echo "[+] Enumerando subdominios de $TARGET"
    subfinder -silent -d "$TARGET" | tee "$TARGET-subs.txt"

    echo "[+] Comprobando hosts activos"
    httpx -silent -l "$TARGET-subs.txt" | tee "$TARGET-live.txt"
}

new_target() {
    if [ -z "$1" ]; then
        echo "Uso: new_target <nombre>"
        return 1
    fi

    mkdir -p "$HOME/bugbounty/$1"/{recon,scans,notes,loot}
    echo "[+] Estructura creada en ~/bugbounty/$1"
}

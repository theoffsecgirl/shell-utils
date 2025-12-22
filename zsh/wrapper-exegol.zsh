# Wrapper para ejecutar herramientas ofensivas dentro de Exegol.
# Centraliza toda la ejecución de hacking en el contenedor (imagen free),
# manteniendo el host limpio y evitando dependencias locales.
#
# Uso:
#   ex nmap -sC -sV target.com
#   ex ffuf -u https://target/FUZZ -w wordlist.txt
ex() { exegol exec free -- "$@"; }

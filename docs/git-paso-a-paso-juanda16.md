# Paso a paso: llave SSH para GitHub **Juanda16** y push del proyecto

Ruta local del proyecto: `/Users/juan_arismendy/personal/udea/Practica final`  
Repositorio GitHub: `Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos`  
Correo sugerido en la llave (identificador, no inicia sesión): `juan.arismendy@udea.edu.co`

---

## 1. Crear una llave nueva (solo para la cuenta Juanda16)

En **Terminal** (no hace falta estar dentro del proyecto todavía).

```bash
# Carpeta de llaves (por defecto en Mac)
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generar llave dedicada (nombre distinto a la del trabajo)
ssh-keygen -t ed25519 -C "juan.arismendy@udea.edu.co" -f ~/.ssh/id_ed25519_github_juanda16
```

- Cuando pregunte *passphrase*, puedes dejarla vacía (Enter) o poner una frase (más seguro si la Mac se comparte).
- **No** sobrescribas archivos que ya existan (`id_rsa`, `id_ed25519`, etc.); por eso el nombre `id_ed25519_github_juanda16` es fijo en esta guía.

---

## 2. Copiar la clave **pública** para pegarla en GitHub

```bash
cat ~/.ssh/id_ed25519_github_juanda16.pub
```

Selecciona toda la línea (empieza por `ssh-ed25519` y termina en el comentario) y cópiala.

**Opcional (copia al portapapeles):**

```bash
pbcopy < ~/.ssh/id_ed25519_github_juanda16.pub
```

Luego en el navegador, con la sesión de GitHub en la cuenta **Juanda16**:

1. **Settings** (avatar arriba a la derecha) → **SSH and GPG keys**  
2. **New SSH key**  
3. Título: por ejemplo `Mac personal UdeA`  
4. Pega el contenido de `.pub` → **Add SSH key**

---

## 3. Probar que GitHub reconoce la cuenta Juanda16

```bash
ssh -i ~/.ssh/id_ed25519_github_juanda16 -o IdentitiesOnly=yes -T git@github.com
```

La primera vez preguntará *Are you sure you want to continue connecting* → escribe `yes` y Enter.

Debe aparecer algo como: **Hi Juanda16! You've successfully authenticated...**

Si dice **Hi juand-arismendy** (u otro usuario), esa llave está asociada a otra cuenta en GitHub: revisa que pegaste la `.pub` correcta en **Juanda16**.

---

## 4. Ir al proyecto y forzar esta llave solo en este repositorio

Así no cambias la configuración global del Mac ni la de otros repos.

```bash
cd "/Users/juan_arismendy/personal/udea/Practica final"

git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_github_juanda16 -o IdentitiesOnly=yes"

git remote -v
```

El remoto debe verse así (SSH hacia `github.com`):

```text
origin  git@github.com:Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos.git (fetch)
origin  git@github.com:Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos.git (push)
```

Si no coincide, corrígelo:

```bash
git remote set-url origin git@github.com:Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos.git
```

---

## 5. Ver identidad de commits (solo este repo; ya debería estar)

```bash
git config --local user.name
git config --local user.email
```

Esperado para commits académicos:

- `Juan David Arismendy Pulgarín`
- `juan.arismendy@udea.edu.co`

Si no:

```bash
git config --local user.name "Juan David Arismendy Pulgarín"
git config --local user.email "juan.arismendy@udea.edu.co"
```

---

## 6. Subir la rama `main` a GitHub

```bash
cd "/Users/juan_arismendy/personal/udea/Practica final"
git status
git push -u origin main
```

Si el remoto estaba vacío, con esto queda publicado el historial local.

---

## 7. Comprobar en la web

Abre: [https://github.com/Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos](https://github.com/Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos)

Deberías ver commits, ramas y archivos.

---

## 8. (Opcional) Quitar la regla solo de este repo

Si algún día quieres que este directorio vuelva a usar el SSH por defecto del sistema:

```bash
cd "/Users/juan_arismendy/personal/udea/Practica final"
git config --unset core.sshCommand
```

Luego tendrías que usar otra forma (p. ej. `Host github-udea` en `~/.ssh/config`) para no mezclar cuentas.

---

## Resumen de archivos importantes

| Archivo | Uso |
|---------|-----|
| `~/.ssh/id_ed25519_github_juanda16` | Llave **privada** (no compartir, no subir a git) |
| `~/.ssh/id_ed25519_github_juanda16.pub` | Llave **pública** (sí va en GitHub) |

Más contexto y alternativa con `~/.ssh/config`: [configuracion-git-mac.md](configuracion-git-mac.md).

# Git en Mac: proyecto académico vs trabajo (cuentas separadas)

Hay **dos cosas distintas**: (1) **quién firma los commits** (`user.name` / `user.email`) y (2) **cómo te autenticas contra GitHub** (SSH o HTTPS + token). Los proyectos laborales no se alteran si **no cambias** `~/.gitconfig` global y usas **SSH con otro host alias** o **includeIf** solo bajo `~/personal/`.

## 1. Identidad del commit (solo este repositorio)

En la raíz de **Practica final** ya está configurado (solo `.git/config`, no global):

```bash
git config user.name "Juan David Arismendy Pulgarín"
git config user.email "juan.arismendy@udea.edu.co"
```

Comprueba con:

```bash
cd "/Users/juan_arismendy/personal/udea/Practica final"
git config --local --list
```

Cualquier otro repo seguirá usando tu `user.*` **global** (p. ej. correo laboral).

**Laura** en su Mac debería poner su propio `git config` local en su clon, con su correo UdeA.

---

## 2. Autenticación: por qué HTTPS con dos cuentas en `github.com` molesta

Con **HTTPS**, el llavero (`osxkeychain`) suele guardar credenciales **por host** (`github.com`). Alternar dos cuentas en el mismo host provoca mezclas o que pida login en bucle. La solución habitual en Mac es **SSH con dos llaves y dos “hosts” lógicos**.

---

## 3. Recomendación: SSH + alias de host (académico)

### 3.1 Crear una llave solo para GitHub académico

```bash
ssh-keygen -t ed25519 -C "juan.arismendy@udea.edu.co" -f ~/.ssh/id_ed25519_github_udea
```

Añade la **clave pública** (`~/.ssh/id_ed25519_github_udea.pub`) en GitHub: *Settings → SSH and GPG keys* de la **cuenta académica**.

### 3.2 Editar `~/.ssh/config`

Añade un bloque **nuevo** sin quitar el que ya uses para trabajo. Ejemplo:

```ssh-config
# Trabajo (ejemplo: sigue siendo github.com con tu llave habitual)
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519   # o la llave que ya uses para la empresa
  IdentitiesOnly yes

# Académico / personal UdeA — mismo GitHub, otra llave y otra cuenta
Host github-udea
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github_udea
  IdentitiesOnly yes
```

`IdentitiesOnly yes` evita que SSH pruebe todas las llaves del agente y elija la incorrecta.

Prueba:

```bash
ssh -T git@github-udea
```

Debe saludarte con la **cuenta académica**.

### 3.3 Remoto de este proyecto

Al crear el repo en GitHub con la cuenta UdeA, usa el remoto con el **alias** `github-udea`:

```bash
cd "/Users/juan_arismendy/personal/udea/Practica final"
git remote add origin git@github-udea:TU_USUARIO_ACADEMICO/practica-final.git
# si origin ya existe:
# git remote set-url origin git@github-udea:TU_USUARIO_ACADEMICO/practica-final.git

git push -u origin main
```

Los repos laborales siguen con `git@github.com:empresa/...` y no tocan la llave UdeA.

---

## 4. Alternativa: `includeIf` por carpeta (identidad automática)

Si quieres que **todos** los repos bajo `~/personal/udea/` usen nombre y correo UdeA **sin** configurar cada repo a mano, en `~/.gitconfig`:

```ini
[includeIf "gitdir:~/personal/udea/"]
  path = ~/.gitconfig-udea
```

Y en `~/.gitconfig-udea`:

```ini
[user]
  name = Juan David Arismendy Pulgarín
  email = juan.arismendy@udea.edu.co
```

Eso **no** cambia la autenticación; sigues necesitando SSH con host alias o tokens distintos para empujar a GitHub.

---

## 5. Qué no hace falta tocar

- **Global** `user.email` / `user.name`**: déjalos como los del trabajo si así te conviene para el resto de repos.
- **`credential.helper=osxkeychain`**: está bien; el conflicto de dos cuentas en HTTPS se evita usando **SSH** para el repo académico con `github-udea`.
- **`url.*.insteadOf`** en global: si reescribe `https://github.com/` a SSH, el remoto con `git@github-udea:...` **no** pasa por esa regla de `github.com`; sigue siendo válido.

---

## 6. Resumen rápido

| Qué quieres | Dónde |
|-------------|--------|
| Commits con correo UdeA solo aquí | `git config` **local** en Practica final (ya aplicado) |
| Push con cuenta GitHub UdeA sin mezclar con la del trabajo | Remoto `git@github-udea:...` + llave dedicada en `~/.ssh/config` |
| Varios repos académicos con misma identidad | `includeIf` + `~/.gitconfig-udea` |

Si en algún momento `git push` falla por permisos, revisa **qué host** usa el remoto (`git remote -v`) y **qué cuenta** responde `ssh -T git@github-udea`.

---

## 7. Error: `Permission to Juanda16/... denied to otra-cuenta`

Eso indica que **SSH está usando la llave de otra cuenta** (p. ej. laboral o `juand-arismendy`) mientras el repo vive bajo **Juanda16**.

Causas frecuentes en este Mac:

1. Tienes en `~/.gitconfig` una regla **`url.*.insteadOf`** que convierte `https://github.com/...` en SSH hacia `github.com`, y el agente SSH ofrece primero la llave “equivocada”.
2. El remoto apunta a `github.com` pero todas las llaves van al mismo host.

**Solución A (recomendada ya documentada):** remoto `git@github-udea:Juanda16/nombre-repo.git` + bloque `Host github-udea` con la llave registrada en la cuenta **Juanda16**.

**Solución B (solo este repositorio, sin tocar `~/.ssh/config`):** fuerza la llave de Juanda16 al hacer Git en esta carpeta:

```bash
cd "/Users/juan_arismendy/personal/udea/Practica final"
# Crea la llave si aún no existe y súbela a GitHub (cuenta Juanda16)
# ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github_juanda16 -C "tu-correo@ejemplo.com"

git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_github_juanda16 -o IdentitiesOnly=yes"
```

Comprueba la cuenta que responde GitHub:

```bash
ssh -i ~/.ssh/id_ed25519_github_juanda16 -o IdentitiesOnly=yes -T git@github.com
```

Debe decir **Hi Juanda16**. Luego:

```bash
git remote set-url origin git@github.com:Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos.git
git push -u origin main
```

Para **quitar** la regla solo en este clon (volver al comportamiento por defecto de SSH):

```bash
git config --unset core.sshCommand
```

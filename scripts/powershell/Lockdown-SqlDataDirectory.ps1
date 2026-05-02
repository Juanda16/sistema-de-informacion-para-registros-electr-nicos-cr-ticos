<#
.SYNOPSIS
  Restringe ACL NTFS sobre la carpeta de datos de SQL Server (blindaje 21 CFR Part 11).

.DESCRIPTION
  Basado en el procedimiento del manual técnico del proyecto All-Fill / Nova Control:
  - Deshabilita herencia y conserva ACL explícita.
  - Concede Control total a SYSTEM (S-1-5-18) y Administradores (S-1-5-32-544).
  - Elimina reglas cuyo IdentityReference coincide con patrones configurables (p. ej. Users, Everyone).

.PARAMETER Path
  Ruta de la carpeta Data del SQL Server (obtener en SSMS: servidor → Properties → Database Settings).

.PARAMETER RemoveIdentityPatterns
  Lista de subcadenas a buscar en IdentityReference para eliminar la regla (comparación case-insensitive).

.NOTES
  Ejecutar Windows PowerShell o PowerShell 7 **como administrador**.
  Probar primero en entorno de laboratorio: un error de ACL puede impedir el arranque del servicio MSSQL.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string] $Path,

    [string[]] $RemoveIdentityPatterns = @(
        'Users',
        'Everyone',
        'Todos',
        'Authenticated Users'
    )
)

if (-not (Test-Path -LiteralPath $Path)) {
    throw "La ruta no existe: $Path"
}

$acl = Get-Acl -LiteralPath $Path
$acl.SetAccessRuleProtection($true, $true)
Set-Acl -LiteralPath $Path -AclObject $acl

$acl = Get-Acl -LiteralPath $Path

$sysSid = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-18')
$sysRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $sysSid,
    'FullControl',
    'ContainerInherit,ObjectInherit',
    'None',
    'Allow'
)
$acl.SetAccessRule($sysRule)

$adminSid = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')
$adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $adminSid,
    'FullControl',
    'ContainerInherit,ObjectInherit',
    'None',
    'Allow'
)
$acl.SetAccessRule($adminRule)

foreach ($rule in @($acl.Access)) {
    $id = $rule.IdentityReference.Value
    foreach ($pattern in $RemoveIdentityPatterns) {
        if ($id -match [regex]::Escape($pattern)) {
            [void] $acl.RemoveAccessRule($rule)
            break
        }
    }
}

if ($PSCmdlet.ShouldProcess($Path, 'Aplicar ACL restringida')) {
    Set-Acl -LiteralPath $Path -AclObject $acl
    Write-Host 'Blindaje aplicado. Verifique Propiedades > Seguridad de la carpeta.' -ForegroundColor Green
}

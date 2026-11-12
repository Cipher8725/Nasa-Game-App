# Godot Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.7.2 |
| **Release Date** | 2026 (build `ed1daf0bf`) |
| **Project Pinned** | 2026-11-10 |
| **Last Docs Verified** | 2026-11-10 (verificado contra el binario local) |
| **Binary Path (Windows)** | `H:\Godot V4.7.2\Godot_v4.7.2-stable_win64_console.exe` |
| **LLM Knowledge Cutoff** | May 2025 |

## Knowledge Gap Warning

The LLM's training data likely covers Godot up to ~4.3. Versions 4.4, 4.5,
4.6 and 4.7 introduced significant changes that the model does NOT know about.
Always cross-reference this directory before suggesting Godot API calls.

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 4.4 | ~Mid 2025 | MEDIUM | Jolt physics option, FileAccess return types, shader texture type changes |
| 4.5 | ~Late 2025 | HIGH | Accessibility (AccessKit), variadic args, @abstract, shader baker, SMAA |
| 4.6 | Jan 2026 | HIGH | Jolt default, glow rework, D3D12 default on Windows, IK restored |
| 4.7 | 2026 | HIGH | Verificar contra el binario: cambios en `OS`, editor de recursos, etc. |

## Verified Sources

- Official docs: https://docs.godotengine.org/en/stable/
- Godot class reference: https://docs.godotengine.org/en/stable/classes/index.html
- Changelog: https://github.com/godotengine/godot/blob/master/CHANGELOG.md

## Verificación práctica (preferida sobre la documentación)

Antes de usar una API, compruébala contra el binario local. Ejemplo real detectado
en este proyecto:

```gdscript
# Consulta la API real del motor en ejecución.
for method: Dictionary in ClassDB.class_get_method_list("OS", true):
    print(method.get("name", ""))
```

Esto evitó un error de compilación real: `OS.get_unix_time()` **ya no existe en
4.7.2** (ver `deprecated-apis.md`).

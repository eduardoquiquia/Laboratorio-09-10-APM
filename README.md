# Clon de Netflix en Flutter

Laboratorio académico de la Semana 10. Replica la experiencia de Netflix en
web y móvil. No tiene fines comerciales ni relación con Netflix, Inc.; se usa
solo en local y no debe publicarse.

## Ejecutar

```bash
flutter pub get
flutter run -d edge
```

## Pruebas

```bash
flutter analyze
flutter test
```

## Funciones

- Inicio animado y selección de perfiles (crear, renombrar, perfil Niños).
- Billboard, Continuar viendo, Top 10 y filas por género.
- Vista previa al pasar el mouse y detalle con episodios y títulos similares.
- Series, Películas (con filtro de género), Novedades y Mi lista.
- Búsqueda por título, género o elenco, sin distinguir acentos.
- Reproductor simulado con teclado: espacio, flechas, M y Esc.

## Limitaciones

- El catálogo es ficticio y las portadas se generan por código.
- El reproductor no tiene video real.
- Sin backend: Mi lista y el avance se pierden al recargar la página.
- No hay inicio de sesión: la app no pide correos ni contraseñas.

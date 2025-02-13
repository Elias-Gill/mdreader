pub const homeTemplate =
    \\<!DOCTYPE html>
    \\<html lang="en">
    \\<head>
    \\    <meta charset="UTF-8">
    \\    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    \\    <title>Markdown Viewer</title>
    \\    <link rel="stylesheet" href="/assets/styles.css">
    \\</head>
    \\<body>
    \\    <h1>Markdown Viewer</h1>
    \\    <div id="markdown-container">{s}</div>
    \\</body>
    \\</html>
;

pub const CSS =
    \\/* Estilos generales */
    \\body {
    \\    background-color: #1c1c1c; /* bg */
    \\    color: #c9c7cd; /* fg */
    \\    line-height: 1.6;
    \\    margin: 0;
    \\    padding: 2rem;
    \\}
    \\
    \\/* Contenedor principal */
    \\#markdown-container {
    \\    max-width: 800px;
    \\    margin: 0 auto;
    \\    padding: 2rem;
    \\    background-color: #27272a; /* black */
    \\    border-radius: 12px;
    \\    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    \\}
    \\
    \\/* Encabezados */
    \\h1, h2, h3, h4, h5, h6 {
    \\    color: #c9c7cd; /* fg */
    \\    margin-top: 1.5em;
    \\    margin-bottom: 0.5em;
    \\}
    \\
    \\h1 {
    \\    font-size: 2.5rem;
    \\    padding-bottom: 0.3em;
    \\}
    \\
    \\h2 {
    \\    font-size: 2rem;
    \\    padding-bottom: 0.2em;
    \\}
    \\
    \\h3 {
    \\    font-size: 1.75rem;
    \\}
    \\
    \\h4 {
    \\    font-size: 1.5rem;
    \\}
    \\
    \\h5 {
    \\    font-size: 1.25rem;
    \\}
    \\
    \\h6 {
    \\    font-size: 1rem;
    \\    color: #8b8693; /* subtext3 */
    \\}
    \\
    \\/* Párrafos */
    \\p {
    \\    margin: 1em 0;
    \\    color: #c9c7cd; /* fg */
    \\}
    \\
    \\/* Enlaces */
    \\a {
    \\    color: #92a2d5; /* blue */
    \\    text-decoration: none;
    \\    transition: color 0.2s ease;
    \\}
    \\
    \\a:hover {
    \\    color: #a6b6e9; /* bright_blue */
    \\    text-decoration: underline;
    \\}
    \\
    \\/* Listas */
    \\ul, ol {
    \\    margin: 1em 0;
    \\    padding-left: 2em;
    \\}
    \\
    \\li {
    \\    margin: 0.5em 0;
    \\    color: #c9c7cd; /* fg */
    \\}
    \\
    \\/* Código en línea */
    \\code {
    \\    background-color: #353539; /* bright_black */
    \\    color: #90b99f; /* green */
    \\    padding: 0.2em 0.4em;
    \\    border-radius: 4px;
    \\    font-size: 0.9em;
    \\}
    \\
    \\/* Bloques de código */
    \\pre {
    \\    background-color: #353539; /* bright_black */
    \\    padding: 1em;
    \\    border-radius: 8px;
    \\    overflow-x: auto;
    \\    margin: 1.5em 0;
    \\}
    \\
    \\pre code {
    \\    background-color: transparent;
    \\    color: #90b99f; /* green */
    \\    padding: 0;
    \\    font-size: 0.9em;
    \\}
    \\
    \\/* Citas */
    \\blockquote {
    \\    border-left: 4px solid #6c6874; /* subtext4 */
    \\    padding-left: 1em;
    \\    margin: 1.5em 0;
    \\    color: #8b8693; /* subtext3 */
    \\    font-style: italic;
    \\}
    \\
    \\/* Tablas */
    \\table {
    \\    width: 100%;
    \\    border-collapse: collapse;
    \\    margin: 1.5em 0;
    \\}
    \\
    \\th, td {
    \\    padding: 0.75em;
    \\    border: 1px solid #6c6874; /* subtext4 */
    \\    text-align: left;
    \\}
    \\
    \\th {
    \\    background-color: #353539; /* bright_black */
    \\    color: #c9c7cd; /* fg */
    \\}
    \\
    \\/* Líneas horizontales */
    \\hr {
    \\    border: 0;
    \\    height: 1px;
    \\    background-color: #6c6874; /* subtext4 */
    \\    margin: 2em 0;
    \\}
    \\
    \\/* Imágenes */
    \\img {
    \\    max-width: 50%;
    \\    height: auto;
    \\    display: block;     /* Make the image a block-level element */
    \\    border-radius: 8px;
    \\    margin: 1.5em auto;     /* Centra la imagen horizontalmente con margen superior e inferior */
    \\}
    \\
    \\/* Botones (opcional) */
    \\button {
    \\    background-color: #92a2d5; /* blue */
    \\    color: #1c1c1c; /* bg */
    \\    border: none;
    \\    padding: 0.5em 1em;
    \\    border-radius: 6px;
    \\    cursor: pointer;
    \\    transition: background-color 0.2s ease;
    \\}
    \\
    \\button:hover {
    \\    background-color: #a6b6e9; /* bright_blue */
    \\}
;

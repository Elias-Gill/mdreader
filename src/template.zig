pub const homeTemplate =
    \\<!DOCTYPE html>
    \\<html lang="en">
    \\<head>
    \\    <meta charset="UTF-8">
    \\    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    \\    <title>Markdown Viewer</title>
    \\    <style>
    \\        body { font-family: Arial, sans-serif; padding: 20px; background: #1c1c1c; color: #c9c7cd; }
    \\        #markdown-container { white-space: pre-wrap; font-family: monospace; background: #27272a; padding: 10px; border-radius: 8px; }
    \\    </style>
    \\</head>
    \\<body>
    \\    <h1>Markdown Viewer</h1>
    \\    <div id="markdown-container">{s}</div>
    \\</body>
    \\</html>
;

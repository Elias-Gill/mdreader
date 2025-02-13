const std = @import("std");
const net = std.net;
const http = std.http;

const template = @import("template.zig");
const parser = @import("parser.zig");

const Allocator = std.mem.Allocator;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator: Allocator = gpa.allocator();

var flag = std.atomic.Value(bool).init(false);

pub fn stopServer() void {
    flag.store(true, .seq_cst);
}

pub fn startHttpServer() !void {
    const addr = net.Address.parseIp4("127.0.0.1", 9090) catch |err| {
        std.debug.print("An error occurred while resolving the IP address: {}\n", .{err});
        return;
    };
    var server = try addr.listen(.{ .force_nonblocking = true, .reuse_address = true });

    std.debug.print("Server is up in port :9090", .{});
    while (flag.load(.seq_cst) == false) {
        var connection = server.accept() catch {
            continue;
        };
        defer connection.stream.close();

        var read_buffer: [1024]u8 = undefined;
        var http_server = http.Server.init(connection, &read_buffer);

        var request = http_server.receiveHead() catch |err| {
            std.debug.print("Could not read head: {}\n", .{err});
            continue;
        };
        handle_request(&request) catch |err| {
            std.debug.print("Could not handle request: {}", .{err});
            continue;
        };
    }

    // Cerrar el servidor de manera segura
    std.debug.print("Deinit server \n", .{});

    server.deinit();
    _ = gpa.deinit();

    std.debug.print("server is down", .{});
}

fn handle_request(request: *http.Server.Request) !void {
    std.debug.print("Handling request for {s}\n", .{request.head.target});

    if (std.mem.eql(u8, request.head.target, "/assets/styles.css")) {
        try request.respond(template.CSS, .{});
    } else if (std.mem.eql(u8, request.head.target, "/assets/htmx.js")) {
        try request.respond(template.HTMX, .{});
    } else if (std.mem.eql(u8, request.head.target, "/app/home")) {
        try request.respond(template.homeTemplate, .{});
    } else if (std.mem.endsWith(u8, request.head.target, ".md") or std.mem.endsWith(u8, request.head.target, ".markdown")) {
        try handleMarkdown(request);
    } else {
        try handleAsset(request);
    }
}

fn handleAsset(request: *http.Server.Request) !void {
    if (request.head.target.len < 2) {
        // If the target is just "/", return a 404
        try request.respond("Invalid path", .{ .status = .not_found });
        return;
    }
    // remove leading "/" from request path
    const filePath = request.head.target[1..request.head.target.len];

    var file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close();

    // Get file size
    const file_size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read file into buffer
    _ = try file.readAll(buffer);

    // set content length
    const size = try std.fmt.allocPrint(allocator, "{d}", .{file_size});
    defer allocator.free(size);
    const content_length: http.Header = .{
        .name = "Content-Length",
        .value = size,
    };

    const mime_type = try getMimeType(filePath);
    defer allocator.free(mime_type);
    const content_type: http.Header = .{
        .name = "Content-Type",
        .value = mime_type,
    };

    try request.respond(buffer, .{ .extra_headers = &[_]http.Header{ content_length, content_type } });
}

fn handleMarkdown(request: *http.Server.Request) !void {
    // Handle markdown file requests
    if (request.head.target.len < 2) {
        // If the target is just "/", return a 404
        try request.respond("Invalid path", .{ .status = .not_found });
        return;
    }

    // Remove the leading '/' to get the file path
    const file_path = request.head.target[1..request.head.target.len];

    // Parse the markdown file to HTML
    const markdown = parser.parseFileToHtml(file_path, allocator) catch |err| {
        std.debug.print("Failed to parse markdown file: {s}\n", .{@errorName(err)});
        try request.respond("Failed to process markdown", .{ .status = .internal_server_error });
        return;
    };
    defer markdown.deinit();

    // Get the HTML content
    const content = markdown.getContent() catch |err| {
        std.debug.print("Failed to get markdown content: {s}\n", .{@errorName(err)});
        try request.respond("Failed to process markdown", .{ .status = .internal_server_error });
        return;
    };

    const html = try std.fmt.allocPrint(allocator, template.homeTemplate, .{content});
    defer allocator.free(html);

    // Serve the HTML content
    try request.respond(html, .{});
}

fn getMimeType(filePath: []const u8) ![]u8 {
    // Inicializamos en el heap con el valor por defecto
    var mime_type: []u8 = undefined;

    // Buscar la última aparición de "."
    if (std.mem.lastIndexOfScalar(u8, filePath, '.')) |pos| {
        const extension = filePath[pos..];

        // Modificamos el MIME type según la extensión
        if (std.mem.eql(u8, extension, ".jpg")) {
            mime_type = try allocator.dupe(u8, "image/jpeg");
        } else if (std.mem.eql(u8, extension, ".png")) {
            mime_type = try allocator.dupe(u8, "image/png");
        } else if (std.mem.eql(u8, extension, ".webp")) {
            mime_type = try allocator.dupe(u8, "image/webp");
        } else {
            mime_type = try allocator.dupe(u8, "text/plain");
        }
    }

    return mime_type;
}

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

    var server = try addr.listen(.{ .force_nonblocking = true });

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
    } else {
        // TODO: open file
        const markdown = try parser.parseFileToHtml("README.md", allocator);
        const content = try markdown.getContent();
        defer markdown.deinit();

        try request.respond(content, .{});
    }
}

const std = @import("std");
const http = @import("http.zig");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator: Allocator = gpa.allocator();

const parseToHtml = @import("parser.zig").parseToHtml;
const homeTemplate = @import("template.zig").homeTemplate;

const WebView = @import("webview").WebView;

pub fn main() !void {
    var server_thread = try std.Thread.spawn(.{}, http.startHttpServer, .{});

    // parse command-line args
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len <= 1) {
        std.log.err("Debe proporcionar un archivo", .{});
        return;
    }

    const fileName = args[1];

    // Headless flag, don't instantiate the webview instance
    if (std.mem.eql(u8, fileName, "--headless")) {
        server_thread.join();
        return;
    }

    var w = WebView.create(false, null);
    try w.setTitle("Markdown Viewer");

    // Allocate space for the URL + null terminator
    const route = try std.fmt.allocPrintZ(allocator, "http://localhost:9090/{s}", .{fileName});
    defer allocator.free(route);

    std.debug.print("Navigating to: {s}\n", .{route});

    // Use the null-terminated string safely
    try w.navigate(route);

    try w.run();
    w.destroy() catch {
        std.debug.print("Error deallocating webview\n", .{});
    };

    // Stop http server
    http.stopServer();
    server_thread.join();
}

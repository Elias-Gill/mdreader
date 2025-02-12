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

    var w = WebView.create(true, null);
    try w.setTitle("Markdown Viewer");
    try w.navigate("http://localhost:9090/app/home");

    try w.run();
    w.destroy() catch {
        std.debug.print("Error deallocating webview\n", .{});
    };

    // Stop http server
    http.stopServer();
    server_thread.join();
}

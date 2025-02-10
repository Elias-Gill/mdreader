const std = @import("std");
const utils = @import("utils.zig");
const parseToHtml = @import("parser.zig").parseToHtml;

const WebView = @import("webview").WebView;

// Global storage for WebView instance
var window: ?*WebView = null;

pub fn main() !void {
    var html = try parseToHtml("# hola mundo", std.heap.page_allocator);

    var w = WebView.create(true, null);
    try w.setTitle("Markdown Viewer");
    const content = try html.getContent();
    try w.setHtml(content);

    // Store the WebView instance globally
    window = &w;

    // Create a callback context (without passing `w`)
    const helloCallback = WebView.CallbackContext(hello).init(null);
    try w.bind("myFunction", &helloCallback);

    try w.run();

    w.destroy() catch {
        std.debug.print("Error deallocating webview\n", .{});
    };

    // Cleanup
    html.deinit();
}

// Callback function that modifies the webview
fn hello(name: [:0]const u8, args: [:0]const u8, _: ?*anyopaque) void {
    std.debug.print("Callback called! Name: {s}, Args: {s}\n", .{ name, args });
    std.debug.assert(window != null);

    window.?.eval("document.body.innerHTML = '<h1>Updated Content!</h1>';") catch {
        std.debug.print("Failed to update content\n", .{});
    };
}

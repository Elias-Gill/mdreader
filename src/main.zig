const std = @import("std");

const WebView = @import("webview").WebView;
const parseToHtml = @import("parser.zig").parseToHtml;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var html = try parseToHtml("# Nada de nada", allocator);

    const w = WebView.create(false, null);

    try w.setTitle("Markdown Viewer");
    const content = try html.getContent();
    try w.setHtml(content);

    try w.run();

    w.terminate() catch {
        std.debug.print("Error closing webview\n", .{});
    };
    w.destroy() catch {
        std.debug.print("Error deallocating webview\n", .{});
    };

    // Correct cleanup order
    html.deinit();
    std.debug.assert(!gpa.detectLeaks());
    _ = gpa.deinit();
}

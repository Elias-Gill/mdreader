const std = @import("std");

const WebView = @import("webview").WebView;
const parseToHtml = @import("parser.zig").parseToHtml;

const utils = @import("utils.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    var html = try parseToHtml("[elias](https://portfolio-elias-gill.fly.dev)", allocator);

    const w = WebView.create(false, null);

    try w.setTitle("Markdown Viewer");
    const content = try html.getContent();
    try w.setHtml(content);

    try w.run();

    w.destroy() catch {
        std.debug.print("Error deallocating webview\n", .{});
    };

    // Correct cleanup order
    html.deinit();
    std.debug.assert(!gpa.detectLeaks());
    _ = gpa.deinit();
}

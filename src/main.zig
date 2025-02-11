const std = @import("std");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator: Allocator = gpa.allocator();

const parseToHtml = @import("parser.zig").parseToHtml;
const homeTemplate = @import("template.zig").homeTemplate;

const WebView = @import("webview").WebView;

// Global storage for WebView instance
var window: ?*WebView = null;

pub fn main() !void {
    var w = WebView.create(true, null);
    try w.setTitle("Markdown Viewer");
    try w.setHtml(homeTemplate);

    // Store the WebView instance globally
    window = &w;

    // Create a callback context (without passing `w`)
    const helloCallback = WebView.CallbackContext(hello).init(null);
    try w.bind("myFunction", &helloCallback);

    try w.run();

    w.destroy() catch {
        std.debug.print("Error deallocating webview\n", .{});
    };
}

// Callback function that modifies the webview
fn hello(name: [:0]const u8, args: [:0]const u8, _: ?*anyopaque) void {
    _ = name;
    std.debug.assert(window != null);

    const cleanedArgs = cleanArgs(args);
    const file = utils.readFileContent(cleanedArgs, allocator) catch {
        window.?.setHtml("Cannot open file") catch {};
        return;
    };
    defer file.deinit();

    const mergedContent = std.mem.join(allocator, "\n", file.items) catch {
        window.?.setHtml("Failed to merge file content") catch {};
        return;
    };
    defer allocator.free(mergedContent); // Free after use

    // Convert the received Markdown into HTML
    const parser = parseToHtml(mergedContent, allocator) catch {
        std.debug.print("Failed to parse Markdown\n", .{});
        return;
    };
    defer parser.deinit();
    const page = parser.getContent() catch {
        std.debug.print("Failed to get parsed markdown content\n", .{});
        return;
    };

    // Update the WebView with the new content
    window.?.setHtml(@as([:0]const u8, @ptrCast(page))) catch {
        std.debug.print("Failed to update content in WebView\n", .{});
    };
}

fn cleanArgs(args: [:0]const u8) []const u8 {
    if (args.len < 4) return args; // Ensure at least [""] is present

    var start: usize = 0;
    var end: usize = args.len;

    // Check and remove leading `["`
    if (args.len >= 2 and args[0] == '[' and args[1] == '"') {
        start += 2;
    }

    // Check and remove trailing `"]`
    if (args.len >= 2 and args[end - 2] == '"' and args[end - 1] == ']') {
        end -= 2;
    }

    return args[start..end];
}

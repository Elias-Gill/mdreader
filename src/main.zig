const std = @import("std");

const WebView = @import("webview").WebView;

const mdp = @cImport({
    @cInclude("md4c.h");
    @cInclude("md4c-html.h");
});

const ctx = struct {
    message: std.ArrayList(u8),
};

fn htmlCallback(chunk: [*c]const u8, size: mdp.MD_SIZE, context: ?*anyopaque) callconv(.C) void {
    // Cast the context to the correct type
    const output: *ctx = @ptrCast(@alignCast(context));

    // Convert the C pointer and size to a Zig slice
    const html = chunk[0..size];

    // Append the slice to the ArrayList
    output.message.appendSlice(html) catch {
        // Handle the error (e.g., log it or panic)
        std.debug.print("Failed to append to ArrayList!\n", .{});
        return;
    };
}

pub fn parse(text: []const u8) !std.ArrayList(u8) {
    // Initialize an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create a context with an ArrayList
    var context = ctx{
        .message = std.ArrayList(u8).init(allocator),
    };

    // Call md_html to convert Markdown to HTML
    const result = mdp.md_html(
        text.ptr,
        @as(c_uint, @intCast(text.len)),
        htmlCallback,
        &context, // Pass a mutable pointer to context
        0, // parser_flags (use default)
        0, // renderer_flags (use default)
    );

    // Check if the conversion was successful
    if (result != 0) {
        return error.MarkdownConversionFailed;
    }

    // Return the ArrayList (caller must deinitialize it)
    return context.message;
}

pub fn main() !void {
    // Parse the Markdown into HTML
    var html = try parse("# Nada de nada");
    defer html.deinit(); // Deinitialize the ArrayList when done

    // Ensure the HTML string is null-terminated
    try html.append(0); // Append null terminator
    const html_str: [:0]const u8 = html.items[0 .. html.items.len - 1 :0];

    // Create and configure the WebView
    const w = WebView.create(false, null);

    try w.setTitle("Markdown Viewer");
    // try w.setSize(800, 600, WebView.WindowSizeHint.None);

    // Pass the null-terminated string to setHtml
    try w.setHtml(html_str); // Cast to [*c]const u8

    try w.run();
    try w.destroy(); // Ensure WebView is destroyed when done
}

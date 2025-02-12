const std = @import("std");

const mdp = @cImport({
    @cInclude("md4c.h");
    @cInclude("md4c-html.h");
});

const Html = struct {
    _content: std.ArrayList(u8),
    _allocator: std.mem.Allocator,

    pub fn getContent(self: *Html) ![:0]const u8 {
        try self._content.append(0); // Null-terminate the string
        return self._content.items[0 .. self._content.items.len - 1 :0];
    }

    pub fn deinit(self: *Html) void {
        self._content.deinit();
        self._allocator.destroy(self);
    }

    fn init(allocator: std.mem.Allocator) !*Html {
        var c = try allocator.create(Html);
        c._content = std.ArrayList(u8).init(allocator);
        c._allocator = allocator;
        return c;
    }
};

fn callback(chunk: [*c]const u8, size: mdp.MD_SIZE, context: ?*anyopaque) callconv(.C) void {
    std.debug.assert(context != null);

    const output: *Html = @ptrCast(@alignCast(context)); // Cast context
    const html = chunk[0..size]; // Get the output chunk

    // Append the chunk to the HTML content
    output._content.appendSlice(html) catch |err| {
        std.debug.print("Failed to append: {}\n", .{err});
    };
}

pub fn readFileContent(file: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    const file_contents = try std.fs.cwd().readFileAlloc(allocator, file, std.math.maxInt(usize));
    return file_contents;
}

pub fn parseFileToHtml(file: []const u8, allocator: std.mem.Allocator) !*Html {
    // Read the file content
    const file_contents = try readFileContent(file, allocator);
    defer allocator.free(file_contents);

    // Initialize the HTML context
    var context = try Html.init(allocator);

    // Call md_html to convert markdown to HTML
    const result = mdp.md_html(
        @as([*c]const u8, @ptrCast(file_contents.ptr)), // Pointer to the file content
        @as(mdp.MD_SIZE, @intCast(file_contents.len)), // Length of the file content
        callback, // Callback function
        context, // User data (HTML context)
        0, // Parser flags
        0, // Renderer flags
    );

    // Check for errors
    if (result != 0) {
        context.deinit();
        return error.MarkdownConversionFailed;
    }

    return context;
}

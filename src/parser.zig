const std = @import("std");

const mdp = @cImport({
    @cInclude("md4c.h");
    @cInclude("md4c-html.h");
});

const Html = struct {
    _content: std.ArrayList(u8),
    _allocator: std.mem.Allocator,

    pub fn getContent(self: *Html) ![:0]const u8 {
        try self._content.append(0);
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

    const output: *Html = @ptrCast(@alignCast(context)); // cast context
    const html = chunk[0..size]; // copy output string
    // TODO: maybe make some processing over the string

    output._content.appendSlice(html) catch |err| {
        std.debug.print("Failed to append: {}\n", .{err});
    };
}

pub fn parseToHtml(text: []const u8, allocator: std.mem.Allocator) !*Html {
    var context = try Html.init(allocator);

    const result = mdp.md_html(
        text.ptr,
        @as(c_uint, @intCast(text.len)),
        callback,
        context,
        0,
        0,
    );

    if (result != 0) {
        context.deinit();
        return error.MarkdownConversionFailed;
    }

    return context;
}

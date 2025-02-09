const std = @import("std");

/// Read all the content of a file (line by line) from the file system and returns the content as a
/// ArrayList (item = line).
///
/// Usage example:
/// var content = readFile("README.md", allocator) catch {
///     std.debug.print("cannot open file", .{});
///     return;
/// };
///
/// for (content.items) |item| {
///     std.debug.print("{s}\n", .{item});
///     allocator.free(item);
/// }
/// content.deinit();
///
pub fn readFileContent(file: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    const fd = try std.fs.cwd().openFile(file, .{});
    defer fd.close();

    var result = std.ArrayList([]const u8).init(allocator);

    while (try fd.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        try result.append(@as([]const u8, line));
    }

    return result;
}

/// Lists the current working directory recursively and returns all paths (relative to the current directory)
/// to markdown (.md) files
pub fn listFiles(allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    var cwd = try std.fs.cwd().openDir(".", .{ .iterate = true });
    defer cwd.close();

    var walker = try cwd.walk(allocator);
    defer walker.deinit();

    var result = std.ArrayList([]const u8).init(allocator);
    errdefer result.deinit();

    while (try walker.next()) |entry| {
        if (std.mem.endsWith(u8, entry.basename, ".md") or std.mem.endsWith(u8, entry.basename, ".markdown")) {
            const clone = try allocator.dupe(u8, entry.path); // clone entry path
            try result.append(clone);
        }
    }

    return result;
}


/****************************************************************
File: file_sizes.d
---------------------------------------------
Author: Vasudev Ram
Copyright 2016 Vasudev Ram
Web site: https://vasudevram.github.io
Blog: http://jugad2.blogspot.com
Product store: https://gumroad.com/vasudevram
---------------------------------------------
Purpose: To find the sizes of all files (recursively, including in 
subdirectories) under a given directory tree.
Compile with:

$ dmd file_sizes.d

Description: To find the sizes of all files under a given directory 
tree. The program will print both the name of the file and 
the file size in bytes, one file per line. At the end, it will 
also print the total number of files, and sum of their sizes.
****************************************************************/

import std.stdio;
import std.file;

void usage(string[] args) {
    stderr.writeln("Usage: ", args[0], " dirName");
    stderr.writeln(
        "Recursively find and print names and " ~
        "sizes of all files under dirName.");
}

int main(string[] args) {
    if (args.length != 2) {
        usage(args);
        return 1;
    }
    string dirName = args[1];
    // Check if dirName exists.
    if (!exists(dirName)) {
        stderr.writeln("Error: ", dirName, " not found. Exiting.");
        return 1;
    }
    // Check if dirName is not the NUL device and is actually a directory.
    if (dirName == "NUL" || !DirEntry(dirName).isDir()) {
        stderr.writeln("Error: ", dirName, " is not a directory. Exiting.");
        return 1;
    }
    try {
        ulong file_count = 0;
        ulong total_size = 0;
        ulong size;
        foreach(DirEntry de; dirEntries(args[1], SpanMode.breadth)) {
            // The isFile() check may be enough, also need to check for
            // Windows vs. POSIX behavior.
            if (de.isFile() && !de.isDir()) {
                size = getSize(de.name());
                writeln(de.name(), "\t", size);
                total_size += size;
                file_count += 1;
            }
        }
        writeln("Total number of files under directory '", args[1], 
            "': ", file_count);
        writeln("Total size in bytes of files under directory '", args[1], 
            "': ", total_size);

    } catch (FileException fe) {
        stderr.writeln("Got a FileException: ", fe.toString(), 
        "\n. Errno: ", fe.errno, ". Exiting.");
        return 1;
    } catch (Exception e) {
        stderr.writeln("Got an Exception: ", e.toString(), 
        "\n. Exiting.");
        return 1;
    }
    return 0;
}


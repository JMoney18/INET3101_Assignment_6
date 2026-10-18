# Programming Assignment 6: GNU Coreutils

## Problem Statement & Solution Overview

For this assignment, I worked with GNU Coreutils 9.7 to change the behavior of two commands. The goal was to make `ls` display a long listing without needing `-l` and make `whoami` print `You are: ` before the username.

I used AI to help locate the relevant code, prepare the changes, and explain how they work. I organized the files in my Assignment 6 folder, ran the build in VS Code’s integrated terminal, and checked the results myself.

I could not locate the build script mentioned in the assignment, so I emailed my professor for clarification. Since I had not received a response by the due date, I used AI assistance to create a replacement `build_on_mac.sh`.

The script downloads Coreutils 9.7, copies the modified source files into the source tree, and compiles `ls` and `whoami`. It generates the compatibility headers needed for the build. The compiled programs stay inside the assignment folder.

### Building and Running

From the Assignment 6 folder, I ran:

```bash
bash build_on_mac.sh
```

After the build succeeded, I ran:

```bash
./build/coreutils-9.7/src/ls
./build/coreutils-9.7/src/whoami
bash verify.sh
```

## C System Mechanics & Diff Analysis

### Changes to ls.c

When I first opened `ls.c`, I wasn’t sure where to start because the file had over 5,000 lines. With AI’s help, I looked at how the program handles `-l`, since that option already produces the output needed for this assignment.

The program uses `enum format` to define its listing styles. The global variable `format` holds the style the program will use. Inside `decode_switches()`, `getopt_long()` reads the command-line options, and `format_opt` tracks whether the user selected a format.

The original default chooses between columns and one filename per line depending on whether the output is going to a terminal. The change replaces that choice with `long_format`.

The part that checks `format_opt` stays the same, so users can still choose another format. I checked this by running the verification script, which confirmed that `-1` and `-C` still work.

What helped me understand this change was realizing that I didn’t need to write the long-listing code myself. It was already there. I only needed to change when the program selects it.

### Changes to whoami.c

For `whoami.c`, the username lookup was already working, so the only change needed was how it prints the result.

With AI’s explanation, I learned that `geteuid()` gets the process’s effective user ID. Then `getpwuid()` looks up the account information for that ID. It returns a pointer to a `struct passwd`, and `pw->pw_name` gives the username. The effective user can be different from the person who originally logged in.

The original output line was:

```c
puts (pw->pw_name);
```

The modified line is:

```c
printf ("You are: %s\n", pw->pw_name);
```

This prints `You are: ` followed by the username. The `%s` is where the username goes, and `\n` starts a new line afterward. The lookup functions and existing error handling stay the same.

I ran the compiled program myself and confirmed that it printed `You are: jason`.

### Unified Diff

This patch shows the exact changes compared with the original Coreutils 9.7 source. AI wrote it out in terms that I believe you wanted it to be.

```diff
diff --git a/src/ls.c b/src/ls.c
index 1078f88..339082c 100644
--- a/src/ls.c
+++ b/src/ls.c
@@ -2312,8 +2312,7 @@ decode_switches (int argc, char **argv)
     }
 
   format = (0 <= format_opt ? format_opt
-            : ls_mode == LS_LS ? (stdout_isatty ()
-                                  ? many_per_line : one_per_line)
+            : ls_mode == LS_LS ? long_format
             : ls_mode == LS_MULTI_COL ? many_per_line
             : /* ls_mode == LS_LONG_FORMAT */ long_format);
 
diff --git a/src/whoami.c b/src/whoami.c
index 9313eaf..bc7e23b 100644
--- a/src/whoami.c
+++ b/src/whoami.c
@@ -83,6 +83,6 @@ main (int argc, char **argv)
   if (!pw)
     error (EXIT_FAILURE, errno, _("cannot find name for user ID %ju"),
            (uintmax_t) uid);
-  puts (pw->pw_name);
+  printf ("You are: %s\n", pw->pw_name);
   return EXIT_SUCCESS;
 }
```

## Pros & Cons of Solution

One benefit is that `ls` shows more file information without requiring an extra flag. The changes are small because they reuse functionality already in Coreutils.

A disadvantage is that changing standard command output could break shell scripts. A script expecting only a username would also have trouble with the new `whoami` prefix. Long listings may take more work because they require additional file metadata.

For this assignment, I ran the modified programs using their paths inside the build folder.

## AI Audit Reflection

I used AI to help me work through parts of the assignment that I didn’t understand. When I saw that `ls.c` had over 5,000 lines, I asked how to figure out which part needed to change. I had AI explain how the program selects its output format and how command-line options affect that choice.

I also asked questions about the build process because I was confused about `bash build_on_mac.sh`. Through that discussion, I learned that the command runs a script file that needs to be available on my computer. After I couldn’t locate the course script and hadn’t received a response from my professor, I worked with AI to prepare a replacement.

AI helped implement the source changes and prepare the build and verification scripts. I then moved the files into my assignment folder and ran the commands myself in VS Code. I shared the results with AI to help interpret the output and check whether anything was wrong.

After testing, I had AI explain the differences between the original and modified code. This helped me understand why changing the default to `long_format` works while still allowing options like `-1` and `-C`. I also learned why `whoami` only needed a change to its print statement rather than its username lookup.

I used the actual build and program output to check the solution. Both programs compiled, the required output appeared, and the verification script reported that all checks passed.

## Testing & Screenshots

I tested the programs in VS Code’s terminal. First, I ran `bash build_on_mac.sh` to compile them. There were warnings about duplicate libraries, but the build finished with `BUILD SUCCESS`.

Next, I ran the modified `ls` without adding `-l`. It showed file permissions, owner and group names, sizes, dates, and filenames. This confirmed that long listings were working by default.

I then ran the modified `whoami`, which printed:

```text
You are: jason
```

Finally, I ran `bash verify.sh` to check the changes more closely. It confirmed that the default listing matched `-l` and that `-1` and `-C` could still select other formats. It also checked the username prefix and a few existing behaviors, such as rejecting extra arguments for `whoami`. The script finished with `ALL CHECKS PASSED`.

I saved screenshots of the successful build, both commands, and the verification results in the `Screenshots` folder.
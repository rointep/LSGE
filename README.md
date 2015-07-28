# LSGE
LSGE (Lua Storyboard Generator Engine) is a fast osu! storyboard generation application utilizing the Lua scripting language. LSGE allows you to take advantage of a powerful scripting language to quickly generate thousands of lines of storyboard code.


# How to use
### Download the application
You can download the latest stable version of LSGE from the [releases](../../releases) page.

### Building from source
While the parser is written in pure Lua, you can build the executable from source if you want. You'll need Lua 5.3 binaries and header files in order to compile.
The application comes as a Visual Studio 2013 project. Make sure to include the _parser.lsge_ script with your executable.¸

### Compiling storyboard scripts
LSGE is a command line application; currently there are no GUI extensions available for it. 

You can simply drag-and-drop your script file onto the LSGE executable and it will, providing your code is error-free, "compile" and generate the storyboard code for you and save it as "output.osb".
If you're an advanced user, here's the detailed command line syntax:
```
lsge SCRIPTFILE <option(s)>

Options:
-h                  Show a help message
-d DESTINATION      Specify the destination filepath where the generated .osb will be written
```
# Documentation

Visit the [Wiki](wiki) for detailed information about functions and methods available.

# License

LSGE is licensed under GPLv3 license.

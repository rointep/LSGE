#include <iostream>
#include <string>
#include <ctime>
#include <lua.hpp>

static void show_usage_message(std::string name)
{
	std::cerr << "Usage: " << name << " SOURCEFILE <option(s)>" << std::endl
		<< "Options:" << std::endl
		<< "\t-h \t\t\tShow this help message." << std::endl
		<< "\t-d DESTINATION\t\tSpecify the filepath for the generated code. Defaults to 'output.osb'." << std::endl;
}

int main(int argc, char* argv[])
{
	std::cout << "LSGE - Version 1.0 -" << std::endl;

	if (argc < 2) {
		show_usage_message(argv[0]);
		return -1;
	}

	char* lua_destinationPath = NULL;
	
	for (int i = 2; i < argc; ++i) {
		std::string arg = argv[i];
		if (arg == "-h") {
			show_usage_message(argv[0]);
			return 0;
		} else if (arg == "-d") {
			if (i + 1 < argc) {
				lua_destinationPath = argv[++i];
			} else {
				std::cerr << "-d option requires an additional argument." << std::endl;
				return -1;
			}
		}
	}
	
	// Create new Lua state
	lua_State* L = luaL_newstate();

	luaL_openlibs(L);

	// Run our parser code
	if (luaL_dofile(L, "parser.lsge") != 0) {
		std::cerr << "The program failed to initialize. Please make sure that 'parser.lsge' exists in the program's running directory and is readable by the system." << std::endl << std::endl << lua_tostring(L, -1) << std::endl;
		lua_pop(L, 1);
		return -1;
	}

	if (lua_destinationPath != NULL) {
		lua_pushstring(L, lua_destinationPath);
		lua_setglobal(L, "LSGE_DESTINATION_FILEPATH");
	}

	std::cout << "Generating storyboard code..." << std::endl;

	clock_t begin = clock();

	// Run the user's storyboard script
	if (luaL_dofile(L, argv[1]) != 0) {
		std::cerr << "Compilation failed, please check your source file for errors." << std::endl << std::endl << lua_tostring(L, -1) << std::endl;
		lua_pop(L, 1);
		return -1;
	}

	lua_getglobal(L, "LSGE_BUILD_STORYBOARD");
	if (!lua_isfunction(L, -1))	{
		std::cerr << "Unable to generate storyboard file. The 'parser.lsge' file may be corrupt." << std::endl;
		lua_pop(L, 1);
		return -1;
	}

	if (lua_pcall(L, 0, 0, 0) != 0) {
		std::cerr << "Unable to generate storyboard file. " << std::endl << lua_tostring(L, -1) << std::endl;
		lua_pop(L, 1);
		return -1;
	}

	double elapsed_time = double(clock() - begin) / CLOCKS_PER_SEC;

	std::cout << "Complete! Elapsed time: " << elapsed_time << " seconds" << std::endl;

	// Close the Lua state
	lua_close(L);

	return 0;
}
/* Angolmois on GFOS: the stack (the game keeps path buffers and its BMS
 * tables on it) and the $VER string. The game's own main() is built as
 * ag_game_main (-Dmain=ag_game_main on angolmois.c only).
 * MIT, Copyright (c) 2026 AmiCradle Team. */
unsigned long __stack = 256 * 1024;
static const char version[] __attribute__((used)) =
	"$VER: Angolmois " AG_VERSION " (" AG_DATE ") GFOS";

int ag_game_main(int argc, char **argv);

int main(int argc, char **argv)
{
	return ag_game_main(argc, argv);
}

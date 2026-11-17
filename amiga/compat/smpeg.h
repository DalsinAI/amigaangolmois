/* Angolmois without SMPEG: MPEG-1 background movies (#BMP pointing at an
 * .mpg) are not played; the game says it could not load them and goes on
 * with the still images and the sound. SMPEG 2 is not part of GFOpenGPU's
 * SDL 2 kit, and its MPEG-1 decoder is not worth carrying for this.
 * Used on the PC tests too, so both builds run the same code.
 * MIT, Copyright (c) 2026 AmiCradle Team. */
#ifndef AG_SMPEG_SHIM_H
#define AG_SMPEG_SHIM_H
#include <SDL.h>

typedef struct SMPEG SMPEG;
typedef struct SMPEG_Frame { unsigned int w, h, image_width, image_height; Uint8 *image; } SMPEG_Frame;
typedef void (*SMPEG_DisplayCallback)(void *data, SMPEG_Frame *frame);

static inline SMPEG *SMPEG_new_rwops(SDL_RWops *src, void *info, int freesrc, int sdl_audio)
{
	(void)info; (void)sdl_audio;
	if (src && freesrc) SDL_RWclose(src);
	return NULL;
}
static inline void SMPEG_enablevideo(SMPEG *m, int e) { (void)m; (void)e; }
static inline void SMPEG_loop(SMPEG *m, int l) { (void)m; (void)l; }
static inline void SMPEG_setdisplay(SMPEG *m, SMPEG_DisplayCallback cb, void *data, SDL_mutex *lock)
{ (void)m; (void)cb; (void)data; (void)lock; }
static inline void SMPEG_play(SMPEG *m) { (void)m; }
static inline void SMPEG_stop(SMPEG *m) { (void)m; }
static inline void SMPEG_rewind(SMPEG *m) { (void)m; }
static inline void SMPEG_delete(SMPEG *m) { (void)m; }
#endif

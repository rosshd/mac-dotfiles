#!/usr/bin/env python3
import curses, time, random

STARS = ['·', '·', '·', '✦', '*', '˙']

SHIP = {
    'R': '»=>',
    'L': '<=«',
    'U': ' ▲ ',
    'D': ' ▼ ',
}

EXHAUST = {
    'R': ('·', -1, 0),
    'L': ('·', +3, 0),
    'U': ('▾',  1, +1),
    'D': ('▴', -1, +1),
}

TRACK = {
    'R': '─', 'L': '─', 'U': '│', 'D': '│',
    'TL': '╔', 'TR': '╗', 'BL': '╚', 'BR': '╝',
}

def build_path(top, bottom, left, right):
    path = []
    for x in range(left, right):     path.append((top, x, 'R'))
    for y in range(top, bottom):     path.append((y, right, 'D'))
    for x in range(right, left, -1): path.append((bottom, x, 'L'))
    for y in range(bottom, top, -1): path.append((y, left, 'U'))
    return path

def draw_track(stdscr, top, bottom, left, right, color):
    h, w = stdscr.getmaxyx()
    def put(y, x, ch):
        if 0 <= y < h and 0 <= x < w - 1:
            try: stdscr.addstr(y, x, ch, color)
            except curses.error: pass

    for x in range(left + 1, right):
        put(top, x, TRACK['R'])
        put(bottom, x, TRACK['R'])
    for y in range(top + 1, bottom):
        put(y, left, TRACK['U'])
        put(y, right, TRACK['U'])

    put(top,    left,  TRACK['TL'])
    put(top,    right, TRACK['TR'])
    put(bottom, left,  TRACK['BL'])
    put(bottom, right, TRACK['BR'])

def main(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_CYAN,    -1)
    curses.init_pair(2, curses.COLOR_YELLOW,  -1)
    curses.init_pair(3, curses.COLOR_WHITE,   -1)
    curses.init_pair(4, curses.COLOR_MAGENTA, -1)
    curses.init_pair(5, curses.COLOR_GREEN,   -1)
    curses.init_pair(6, curses.COLOR_BLUE,    -1)

    stdscr.timeout(0)
    random.seed(99)

    h, w = stdscr.getmaxyx()
    pad_y, pad_x = 2, 4
    top, bottom = pad_y, h - pad_y - 1
    left, right = pad_x, w - pad_x - 1

    stars = [(random.randint(top+1, bottom-1),
              random.randint(left+1, right-1),
              random.choice(STARS)) for _ in range(50)]

    path = build_path(top, bottom, left, right)
    pos, frame = 0, 0

    center_text = [
        "  · · · · · · · · · · · · ·  ",
        "                              ",
        "   ██████╗  ██████╗ ███████╗  ",
        "   ██╔══██╗██╔═══██╗██╔════╝  ",
        "   ██████╔╝██║   ██║███████╗  ",
        "   ██╔══██╗██║   ██║╚════██║  ",
        "   ██║  ██║╚██████╔╝███████║  ",
        "   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝  ",
        "                              ",
        "  · · · · · · · · · · · · ·  ",
    ]

    while True:
        key = stdscr.getch()
        if key in (ord('q'), 27):
            break

        h, w = stdscr.getmaxyx()
        stdscr.erase()

        # Stars (twinkle every 12 frames)
        for sy, sx, sc in stars:
            if 0 <= sy < h and 0 <= sx < w - 1:
                ch = sc if (frame + sy) % 12 != 0 else '·'
                try: stdscr.addstr(sy, sx, ch, curses.color_pair(2) | curses.A_DIM)
                except curses.error: pass

        # Track
        draw_track(stdscr, top, bottom, left, right, curses.color_pair(6))

        # Center ASCII name block
        cy = (top + bottom) // 2 - len(center_text) // 2
        cx = (left + right) // 2 - len(center_text[0]) // 2
        for i, line in enumerate(center_text):
            color = curses.color_pair(1) | curses.A_BOLD if '█' in line else curses.color_pair(3) | curses.A_DIM
            try: stdscr.addstr(cy + i, cx, line, color)
            except curses.error: pass

        # Spaceship
        y, x, direction = path[pos]
        ship = SHIP[direction]
        ex_char, ex_dx, ex_dy = EXHAUST[direction]

        blink = frame % 3 != 0
        try:
            stdscr.addstr(y, x, ship, curses.color_pair(1) | curses.A_BOLD)
            if blink:
                ey, ex = y + ex_dy, x + ex_dx
                if 0 <= ey < h and 0 <= ex < w - 1:
                    stdscr.addstr(ey, ex, ex_char, curses.color_pair(5))
        except curses.error:
            pass

        # Hint
        try: stdscr.addstr(h-1, 0, " q to exit ", curses.color_pair(3) | curses.A_DIM)
        except curses.error: pass

        stdscr.refresh()
        pos = (pos + 1) % len(path)
        frame += 1
        time.sleep(0.035)

try:
    curses.wrapper(main)
except KeyboardInterrupt:
    pass

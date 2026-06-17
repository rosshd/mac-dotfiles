#!/usr/bin/env python3
import curses, math, os, random, signal, subprocess, sys, time

TIMED = "--no-timeout" not in sys.argv

LOGO = [
    "                      ..'          ",
    "                  ,xNMM.           ",
    "                .OMMMMo            ",
    "                lMM\"               ",
    "      .;loddo:.  .olloddol;.       ",
    "    cKMMMMMMMMMMNWMMMMMMMMMM0:     ",
    "  .KMMMMMMMMMMMMMMMMMMMMMMMWd.     ",
    "  XMMMMMMMMMMMMMMMMMMMMMMMX.       ",
    " ;MMMMMMMMMMMMMMMMMMMMMMMM:        ",
    " :MMMMMMMMMMMMMMMMMMMMMMMM:        ",
    " .MMMMMMMMMMMMMMMMMMMMMMMMX.       ",
    "  kMMMMMMMMMMMMMMMMMMMMMMMMWd.     ",
    "  'XMMMMMMMMMMMMMMMMMMMMMMMMMMk    ",
    "   'XMMMMMMMMMMMMMMMMMMMMMMMMK.    ",
    "     kMMMMMMMMMMMMMMMMMMMMMMd      ",
    "      ;KMMMMMMMWXXWMMMMMMMk.       ",
    "        \"cooc*\"    \"*coo'\"         ",
]
LW = max(len(l) for l in LOGO)
LH = len(LOGO)
STARS = list("·˙·✦·˙·*")


def get_info():
    def sh(*cmd):
        try: return subprocess.check_output(list(cmd), text=True, stderr=subprocess.DEVNULL).strip()
        except: return "—"
    def sh_bash(cmd):
        try: return subprocess.check_output(["bash", "-c", cmd], text=True, stderr=subprocess.DEVNULL).strip()
        except: return "—"

    user  = os.environ.get("USER", "ross")
    host  = sh("hostname", "-s")
    ver   = sh("sw_vers", "-productVersion")
    build = sh("sw_vers", "-buildVersion")
    kern  = sh("uname", "-r")
    up    = sh_bash("uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}'")
    shell = sh_bash("fish --version 2>&1 | awk '{print $NF}'")
    cores = sh("sysctl", "-n", "hw.logicalcpu")
    term  = os.environ.get("TERM_PROGRAM", os.environ.get("LC_TERMINAL", "iTerm2"))
    pkgs_f = sh_bash("brew list 2>/dev/null | wc -l").strip()
    pkgs_c = sh_bash("brew list --cask 2>/dev/null | wc -l").strip()
    ip    = sh("ipconfig", "getifaddr", "en0")
    if ip == "—": ip = sh("ipconfig", "getifaddr", "en1")

    mem_total = int(sh("sysctl", "-n", "hw.memsize")) // (1024 ** 3)
    try:
        vm = subprocess.check_output(["vm_stat"], text=True)
        def vp(key):
            for line in vm.splitlines():
                if key in line:
                    return int(line.split(":")[1].strip().rstrip("."))
            return 0
        used = round((vp("Pages active") + vp("Pages wired down") + vp("Pages occupied by compressor")) * 4096 / 1024 ** 3, 1)
    except:
        used = "?"

    gpu  = sh_bash("system_profiler SPDisplaysDataType 2>/dev/null | grep 'Chipset Model' | head -1 | awk -F': ' '{print $2}'")
    res  = sh_bash("system_profiler SPDisplaysDataType 2>/dev/null | grep 'Resolution' | head -1 | awk -F': ' '{print $2}'")
    disk = sh_bash("df -h / | tail -1 | awk '{print $3 \"/\" $2 \" (\" $5 \" used)\"}'")
    batt = sh_bash("pmset -g batt | grep InternalBattery | awk '{print $3}' | tr -d ';'")
    batt_s = sh_bash("pmset -g batt | grep -o 'charging\\|discharging\\|charged' | head -1")

    return {
        "_title":   f"{user}@{host}",
        "OS":       f"macOS Tahoe {ver} ({build})",
        "Kernel":   f"Darwin {kern}",
        "Uptime":   up,
        "Shell":    f"fish {shell}",
        "Terminal": term,
        "WM":       "Quartz Compositor",
        "CPU":      f"Apple M5 Pro ({cores} cores)",
        "GPU":      gpu,
        "Memory":   f"{used} GiB / {mem_total} GiB",
        "Disk":     disk,
        "Display":  res,
        "Battery":  f"{batt} ({batt_s})" if batt != "—" else "—",
        "Local IP": ip,
        "Packages": f"{pkgs_f} (brew), {pkgs_c} (cask)",
    }


def main(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1,  curses.COLOR_YELLOW,  -1)
    curses.init_pair(5,  curses.COLOR_YELLOW,  -1)
    curses.init_pair(6,  curses.COLOR_WHITE,   -1)
    curses.init_pair(7,  curses.COLOR_YELLOW,  -1)
    curses.init_pair(8,  curses.COLOR_BLUE,    -1)
    curses.init_pair(9,  curses.COLOR_MAGENTA, -1)
    curses.init_pair(11, curses.COLOR_MAGENTA, -1)
    curses.init_pair(12, curses.COLOR_YELLOW,  -1)
    curses.init_pair(13, curses.COLOR_BLUE,    -1)
    curses.init_pair(14, curses.COLOR_CYAN,    -1)

    signal.signal(signal.SIGWINCH, lambda *_: sys.exit(0))

    stdscr.timeout(50)
    info = get_info()

    H, W      = stdscr.getmaxyx()
    INFO_W    = 45                          # approx info panel width
    CONTENT_W = LW + 2 + INFO_W
    CONTENT_H = LH
    OY        = max(1, (H - CONTENT_H) // 2)
    OX        = max(1, (W - CONTENT_W) // 2)
    LOX       = OX + 3                        # logo 3 chars right of orbit center
    CY, CX    = OY + LH // 2, OX + LW // 2   # orbit center unchanged
    RX, RY    = LW // 2 + 3, LH // 2 + 1
    info_x    = LOX + LW + 5
    max_score = LH * 0.75 + LW * 0.25

    random.seed(7)
    stars = []
    for _ in range(120):
        sy = random.randint(0, H - 2)
        sx = random.randint(0, W - 2)
        stars.append((sy, sx, random.choice(STARS)))
    logo_cells = {(OY + i, LOX + j) for i, row in enumerate(LOGO)
                  for j, ch in enumerate(row) if ch != ' '}

    t, frame   = 0.0, 0
    START      = time.time()
    in_front   = True
    last_half  = 0

    while True:
        key = stdscr.getch()
        if key != -1:
            break
        if TIMED and time.time() - START > 8.0:
            break

        # front/behind toggle every half-orbit
        half = int(t / math.pi)
        if half != last_half:
            in_front  = not in_front
            last_half = half

        # ship position and facing
        sx_f = CX + RX * math.cos(t)
        sy_f = CY + RY * 0.5 * math.sin(t) + 2
        dx   = (CX + RX * math.cos(t + 0.05)) - sx_f
        dy   = (CY + RY * 0.5 * math.sin(t + 0.05) + 2) - sy_f
        sx_i, sy_i = int(round(sx_f)), int(round(sy_f))
        if abs(dx) > abs(dy) * 1.4:
            ship, (ex, ey) = ("»=>", (-1, 0)) if dx > 0 else ("<=«", (3, 0))
        elif dy < 0:
            ship, (ex, ey) = (" ▲ ", (1, 1))
        else:
            ship, (ex, ey) = (" ▼ ", (1, -1))

        stdscr.erase()

        # stars across full terminal — skip logo and info panel cells
        for idx, (sy, sx, sc) in enumerate(stars):
            if (sy, sx) in logo_cells:
                continue
            if sy >= OY and sy < OY + LH and sx >= info_x and sx < info_x + 46:
                continue
            try:
                ch = sc if (frame + idx * 7) % 18 != 0 else "·"
                stdscr.addstr(sy, sx, ch,
                    curses.color_pair([7,7,7,8,9,7,8,9][idx % 8]) | curses.A_DIM)
            except curses.error: pass

        # logo with diagonal colour gradient
        for i, row in enumerate(LOGO):
            r = OY + i
            if r >= H: break
            for j, ch in enumerate(row):
                if ch == ' ': continue
                s = (i * 0.75 + j * 0.25) / max_score
                if   s < 0.42: pair, attr = 1,  curses.A_BOLD
                elif s < 0.50: pair, attr = 1,  curses.A_DIM
                elif s < 0.58: pair, attr = 6,  curses.A_DIM
                elif s < 0.72: pair, attr = 14, curses.A_DIM
                else:          pair, attr = 9,  curses.A_DIM
                try: stdscr.addstr(r, LOX + j, ch, curses.color_pair(pair) | attr)
                except curses.error: pass

        # info panel
        if info_x < W:
            try:
                stdscr.addstr(OY,     info_x, "🚀 " + info["_title"],          curses.color_pair(12) | curses.A_BOLD)
                stdscr.addstr(OY + 1, info_x, "─" * min(34, W - info_x - 1),  curses.color_pair(13) | curses.A_DIM)
            except curses.error: pass
            row = OY + 2
            for k, v in list(info.items())[1:]:
                if row >= H: break
                try:
                    stdscr.addstr(row, info_x,     f"{k:<9}", curses.color_pair(5) | curses.A_DIM)
                    stdscr.addstr(row, info_x + 9, v,         curses.color_pair(6))
                except curses.error: pass
                row += 1
            row += 1
            if row < H:
                try:
                    if TIMED:
                        progress = min((time.time() - START) / 8.0, 1.0)
                        bw  = min(30, W - info_x - 1)
                        bar = "█" * int(progress * bw) + "░" * (bw - int(progress * bw))
                        stdscr.addstr(row, info_x, bar, curses.color_pair(13) | curses.A_DIM)
                        row += 1
                        if row < H:
                            stdscr.addstr(row, info_x, "any key to skip", curses.color_pair(14) | curses.A_DIM)
                    else:
                        stdscr.addstr(row, info_x, "any key to exit", curses.color_pair(14) | curses.A_DIM)
                except curses.error: pass

        # ship (hides behind logo cells when in_front is False)
        if 0 <= sy_i < H and 0 <= sx_i < W - 3:
            for k, ch in enumerate(ship):
                col = sx_i + k
                if not in_front and (sy_i, col) in logo_cells:
                    continue
                try: stdscr.addstr(sy_i, col, ch, curses.color_pair(1) | curses.A_BOLD)
                except curses.error: pass
            if frame % 3 != 0:
                er, ec = sy_i + ey, sx_i + ex
                if 0 <= er < H and 0 <= ec < W - 1:
                    if in_front or (er, ec) not in logo_cells:
                        try: stdscr.addstr(er, ec, "·", curses.color_pair(11))
                        except curses.error: pass

        stdscr.refresh()
        t     += 0.05
        frame += 1


try:
    curses.wrapper(main)
except (KeyboardInterrupt, SystemExit):
    pass

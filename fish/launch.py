#!/usr/bin/env python3
import curses, math, os, random, signal, shutil, subprocess, sys, time

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
    battery = f"{batt} ({batt_s})" if batt != "—" else "—"

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
        "Battery":  battery,
        "Local IP": ip,
        "Packages": f"{pkgs_f} (brew), {pkgs_c} (cask)",
    }


def main(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1,  curses.COLOR_YELLOW,  -1)  # orange (logo top / ship)
    curses.init_pair(5,  curses.COLOR_YELLOW,  -1)  # info key labels
    curses.init_pair(6,  curses.COLOR_WHITE,   -1)  # info values
    curses.init_pair(7,  curses.COLOR_YELLOW,  -1)  # stars gold
    curses.init_pair(8,  curses.COLOR_BLUE,    -1)  # stars blue
    curses.init_pair(9,  curses.COLOR_MAGENTA, -1)  # purple (logo bottom / stars)
    curses.init_pair(11, curses.COLOR_MAGENTA, -1)  # exhaust
    curses.init_pair(12, curses.COLOR_YELLOW,  -1)  # title
    curses.init_pair(13, curses.COLOR_BLUE,    -1)  # separator
    curses.init_pair(14, curses.COLOR_CYAN,    -1)  # turquoise hint text

    stdscr.timeout(50)
    info = get_info()

    OY, OX   = 1, 4
    CY       = OY + LH // 2
    CX       = OX + LW // 2
    RX       = LW // 2 + 3
    RY       = LH // 2 + 1
    info_x   = OX + LW + 2
    max_score = LH * 0.75 + LW * 0.25

    random.seed(7)
    stars = [(random.randint(OY, OY + LH - 1), random.randint(0, OX + LW + 1), random.choice(STARS))
             for _ in range(40)]

    logo_cells = {(OY + i, OX + j) for i, line in enumerate(LOGO)
                  for j, ch in enumerate(line) if ch != ' '}

    t          = 0.0
    frame      = 0
    START      = time.time()
    DURATION   = 8.0
    in_front   = True
    last_orbit = 0

    _resize = [False]
    def on_resize(sig, _):
        _resize[0] = True
    signal.signal(signal.SIGWINCH, on_resize)

    while True:
        key = stdscr.getch()

        if _resize[0] or key == curses.KEY_RESIZE:
            _resize[0] = False
            sz = shutil.get_terminal_size()
            curses.resizeterm(sz.lines, sz.columns)
            stdscr.clearok(True)
            stdscr.refresh()
            continue

        if key != -1:
            break
        if TIMED and time.time() - START > DURATION:
            break

        # toggle front/behind every half-orbit
        current_half = int(t / math.pi)
        if current_half != last_orbit:
            in_front   = not in_front
            last_orbit = current_half

        # ship position + direction
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

        H, W = stdscr.getmaxyx()

        try:
            stdscr.erase()

            # stars
            star_colors = [7, 7, 8, 9, 7, 8]
            for idx, (sy, sx, sc) in enumerate(stars):
                if 0 <= sy < H and 0 <= sx < W - 1 and (sy, sx) not in logo_cells:
                    ch = sc if (frame + sy * 3) % 14 != 0 else "·"
                    stdscr.addstr(sy, sx, ch, curses.color_pair(star_colors[idx % 6]) | curses.A_DIM)

            # logo with diagonal gradient
            for i, line in enumerate(LOGO):
                row = OY + i
                if row >= H: break
                for j, ch in enumerate(line):
                    if ch == ' ': continue
                    score = (i * 0.75 + j * 0.25) / max_score
                    if   score < 0.42: pair, attr = 1,  curses.A_BOLD
                    elif score < 0.50: pair, attr = 1,  curses.A_DIM
                    elif score < 0.58: pair, attr = 6,  curses.A_DIM
                    elif score < 0.72: pair, attr = 14, curses.A_DIM
                    else:              pair, attr = 9,  curses.A_DIM
                    stdscr.addstr(row, OX + j, ch, curses.color_pair(pair) | attr)

            # info panel
            if info_x < W:
                stdscr.addstr(OY,     info_x, "🚀 " + info["_title"], curses.color_pair(12) | curses.A_BOLD)
                stdscr.addstr(OY + 1, info_x, "─" * min(34, W - info_x - 1), curses.color_pair(13) | curses.A_DIM)
                row = OY + 2
                for k, v in list(info.items())[1:]:
                    if row >= H: break
                    stdscr.addstr(row, info_x,              f"{k:<9}", curses.color_pair(5) | curses.A_DIM)
                    stdscr.addstr(row, info_x + 9, v,                  curses.color_pair(6))
                    row += 1
                row += 1
                if row < H:
                    if TIMED:
                        progress = min((time.time() - START) / DURATION, 1.0)
                        bw  = min(30, W - info_x - 1)
                        bar = "█" * int(progress * bw) + "░" * (bw - int(progress * bw))
                        stdscr.addstr(row, info_x, bar, curses.color_pair(13) | curses.A_DIM)
                        row += 1
                        if row < H:
                            stdscr.addstr(row, info_x, "any key to skip", curses.color_pair(14) | curses.A_DIM)
                    else:
                        stdscr.addstr(row, info_x, "any key to exit", curses.color_pair(14) | curses.A_DIM)

            # ship
            if 0 <= sy_i < H and 0 <= sx_i < W - 3:
                for k, ch in enumerate(ship):
                    col = sx_i + k
                    if not in_front and (sy_i, col) in logo_cells:
                        continue
                    stdscr.addstr(sy_i, col, ch, curses.color_pair(1) | curses.A_BOLD)
                if frame % 3 != 0:
                    er, ec = sy_i + ey, sx_i + ex
                    if 0 <= er < H and 0 <= ec < W - 1:
                        if in_front or (er, ec) not in logo_cells:
                            stdscr.addstr(er, ec, "·", curses.color_pair(11))

            stdscr.refresh()

        except curses.error:
            stdscr.clearok(True)

        t     += 0.05
        frame += 1


try:
    curses.wrapper(main)
except KeyboardInterrupt:
    pass

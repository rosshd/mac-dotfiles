ObjC.import("Foundation");

function safe(read, fallback = "") {
  try {
    const value = read();
    return value === null || value === undefined ? fallback : value;
  } catch (_error) {
    return fallback;
  }
}

function run(argv) {
  const daysBack = Number.parseInt(argv[0], 10);
  const daysForward = Number.parseInt(argv[1], 10);
  const selectedCalendars = argv.slice(2);
  const now = new Date();
  const startCutoff = new Date(now.getTime() - daysBack * 86400000);
  const endCutoff = new Date(now.getTime() + daysForward * 86400000);
  const calendarApp = Application("Calendar");
  const output = [];

  for (const calendar of calendarApp.calendars()) {
    const calendarName = safe(() => calendar.name());
    if (selectedCalendars.length > 0 && !selectedCalendars.includes(calendarName)) {
      continue;
    }
    const matchingEvents = calendar.events.whose({
      _and: [
        { startDate: { _greaterThanEquals: startCutoff } },
        { startDate: { _lessThanEquals: endCutoff } },
      ],
    })();
    for (const event of matchingEvents) {
      const start = safe(() => event.startDate(), null);
      const end = safe(() => event.endDate(), null);
      output.push({
        uid: safe(() => event.uid()),
        calendar: calendarName,
        title: safe(() => event.summary()),
        start: start ? start.toISOString() : "",
        end: end ? end.toISOString() : "",
        location: safe(() => event.location()),
        url: safe(() => event.url()),
        notes: safe(() => event.description()),
        all_day: String(safe(() => event.alldayEvent(), false)),
      });
    }
  }

  return JSON.stringify(output);
}

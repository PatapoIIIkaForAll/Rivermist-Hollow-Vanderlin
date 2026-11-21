#define AUTOTRANSLATE_LANG_EN "en"
#define AUTOTRANSLATE_LANG_RU "ru"

#define AUTOTRANSLATE_PREF_OFF "Off"
#define AUTOTRANSLATE_PREF_ENGLISH "Translate to English"
#define AUTOTRANSLATE_PREF_RUSSIAN "Translate to Russian"

/// Cached on the client when the setting is off, so listeners do not read the preference per message.
#define AUTOTRANSLATE_TARGET_NONE "off"

#define AUTOTRANSLATE_BACKEND_OFF "off"
#define AUTOTRANSLATE_BACKEND_CHECKING "checking"
#define AUTOTRANSLATE_BACKEND_OK "ok"
#define AUTOTRANSLATE_BACKEND_DOWN "down"

#define AUTOTRANSLATE_LINE_PENDING "pending"
#define AUTOTRANSLATE_LINE_DONE "done"
#define AUTOTRANSLATE_LINE_FAILED "failed"

/// Chat payload type. The panel shows "internal/" types on every tab and never merges them.
#define AUTOTRANSLATE_PANEL_MESSAGE "internal/translation"

#define AUTOTRANSLATE_CHANNEL_SAY "Say"
#define AUTOTRANSLATE_CHANNEL_EMOTE "Emote"
#define AUTOTRANSLATE_CHANNEL_OOC "OOC"
#define AUTOTRANSLATE_CHANNEL_LOOC "LOOC"
#define AUTOTRANSLATE_CHANNEL_ADMIN "Admin help"
#define AUTOTRANSLATE_CHANNEL_TEST "Test"

/// Longest wait for one result. rust-g cannot cancel a request, so this only frees the listeners.
#define AUTOTRANSLATE_REQUEST_TIMEOUT (8 SECONDS)
/// Delay between health checks while the backend is down.
#define AUTOTRANSLATE_PROBE_INTERVAL (30 SECONDS)
/// Failed requests in a row that mark the backend as down.
#define AUTOTRANSLATE_FAILURES_TO_TRIP 5
#define AUTOTRANSLATE_ERROR_HISTORY 10
#define AUTOTRANSLATE_LATENCY_SAMPLES 50
/// Share of letters one script needs before a line counts as that language.
#define AUTOTRANSLATE_SCRIPT_MAJORITY 0.6
/// rust-g clock id for request latency.
#define AUTOTRANSLATE_CLOCK "autotranslate"

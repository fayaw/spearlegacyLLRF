/* General macros for checking severity */
%%#define LOOP_INVALID_SEVERITY(arg_pvSeverity) (                         \
            ((arg_pvSeverity) >= INVALID_ALARM)                           \
            ) /* LOOP_INVALID_SEVERITY */

%%#define LOOP_MAJOR_SEVERITY(arg_pvSeverity) (                           \
            ((arg_pvSeverity) >= MAJOR_ALARM)                             \
            ) /* LOOP_MAJOR_SEVERITY */

%%#define LOOP_MINOR_SEVERITY(arg_pvSeverity) (                           \
            ((arg_pvSeverity) >= MINOR_ALARM)                             \
            ) /* LOOP_MINOR_SEVERITY */


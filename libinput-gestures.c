#include <unistd.h>
#include <sys/types.h>
//#include <sys/stat.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    setreuid(geteuid(), geteuid());
    setregid(getegid(), getegid());

    char linkPath[PATH_MAX];
    pid_t pid = getpid();
    sprintf(linkPath, "/proc/%d/exe", pid);

    char exePath[PATH_MAX];
    memset(exePath, 0, sizeof(exePath));

    if (readlink(linkPath, exePath, PATH_MAX) == -1)
    {
        printf("Failed to get executable path");
        return 1;
    }

    char scriptPath[PATH_MAX];
    snprintf(scriptPath, PATH_MAX, "%s.py", exePath);

    return execv(scriptPath, argv);
}

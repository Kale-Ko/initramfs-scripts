#include <cstdlib>
#include <unistd.h>
#include <sys/stat.h>
#include <pwd.h>
#include <grp.h>

int main()
{
    if (setuid(0) != 0)
    {
        return 1;
    }
    if (setgid(0) != 0)
    {
        return 1;
    }

    const char* PATH = "/scripts/cryptroot-unlock";

    struct stat path_stat;
    stat(PATH, &path_stat);

    if (path_stat.st_uid != 0 || path_stat.st_gid != 0)
    {
        return 1;
    }
    if (!(path_stat.st_mode & S_IRUSR) || !(path_stat.st_mode & S_IRGRP) || !(path_stat.st_mode & S_IROTH)
        || !(path_stat.st_mode & S_IXUSR) || !(path_stat.st_mode & S_IXGRP) || !(path_stat.st_mode & S_IXOTH)
        || (path_stat.st_mode & S_IWGRP) || (path_stat.st_mode & S_IWOTH))
    {
        return 1;
    }

    char* argv[2] = { (char*) PATH, nullptr };
    char** envp = environ;
    execve(PATH, argv, envp);

    return 0;
}
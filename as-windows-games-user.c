#define _GNU_SOURCE
#include <fcntl.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static int exec_prog(char* const* argv, unsigned int timeout_seconds) {
  pid_t my_pid;
  int status;

  if (0 == (my_pid = fork())) {
    // Map stdin/stdout/stderr to /dev/null
    int null_fd = open("/dev/null", O_RDWR);
    if (null_fd == -1) {
      perror("Error opening /dev/null");
      _exit(1);
    }
    dup2(null_fd, STDIN_FILENO);
    dup2(null_fd, STDOUT_FILENO);
    dup2(null_fd, STDERR_FILENO);
    close(null_fd);
    // Child gets replaced with an exec
    if (-1 == execvp(argv[0], argv)) {
      perror("Child processes execv failed");
      _exit(1);
    }
  }

  waitpid(my_pid, &status, 0);

  // printf("%s WEXITSTATUS %d WIFEXITED %d [status %d]\n",
  //  argv[0], WEXITSTATUS(status), WIFEXITED(status), status);

  if (1 != WIFEXITED(status) || 0 != WEXITSTATUS(status)) {
    perror("Process failed");
    return 1;
  }

  return 0;
}

int main(int argc, char* argv[]) {
  uid_t ruid = getuid();
  uid_t euid = geteuid();
  // Become the caller, but save privileged euid for later
  if (setresuid(ruid, ruid, euid) != 0) {
    perror("Failed to setresuid");
  }

  // Call xhost with the caller's privileges
  char* xhost_args[3];
  xhost_args[0] = strdup("xhost");
  xhost_args[1] = strdup("+SI:localuser:WindowsGamesUser");
  xhost_args[2] = NULL;
  if (exec_prog(xhost_args, 3) != 0) {
    return 1;
  }

  // Get privilege again
  if (setresuid(ruid, euid, -1) != 0) {
    perror("Failed to setresuid");
  }
  // Complete become WindowsGamesUser
  struct passwd* pwnam = getpwnam("WindowsGamesUser");
  if (setresuid(pwnam->pw_uid, pwnam->pw_uid, -1) != 0) {
    perror("Failed to setresuid");
  }
  setenv("USER", "WindowsGamesUser", 1);
  setenv("USERNAME", "WindowsGamesUser", 1);
  setenv("LOGNAME", "WindowsGamesUser", 1);
  const char* home = getenv("HOME");
  if (strstr(home, HOME_ROOT) != home) {
    fprintf(stderr,
            "The environment variable HOME=%s must start with prefix %s\n",
            home, HOME_ROOT);
    return 1;
  }

  // Ensure enough arguments have been given
  if (argv[0] == NULL && argv[1] == NULL) {
    fprintf(stderr, "Not enough arguments!");
    return 1;
  }

  // Call the same command we received
  if (execvp(argv[1], &argv[1]) != 0) {
    perror("Execv failed");
    return 1;
  }
  return 0;
}


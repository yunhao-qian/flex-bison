#include "hello.h"
#include <stdio.h>

int main(int argc, const char **argv) {
    if (argc <= 1) {
        printf("Good morning, boys and girls!\n");
    } else {
        say_hello(argc - 1, argv + 1);
    }
    return 0;
}

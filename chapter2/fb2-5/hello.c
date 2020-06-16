#include "hello.h"
#include <stdio.h>

void say_hello(int count, const char *people[]) {
    for (int i = 0; i < count; ++i) {
        printf("Good morning, %s!\n", people[i]);
    }
}

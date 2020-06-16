#include "dict.h"
#include "util.h"
#include <stdlib.h>
#include <string.h>

#define CALC_LEVEL_MAX 16

struct Dict *sym_table;

static const int cap_levels[CALC_LEVEL_MAX] = {
    101,
    211,
    431,
    863,
    1733,
    3467,
    6947,
    13901,
    27803,
    55609,
    111227,
    222461,
    444929,
    889871,
    1779761,
    3559537
};

struct Dict *new_dict(int level) {
    if (level < 0) {
        yyerror("internal error: invalid dict level %d", level);
        level = 0;
    }
    if (level >= CALC_LEVEL_MAX) {
        yyerror("fatal error: symbol table overflow");
        exit(0);
    }
    struct Dict *dict = malloc(sizeof(struct Dict));
    dict->level = level;
    dict->table = calloc(cap_levels[level], sizeof(struct Symbol));
    return dict;
}

static unsigned sym_hash(const char *name) {
    unsigned hash = 0, c;
    while (c = *name++) {
        hash = hash * 9 ^ c;
    }
    return hash;
}

/* resize the dictionary size to the next level */
static void resize_dict(struct Dict *dict) {
    struct Dict *new_d = new_dict(dict->level + 1);
    int old_cap = cap_levels[dict->level];
    /* insert the entries of the old dictionary one by one */
    for (struct Symbol *s = dict->table; s < dict->table + old_cap; ++s) {
        if (s->name) {
            struct Symbol *new_s = look_up(new_d, s->name, NULL);
            new_s->number = s->number;
        }
    }
    dict->level = new_d->level;
    /* swap the table pointer of the two dictionaries */
    {
        struct Symbol *temp = dict->table;
        dict->table = new_d->table;
        new_d->table = temp;
    }
    del_dict(new_d);
}

struct Symbol *look_up(struct Dict *dict, const char *name, int *is_new) {
    int cap = cap_levels[dict->level];
    struct Symbol *s = dict->table + sym_hash(name) % cap;
    for (int i = 0; i < cap; ++i) {
        if (s->name && !strcmp(s->name, name)) {
            if (is_new) {
                *is_new = 0;
            }
            return s;
        }
        if (!s->name) {
            s->name = strdup(name);
            if (is_new) {
                *is_new = 1;
            }
            return s;
        }
        /* linear probing */
        if (++s == dict->table + cap) {
            s = dict->table;
        }
    }
    resize_dict(dict);
    return look_up(dict, name, is_new);
}

void del_dict(struct Dict *dict) {
    int cap = cap_levels[dict->level];
    for (struct Symbol *s = dict->table; s < dict->table + cap; ++s) {
        if (s->name) {
            free(s->name);
        }
    }
    free(dict->table);
    free(dict);
}

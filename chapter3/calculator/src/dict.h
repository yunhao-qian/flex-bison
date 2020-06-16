#ifndef CALC_DICT_H_
#define CALC_DICT_H_

/* dictionary for storing variable names and values */

struct Symbol {
    char *name;
    double number;
};

struct Dict {
    int level;
    struct Symbol *table;
};

/* symbol table that stores the variables */
extern struct Dict *sym_table;

/* build a dictionary */
struct Dict *new_dict(int level);

/* look up a variable by its name */
/* is_new = 1 if the variable was not stored */
struct Symbol *look_up(struct Dict *dict, const char *name, int *is_new);

/* delete a dictionary */
void del_dict(struct Dict *dict);

#endif /* CALC_DICT_H_ */

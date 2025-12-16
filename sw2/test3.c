#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>
#include "mtk_c.h"

int main() {
  com0in = fdopen(3, "r");
  com0out = fdopen(3, "w");
  com1in = fdopen(4, "r");
  com1out = fdopen(4, "w");

  fprintf(com0out, "Port0");
}

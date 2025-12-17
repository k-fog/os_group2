#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>
#include "mtk_c.h"
FILE *com0in;
FILE *com0out;
FILE *com1in;
FILE *com1out;

void file_open(void) {
	com0in = fdopen(3, "r");
  com0out = fdopen(3, "w");
  com1in = fdopen(4, "r");
  com1out = fdopen(4, "w");
}
int main() {
  
  file_open();
  while(1) {
    fprintf(com0out, "Port0");
  }
}

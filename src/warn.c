#include <stdio.h>
int main(int argc, char *argv[]) {
   for(int i=1; i < argc;  i++){
      fprintf(stderr, "%s", argv[i]);
      if(i<argc-1) fprintf(stderr, " ");
   }
   fprintf(stderr, "\n");
   return 0;
}

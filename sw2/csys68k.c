#include<errno.h>
extern void outbyte(unsigned char c);
extern char inbyte();

int read(int fd, char *buf, int nbytes)
{
  char c;
  int  i;
  int ch;
  
  swith(fd) {
      case 0:
	ch=0;
	break;
      case 3:
	ch=0;
	break;
      case 4:
	ch=1;
	break;
      default:
	errno = EBADF;
	return -1
  }

  for (i = 0; i < nbytes; i++) {
    c = inbyte(ch);

    if (c == '\r' || c == '\n'){ /* CR -> CRLF */
      outbyte(ch,'\r');
      outbyte(ch,'\n');
      *(buf + i) = '\n';

    /* } else if (c == '\x8'){ */     /* backspace \x8 */
    } else if (c == '\x7f'){      /* backspace \x8 -> \x7f (by terminal config.) */
      if (i > 0){
	outbyte(ch,'\x8'); /* bs  */
	outbyte(ch,' ');   /* spc */
	outbyte(ch,'\x8'); /* bs  */
	i--;
      }
      i--;
      continue;

    } else {
      outbyte(ch, c);
      *(buf + i) = c;
    }

    if (*(buf + i) == '\n'){
      return (i + 1);
    }
  }
  return (i);
}

int write (int fd, char *buf, int nbytes)
{
  int i, j;
  for (i = 0; i < nbytes; i++) {
    if (*(buf + i) == '\n') {
      outbyte ('\r');          /* LF -> CRLF */
    }
    outbyte (*(buf + i));
    for (j = 0; j < 300; j++);
  }
  return (nbytes);
}

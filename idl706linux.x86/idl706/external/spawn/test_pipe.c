#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

int main(int argc, char **argv)
{
  float *data, total = 0.0;
  char *err_str;
  int i, n;

  /* Make sure the output is not buffered */
  setbuf(stdout, (char *) 0);

  /* Find out how many points */
  if (!fread(&n, sizeof(n), 1, stdin)) goto error;

  /* Get memory for the array */
  if (!(data = (float *) malloc(n * sizeof(*data)))) goto error;

  /* Read the data */
  if (!fread(data, sizeof(*data), n, stdin)) goto error;

  /* Calculate the average */
  for (i=0; i < n; i++) total += data[i];
  total /= (float) n;

  /* Return the answer */
  if (!fwrite(&total, sizeof(*data), 1, stdout)) goto error;
  return 0;			/* Success */

 error:
  err_str = strerror(errno);
  if (!err_str) err_str = "<unknown error>";
  fprintf(stderr, "test_pipe: %s\n", err_str);
  return 1;			/* Failure */
}

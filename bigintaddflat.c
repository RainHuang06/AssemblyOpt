/*--------------------------------------------------------------------*/
/* bigintadd.c                                                        */
/* Author: Rain Huang, Matthew Okechukwu                              */
/*--------------------------------------------------------------------*/

#include "bigint.h"
#include "bigintprivate.h"
#include <string.h>
#include <assert.h>

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

/* Return the larger of lLength1 and lLength2. */

static long BigInt_larger(long lLength1, long lLength2)
{
   long lLarger;

   if (lLength2 > lLength1) goto l2Larger;

      lLarger = lLength1;
      goto returnLarger;

   l2Larger:

      lLarger = lLength2;

   returnLarger:

   return lLarger;
}

/*--------------------------------------------------------------------*/

/* Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
   distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
   overflow occurred, and 1 (TRUE) otherwise. */

int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
{
   unsigned long ulCarry;
   unsigned long ulSum;
   long lIndex;
   long lSumLength;

   assert(oAddend1 != NULL);
   assert(oAddend2 != NULL);
   assert(oSum != NULL);
   assert(oSum != oAddend1);
   assert(oSum != oAddend2);

   /* Determine the larger length. */
   lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);

   /* Clear oSum's array if necessary. */
   if (oSum->lLength < lSumLength) goto noMemset;
      memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

   noMemset:

   /* Perform the addition. */

   ulCarry = 0;
   lIndex = 0;

   /*for (lIndex = 0; lIndex < lSumLength; lIndex++)*/

   loopStart:
   if(lIndex >= lSumLength) goto endOfLoop;

      ulSum = ulCarry;
      ulCarry = 0;

      ulSum += oAddend1->aulDigits[lIndex];
      if (ulSum >= oAddend1->aulDigits[lIndex]) goto carry1; /* Check for overflow. */
         ulCarry = 1;

      carry1:

      ulSum += oAddend2->aulDigits[lIndex];
      if (ulSum >= oAddend2->aulDigits[lIndex]) goto carry2; /* Check for overflow. */
         ulCarry = 1;
      
      carry2:

      oSum->aulDigits[lIndex] = ulSum;
      lIndex++;

      goto loopStart;

   endOfLoop:

   /* Check for a carry out of the last "column" of the addition. */
   if (ulCarry != 1) goto noCarry;
      if (lSumLength != MAX_DIGITS) goto notMax;
         return FALSE;
      notMax:
      oSum->aulDigits[lSumLength] = 1;
      lSumLength++;

   noCarry:
   
   /* Set the length of the sum. */
   oSum->lLength = lSumLength;

   return TRUE;
}

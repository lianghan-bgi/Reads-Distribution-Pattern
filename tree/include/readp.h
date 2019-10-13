#include "listp.h"

#ifndef __HAN_LISTP__
#define __HAN_LISTP__

int readP(FILE *fp,char **str){
		list_p *lp = createListP();
		char chr;
		while(!feof(fp) && (chr=fgetc(fp))!='\n' && chr>0){
			if(chr!='\r'){
				pushListP(&lp,chr);
			}
		}
		int len=getListArr(lp,str);
		deleteListP(&lp);
		return len;
}

#endif

/*
whatever, judge str[0] && delete the str
*/

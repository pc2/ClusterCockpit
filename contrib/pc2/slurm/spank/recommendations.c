/*
 *  *   To compile:
 *   *    gcc -shared -o renice.so renice.c
 *    *
 *     */
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/resource.h>
#include <pwd.h>
#include <stdint.h>

#include <slurm/spank.h>

SPANK_PLUGIN(recommendations, 1);

#define PRIO_ENV_VAR "SLURM_RECOMMENDATIONS"

static int _recommendations (int val,const char *optarg, int remote);

struct spank_option spank_options_allocator[] =
{
    { "recommendations", "[mode]",
      "Enables of disables the output of recommendations for the compute jobs in the file slurm-JOBID.recommendations in the jobs working directory. mode=[on,off]", 2, 0,
      (spank_opt_cb_f) _recommendations },
      
    SPANK_OPTIONS_TABLE_END
};

struct spank_option spank_options_local[] =
{
    { "recommendations", "[mode]",
      "Enables of disables the output of recommendations for the compute jobs in the file slurm-JOBID.recommendations in the jobs working directory. mode=[on,off]", 2, 0,
      (spank_opt_cb_f) _recommendations },
      
    SPANK_OPTIONS_TABLE_END
};

int slurm_spank_init (spank_t sp, int ac, char **av)
{
    //slurm_info ("slurm_spank_init");
    spank_err_t err;
    //whoami();
    int rc=ESPANK_SUCCESS;
    struct spank_option *opts_to_register = NULL;
    int i;
    switch ( spank_context() ) {
	    /* salloc, sbatch */
	    case S_CTX_ALLOCATOR: {
	      opts_to_register = spank_options_allocator;
	      break;
	    }
	    /* srun */
	    case S_CTX_LOCAL: {
	      opts_to_register = spank_options_local;
	      break;
	    }
    }
    if ( opts_to_register ) {
      while ( opts_to_register->name && (rc == ESPANK_SUCCESS) ) rc = spank_option_register(sp, opts_to_register++);
    }
    return (rc);
}
int slurm_spank_user_init (spank_t sp, int ac, char **av)
{
    //slurm_info ("slurm_user_init");
    spank_err_t err;
    uint32_t nodes;
    err=spank_get_item (sp, S_JOB_NNODES, &nodes);

    if(err!=ESPANK_SUCCESS){
 	slurm_error("error occured in spank plugin retreiving the number of nodes %i",nodes);
	return -1;
    }
   return 0;
}
//linked list for arguments
struct arg {
   char str[200];
   struct arg *next;
};
struct arg *next = NULL;
struct arg *start = NULL;
int argcount=0;

static int _recommendations (int val,const char *optarg,int remote)
{
    //linked list of arguments
    if(start == NULL) {
      if((start = malloc(sizeof(struct arg))) == NULL) {
         fprintf(stderr, "no storage for parser\n");
         return -1;
      }
      strcpy(start->str, optarg);
      start->next=NULL;
      argcount++;
    }else{
      struct arg *p;
      p=start;
      while(p->next != NULL)
         p=p->next;
      if((p->next = malloc(sizeof(struct arg))) == NULL) {
          fprintf(stderr,"no storage for parser\n");
          return -1;
      }
      p=p->next;
      strcpy(p->str,optarg);
      p->next=NULL; 
      argcount++;

    }
    return (0);
}

int slurm_spank_init_post_opt (spank_t sp, int ac, char **av)
{
    spank_err_t err;
    //slurm_info ("slurm_spank_init_post_opt");
    //whoami();
    if(start == NULL) {
      // default
	err=spank_job_control_setenv(sp,"SPANK_RECOMMENDATIONS","off",1);
	if(err!=ESPANK_SUCCESS){
		slurm_error("error: %s",spank_strerror(err));
		return -1;
	}
        return 0;
    }else{
      struct arg *p;
      p=start;
      while(p->next != NULL){
         p=p->next;
      }
    }
    
    struct arg *p;
    p=start;
    char key[]="on";
    if(strcmp(p->str,key)==0){
      err=spank_job_control_setenv(sp,"SPANK_RECOMMENDATIONS",key,1);
      if(err!=ESPANK_SUCCESS){
          slurm_error("error: %s",spank_strerror(err));
          return -1;
      } 
      slurm_info("Output of recommendations to the jobs working directory is enabled for this job.");
    }
    return 0;
}

